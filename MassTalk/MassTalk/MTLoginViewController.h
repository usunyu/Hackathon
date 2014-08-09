//
//  MTLoginViewController.h
//  MassTalk
//
//  Created by Yu Sun on 8/8/14.
//  Copyright (c) 2014 sunny. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTLoginViewController : UIViewController <UITextFieldDelegate, QBActionStatusDelegate>

@property NSString *username;
@property NSString *password;

@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)loginButton:(UIButton *)sender;
- (IBAction)signupButton:(UIButton *)sender;

@end
