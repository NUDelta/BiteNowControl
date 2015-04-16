//
//  AppDelegate.m
//  BiteNowControl
//
//  Created by Nicole Zhu on 4/15/15.
//  Copyright (c) 2015 Delta Hackers. All rights reserved.
//

#import "AppDelegate.h"
#import "BFFeedViewController.h"
#import <Parse/Parse.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Parse enableLocalDatastore];
    [PFUser enableRevocableSessionInBackground];
    [Parse setApplicationId:@"YLdVnEbVE2KUq5AeLJnI1U9pDSaihGMyhn7rZNPG"
                  clientKey:@"KTimbSuvZuHwCq3XXelLocnnlE4YXz9KRGz79FoZ"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    NSLog(@"%@", [PFUser currentUser]);
    if ([PFUser currentUser] && [[PFUser currentUser] isAuthenticated]) {
        NSLog(@"%@", [PFUser currentUser]);
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BFFeedViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"feedView"];
        self.window.rootViewController = ivc;
    }
    return YES;
}

//- (void)presentFeedViewController {
//    // Go to the welcome screen and have them log in or create an account.
//    BFFeedViewController *viewController =
//    [[BFFeedViewController alloc] initWithNibName:nil
//                                             bundle:nil];
//    viewController.delegate = self;
//    [self.navigationController setViewControllers:@[ viewController ]
//                                         animated:NO];
//}

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
