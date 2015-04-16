//
//  ViewController.m
//  BiteNowControl
//
//  Created by Nicole Zhu on 4/15/15.
//  Copyright (c) 2015 Delta Hackers. All rights reserved.
//

#import "ViewController.h"
#import "BFFeedViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.emailField resignFirstResponder];
    [self.nameField resignFirstResponder];
    if ([segue.identifier isEqualToString:@"login"]) {
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"username" equalTo:self.emailField.text];
        [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                if ([objects count] == 0) {
                    PFUser *user = [PFUser user];
                    user.username = self.emailField.text;
                    user.password = @"password";
                    user[@"name"] = self.nameField.text;
                    [user signUpInBackground];
                }
                else {
                    [PFUser logInWithUsernameInBackground:self.emailField.text password:@"password"];
                }
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
