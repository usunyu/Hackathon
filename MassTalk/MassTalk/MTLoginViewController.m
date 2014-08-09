//
//  MTLoginViewController.m
//  MassTalk
//
//  Created by Yu Sun on 8/8/14.
//  Copyright (c) 2014 sunny. All rights reserved.
//

#import "MTLoginViewController.h"

@implementation MTLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.passwordTextField.secureTextEntry = YES;
    
    // Log in auto
    _username = @"Sunny";
    _password = @"12345678";
    QBASessionCreationRequest *extendedAuthRequest = [QBASessionCreationRequest request];
    extendedAuthRequest.userLogin = _username;
    extendedAuthRequest.userPassword = _password;
    
	[QBAuth createSessionWithExtendedRequest:extendedAuthRequest delegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)loginButton:(UIButton *)sender
{
    _username = self.usernameTextField.text;
    _password = self.passwordTextField.text;
    
    QBASessionCreationRequest *extendedAuthRequest = [QBASessionCreationRequest request];
    extendedAuthRequest.userLogin = _username;
    extendedAuthRequest.userPassword = _password;

	[QBAuth createSessionWithExtendedRequest:extendedAuthRequest delegate:self];
}

- (IBAction)signupButton:(UIButton *)sender {
}

- (void)completedWithResult:(Result *)result{
    
    // QuickBlox session creation  result
    if([result isKindOfClass:[QBAAuthSessionCreationResult class]]){
        
        // Success result
        if(result.success){
            
            QBAAuthSessionCreationResult *res = (QBAAuthSessionCreationResult *)result;
            
            // Save current user
            //
            QBUUser *currentUser = [QBUUser user];
            currentUser.ID = res.session.userID;
            currentUser.login = _username;
            currentUser.password = _password;
            //
            [[MTLocalStorageService shared] setCurrentUser:currentUser];
            
            // Login to QuickBlox Chat
            //
            [[MTTalkServices instance] loginWithUser:currentUser completionBlock:^{
                
                // hide alert after delay
                double delayInSeconds = 1.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
            }];
            
        }else{
            NSString *errorMessage = [[result.errors description] stringByReplacingOccurrencesOfString:@"(" withString:@""];
            errorMessage = [errorMessage stringByReplacingOccurrencesOfString:@")" withString:@""];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errors"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles: nil];
            [alert show];
        }
    }
}

@end
