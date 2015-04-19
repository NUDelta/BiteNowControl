//
//  BFContributeViewController.m
//  BiteNowControl
//
//  Created by Nicole Zhu on 4/15/15.
//  Copyright (c) 2015 Delta Hackers. All rights reserved.
//

#import "BFContributeViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>

@interface BFContributeViewController ()

@end

@implementation BFContributeViewController

@synthesize reportBuilding;
@synthesize buildingFloor;
@synthesize foodType;
@synthesize drinkType;
@synthesize foodRequirement;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self CurrentLocationIdentifier];
    // Do any additional setup after loading the view.
}

- (IBAction)saveReport:(id)sender {
    CLLocation *location = currentLocation;
    CLLocationCoordinate2D coordinate = [location coordinate];
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:coordinate.latitude
                                                  longitude:coordinate.longitude];
    PFObject *foodReport = [PFObject objectWithClassName:@"Report"];
    PFUser *user = [PFUser currentUser];
    foodReport[@"Building"] = [reportBuilding titleForSegmentAtIndex:reportBuilding.selectedSegmentIndex];
    foodReport[@"Floor"] = [buildingFloor titleForSegmentAtIndex:buildingFloor.selectedSegmentIndex];
    foodReport[@"FoodType"] = [foodType titleForSegmentAtIndex:foodType.selectedSegmentIndex];
    foodReport[@"DrinkType"] = [drinkType titleForSegmentAtIndex:drinkType.selectedSegmentIndex];
    foodReport[@"Requirement"] = [foodRequirement titleForSegmentAtIndex:foodRequirement.selectedSegmentIndex];
    foodReport[@"FoodGeopoint"] = geoPoint;
    foodReport[@"User"] = user;
    [foodReport saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"saved");
            UIAlertView *confirmation = [[UIAlertView alloc] initWithTitle:@"Saved food report" message:@"Thanks for submitting a report!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [confirmation show];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reportUpdate" object:nil];
        } else {
            // There was a problem, check error.description
            NSLog(@"error");
        }
    }];
}

-(void)CurrentLocationIdentifier {
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    currentLocation = [locations lastObject];
    NSLog(@"%@", currentLocation);
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        [locationManager startUpdatingLocation];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
