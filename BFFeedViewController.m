//
//  BFFeedViewController.m
//  BiteNowControl
//
//  Created by Nicole Zhu on 4/15/15.
//  Copyright (c) 2015 Delta Hackers. All rights reserved.
//

#import "BFFeedViewController.h"
#import "ReportDetailViewController.h"
#import "AppDelegate.h"

@interface BFFeedViewController ()
@property (weak, nonatomic) IBOutlet UITableView *feedTableView;
@property (strong, nonatomic) NSArray *reportArray;
@end

@implementation BFFeedViewController {
    NSArray *foodReports;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

-(void) updateTableView {
    [self.feedTableView reloadData];
}

- (void) initUI {
    // table view
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchReports) name:@"reportUpdate" object:nil];
    self.feedTableView.delegate = self;
    self.feedTableView.dataSource = self;
    [self fetchReports];
}

- (void) fetchReports {
    PFQuery *query = [PFQuery queryWithClassName:@"Report"];
    [query setLimit:1000];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            foodReports = [[NSArray alloc]initWithArray:objects];
            NSLog(@"Success %lu", (unsigned long)foodReports.count);
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        [self.feedTableView reloadData];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [foodReports count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSNumberFormatter *numberFormatter = nil;
    if (numberFormatter == nil) {
        numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        numberFormatter.maximumFractionDigits = 3;
    }
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    PFObject *report = [foodReports objectAtIndex:indexPath.row];
    PFGeoPoint *geoPoint = [report objectForKey:@"FoodGeopoint"];
    NSString *building = [report objectForKey:@"Building"];
    NSString *floor = [report objectForKey:@"Floor"];
    NSString *foodType = [report objectForKey:@"FoodType"];
    NSString *drinkType = [report objectForKey:@"DrinkType"];
    
    CLLocation *reportLocation = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
    double objectLat = geoPoint.latitude;
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *currentgeoPoint, NSError *error) {
        if (!error){
            NSLog(@"distance %f", [currentgeoPoint distanceInMilesTo:geoPoint]);
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setLocale:[NSLocale currentLocale]];
            [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            [numberFormatter setMaximumFractionDigits:2];
            
            if (![foodType isEqualToString:@"None"] && [drinkType isEqualToString:@"None"]) {
                // only food reported
                cell.textLabel.text = [NSString stringWithFormat:@"%@ on floor %@ of %@", foodType, floor, building];
            } else if ([foodType isEqualToString:@"None"] && ![drinkType isEqualToString:@"None"]) {
                // only drink reported
                cell.textLabel.text = [NSString stringWithFormat:@"%@ on floor %@ of %@", drinkType, floor, building];
            } else {
                // both food and drink reported
                cell.textLabel.text = [NSString stringWithFormat:@"%@ and %@ on floor %@ of %@", foodType, drinkType, floor, building];
            }
//            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.f meters away", [reportLocation distanceFromLocation:((AppDelegate *)[UIApplication sharedApplication].delegate).locationManager.location]];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ miles away", [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[currentgeoPoint distanceInMilesTo:geoPoint]]]];
        }
        else {
            UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Oops!" message:[error description] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
            [errorAlert show];
        }
    }];
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"reportDetail"]) {
        ReportDetailViewController *detailController = (ReportDetailViewController *)segue.destinationViewController;
        detailController.tableIndex = self.feedTableView.indexPathForSelectedRow.row;
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
