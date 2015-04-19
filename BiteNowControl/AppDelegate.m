//
//  AppDelegate.m
//  BiteNowControl
//
//  Created by Nicole Zhu on 4/15/15.
//  Copyright (c) 2015 Delta Hackers. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "BFFeedViewController.h"
#import <Parse/Parse.h>

@interface AppDelegate ()

@property (strong, nonatomic) NSArray *reportArray;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self beginLocationTracking];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)] ) {
        // iOS 8 case
        [self registerUserNotificationCategoriesForApplication:application];
    } else {
        // iOS 7 case
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    }
    [Parse enableLocalDatastore];
    [Parse setApplicationId:@"YLdVnEbVE2KUq5AeLJnI1U9pDSaihGMyhn7rZNPG"
                  clientKey:@"KTimbSuvZuHwCq3XXelLocnnlE4YXz9KRGz79FoZ"];
    [self fetchReports];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchReports) name:@"reportUpdate" object:nil];
    [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(checkReports) userInfo:nil repeats:YES];
    NSLog(@"%@", [PFUser currentUser]);
    if ([PFUser currentUser] && [[PFUser currentUser] isAuthenticated]) {
        NSLog(@"%@", [PFUser currentUser]);
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BFFeedViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"homeView"];
        self.window.rootViewController = ivc;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayFoodNotification:) name:@"reportUpdate" object:nil];
    return YES;
}

-(void)checkReports {
    PFQuery *query = [PFQuery queryWithClassName:@"Report"];
    [query setLimit:1000];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count > self.reportArray.count) {
                PFObject *report = [objects lastObject];
                if ([[report objectForKey:@"FoodGeopoint"] distanceInMilesTo:[PFGeoPoint geoPointWithLocation:self.locationManager.location]] < 1) {
                    [self displayFoodNotification:[objects lastObject]];
                }
                self.reportArray = objects;
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)fetchReports {
     PFQuery *query = [PFQuery queryWithClassName:@"Report"];
    [query setLimit:1000];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.reportArray = objects;
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)registerUserNotificationCategoriesForApplication:(UIApplication *)application
{
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
}

-(void)beginLocationTracking
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        [self.locationManager startUpdatingLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    // NSLog(@"%@", location);
}

- (void)displayFoodNotification:(PFObject *)report
{
    UILocalNotification *foodNotification = [[UILocalNotification alloc] init];
    CLLocation *currentLocation = self.locationManager.location;
    NSString *foodType = @"";
    NSString *drinkType = @"";
    if (![[report objectForKey:@"FoodType"] isEqualToString:@"None"]) {
        foodType = [report objectForKey:@"FoodType"];
    }
    if (![[report objectForKey:@"DrinkType"] isEqualToString:@"None"]) {
        drinkType = [@" and " stringByAppendingString:[report objectForKey:@"DrinkType"]];
    }
    foodNotification.alertBody = [NSString stringWithFormat:@"%@%@ was reported on floor %@ of %@, %.2f miles away!", foodType, drinkType, [report objectForKey:@"Floor"], [report objectForKey:@"Building"], [((PFGeoPoint*)[report objectForKey:@"FoodGeopoint"]) distanceInMilesTo:[PFGeoPoint geoPointWithLocation:currentLocation]]];
    [[UIApplication sharedApplication] presentLocalNotificationNow:foodNotification];
}

-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
