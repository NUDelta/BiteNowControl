//
//  ViewController.m
//  BiteNowControl
//
//  Created by Nicole Zhu on 4/15/15.
//  Copyright (c) 2015 Delta Hackers. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>
#import "BFFeedViewController.h"
#import "AppDelegate.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    [self.emailField resignFirstResponder];
//    [self.nameField resignFirstResponder];
//    
//    if ([segue.identifier isEqualToString:@"login"]) {
//        PFUser *user = [PFUser user];
//        user.username = self.emailField.text;
//        user.password = @"password";
//        user[@"name"] = self.nameField.text;
//        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            if (!error) {
//                // Hooray! Let them use the app now.
//                NSLog(@"%@", [PFUser currentUser]);
//            } else {
//                NSString *errorString = [error userInfo][@"error"];
//                // Show the errorString somewhere and let the user try again.
//            }
//        }];
//    }
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
                    [[PFUser currentUser] fetch];
                    NSLog(@"%@", [PFUser currentUser]);
//                    [PFUser becomeInBackground:@"session-token-here" block:^(PFUser *user, NSError *error) {
//                        if (error) {
//                            // The token could not be validated.
//                        } else {
//                            // The current user is now set to user.
//                            [[PFUser currentUser] fetch];
//                            NSLog(@"%@", [PFUser currentUser]);
//                        }
//                    }];
                }
                else {
                    [PFUser logInWithUsernameInBackground:self.emailField.text password:@"password"];
                }
            }
        }];
    }
}

- (IBAction)logInButton:(UIButton *)sender
{
//    if ([segue.identifier isEqualToString:@"login"]) {
//    PFQuery *userQuery = [PFUser query];
//    [userQuery whereKey:@"username" equalTo:self.emailField.text];
//    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            if ([objects count] == 0) {
//                PFUser *user = [PFUser user];
//                user.username = self.emailField.text;
//                user.password = @"password";
//                user[@"name"] = self.nameField.text;
//                [user signUpInBackground];
//            }
//        } else {
//            [PFUser logInWithUsernameInBackground:self.emailField.text password:@"password"];
//        }
//    }];
//     [PFUser logInWithUsernameInBackground:self.emailField.text password:@"password"
//                                          block:^(PFUser *user, NSError *error) {
//                                                  if (user) {
//              AppDelegate *appDelegateTemp = [[UIApplication sharedApplication]delegate];
//              appDelegateTemp.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
//                                                          
//                                                          // Do stuff after successful login.
//                                        } else {
//                                            // The login failed. Check error to see why.
//                                        }
//                                    }];
//}
//    }
//    [PFUser logInWithUsernameInBackground:self.emailField.text password:@"password"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
