//
//  BFSettingsViewController.m
//  BiteNowControl
//
//  Created by Nicole Zhu on 4/18/15.
//  Copyright (c) 2015 Delta Hackers. All rights reserved.
//

#import "BFSettingsViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>

@interface BFSettingsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *userLabel;

@end

@implementation BFSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *user = [[PFUser currentUser] objectForKey:@"name"];
    self.userLabel.text = user;
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
