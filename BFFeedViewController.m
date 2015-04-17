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

@end

@implementation BFFeedViewController {
    NSArray *foodReports;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
//   foodReports = [NSArray arrayWithObjects:@"Egg Benedict", @"Mushroom Risotto", @"Full Breakfast", @"Hamburger", @"Ham and Egg Sandwich", @"Creme Brelee", @"White Chocolate Donut", @"Starbucks Coffee", @"Vegetable Curry", @"Instant Noodle with Egg", @"Noodle with BBQ Pork", @"Japanese Noodle with Pork", @"Green Tea", @"Thai Shrimp Cake", @"Angry Birds Cake", @"Ham and Cheese Panini", nil];
//    [self initTableView];
}

//- (void)initTableView {
//    self.feedTableView.delegate = self;
//    self.feedTableView.dataSource = self;
//    
//}

- (void) initUI {
    // table view
    self.feedTableView.delegate = self;
    self.feedTableView.dataSource = self;
    PFQuery *query = [PFQuery queryWithClassName:@"Report"];
    [query setLimit:1000];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            foodReports = [[NSArray alloc]initWithArray:objects];
            // find succeeded, first 100 objects available in objects
            NSLog(@"Success %lu", (unsigned long)foodReports.count);
            //            for (PFObject *object in self.foodReports) {
            //                NSLog(@"%@", object.createdAt);
            //            }
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
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    //PFObject *tempObject = [self.foodReports objectAtIndex:indexPath.row];
    //cell.textLabel.text = [tempObject objectForKey:@"event"];
    PFObject *tempObject = [foodReports objectAtIndex:indexPath.row];
    PFGeoPoint *geoPoint = [tempObject objectForKey:@"location"];
    double objectLat = geoPoint.latitude;
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *currentgeoPoint, NSError *error) {
        if (!error){
            NSLog(@"distance %f", [currentgeoPoint distanceInMilesTo:geoPoint]);
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setLocale:[NSLocale currentLocale]];
            [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            [numberFormatter setMaximumFractionDigits:1];
            cell.textLabel.text = [NSString stringWithFormat:@"Food spotted %@ miles away", [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[currentgeoPoint distanceInMilesTo:geoPoint]]]];
        }
        else {
            UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Oops!" message:[error description] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
            [errorAlert show];
        }
    }];
    
    // time formatting
    NSDate *localDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYY-MM-dd hh:mm";
    // [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss Z"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSLog(@"The Current Time is the following %@",[dateFormatter stringFromDate:localDate]);
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:localDate];
    NSTimeInterval secondsBetween = [tempObject.createdAt timeIntervalSinceDate:localDate];
    int numberOfMinutes = (secondsBetween / 60) * -1;
    int numberOfHours = (secondsBetween / 3600) * -1;
    int numberOfDays = (secondsBetween / 86400) * -1;
    
    // conditional cell formatting
    //cell.textLabel.text = [dateFormatter stringFromDate:tempObject.updatedAt];
    if (numberOfMinutes > 60 && numberOfHours < 24) {
        NSString *string = [NSString stringWithFormat:@"Reported %d hours ago", numberOfHours];
        cell.detailTextLabel.text = string;
    } else if (numberOfHours > 24) {
        NSString *string = [NSString stringWithFormat:@"Reported %d days ago", numberOfDays];
        cell.detailTextLabel.text = string;
    } else {
        NSString *string = [NSString stringWithFormat:@"Reported %d minutes ago", numberOfMinutes];
        cell.detailTextLabel.text = string;
    }
    //    NSString *string = [NSString stringWithFormat:@"Food was reported %d days ago, %d hours, %d minutes ago.", numberOfDays, numberOfHours, numberOfMinutes];
    //    NSString *string = [NSString stringWithFormat:@"%@, %@",
    //                        [numberFormatter stringFromNumber:[NSNumber numberWithDouble:geoPoint.latitude]],
    //                        [numberFormatter stringFromNumber:[NSNumber numberWithDouble:geoPoint.longitude]]];
    
    //cell.textLabel.text = [self.foodReports objectAtIndex:indexPath.row];
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
