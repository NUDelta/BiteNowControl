//
//  ReportDetailViewController.m
//  BiteNowControl
//
//  Created by Nicole Zhu on 4/16/15.
//  Copyright (c) 2015 Delta Hackers. All rights reserved.
//

#import "ReportDetailViewController.h"
#import "AppDelegate.h"

@interface ReportDetailViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backBarButtonItem;
@property (weak, nonatomic) IBOutlet UINavigationBar *backNavigationBar;
@property (weak, nonatomic) IBOutlet MKMapView *reportMapView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *foodTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *reportTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *notFreeForAllLabel;

@end

@implementation ReportDetailViewController {
    NSArray *foodReports;
}

- (IBAction)backButtonPressed:(id)sender {
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.reportMapView.delegate = self;
    PFQuery *query = [PFQuery queryWithClassName:@"Report"];
    [query setLimit:1000];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            foodReports = [[NSArray alloc]initWithArray:objects];
            NSLog(@"Success %lu", (unsigned long)foodReports.count);
            // NSLog(@"%@", objects);
            //            for (PFObject *object in self.foodReports) {
            //                NSLog(@"%@", object.createdAt);
            //            }
            if (self.tableIndex >= 0) {
                [self addDetails];
            }
            [self loadReportAnnotation];
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
}

-(void)addDetails
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[NSLocale currentLocale]];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:2];
    
    PFObject *report = [foodReports objectAtIndex:self.tableIndex];
    NSLog(@"%@", foodReports);
    NSLog(@"%ld", (long)self.tableIndex);
    NSLog(@"REPORT %@", report);
    PFGeoPoint *geoPoint = [report objectForKey:@"FoodGeopoint"];
    NSString *building = [report objectForKey:@"Building"];
    NSString *floor = [report objectForKey:@"Floor"];
    NSString *foodType = [report objectForKey:@"FoodType"];
    NSString *drinkType = [report objectForKey:@"DrinkType"];
    
    self.locationLabel.text = [NSString stringWithFormat:@"Floor %@ of %@", floor, building];
    if (![foodType isEqualToString:@"None"] && [drinkType isEqualToString:@"None"]) {
        self.foodTypeLabel.text = [NSString stringWithFormat:@"%@", foodType];
    } else if ([foodType isEqualToString:@"None"] && ![drinkType isEqualToString:@"None"]) {
        self.foodTypeLabel.text = [NSString stringWithFormat:@"%@", drinkType];
    } else {
        self.foodTypeLabel.text = [NSString stringWithFormat:@"%@ and %@", foodType, drinkType];
    }
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *currentgeoPoint, NSError *error) {
        self.distanceLabel.text = [NSString stringWithFormat:@"%@ miles away", [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[currentgeoPoint distanceInMilesTo:geoPoint]]]];
    }];
    
    CLLocation *reportLocation = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
    //self.distanceLabel.text = [NSString stringWithFormat:@"%f meters away from you", [reportLocation distanceFromLocation:((AppDelegate*)[UIApplication sharedApplication].delegate).locationManager.location]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    self.reportTimeLabel.text = [NSString stringWithFormat:@"reported at %@", [formatter stringFromDate:report.updatedAt]];
    // WARNING: this should really be uncommented. However, the logic for determining whether the
    // food is free for everyone seems to be a bit screwed up. For the sake of our study, we will
    // leave this commented out.
    //if ([report.freeForAnyone isEqualToString:@"yes"]) {
    self.notFreeForAllLabel.hidden = YES;
    //}
}

- (void)loadReportAnnotation {
    PFObject *report = [foodReports objectAtIndex:self.tableIndex];
    PFGeoPoint *geoPoint = [report objectForKey:@"FoodGeopoint"];
    CLLocationCoordinate2D reportLocation = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
//    CLLocation *reportLocation = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
//    CLLocationCoordinate2D reportLoc = CLLocationCoordinate2DMake(report, report.lng.doubleValue);
    [self.reportMapView setCenterCoordinate:reportLocation animated:YES];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(reportLocation, 800, 800);
    [self.reportMapView setRegion:region];
    MKPointAnnotation *reportAnnotation = [[MKPointAnnotation alloc] init];
    reportAnnotation.coordinate = reportLocation;
    reportAnnotation.title = @"Free food!";
    [self.reportMapView addAnnotation:reportAnnotation];
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
