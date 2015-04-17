//
//  BFContributeViewController.h
//  BiteNowControl
//
//  Created by Nicole Zhu on 4/15/15.
//  Copyright (c) 2015 Delta Hackers. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>

@interface BFContributeViewController : ViewController<CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
}
@property (weak, nonatomic) IBOutlet UISegmentedControl *reportBuilding;
@property (weak, nonatomic) IBOutlet UISegmentedControl *buildingFloor;
@property (weak, nonatomic) IBOutlet UISegmentedControl *foodType;
@property (weak, nonatomic) IBOutlet UISegmentedControl *drinkType;
@property (weak, nonatomic) IBOutlet UISegmentedControl *foodRequirement;

@end
