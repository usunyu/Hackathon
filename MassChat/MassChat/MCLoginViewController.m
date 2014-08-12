//
//  MCLoginViewController.m
//  MassChat
//
//  Created by Yu Sun on 8/10/14.
//  Copyright (c) 2014 sunny. All rights reserved.
//

#import "MCLoginViewController.h"

@interface MCLoginViewController ()

@end

@implementation MCLoginViewController

- (void) autoLogin
{
    // Log in auto for test
    _username = @"Sunny";
    _password = @"12345678";
    QBASessionCreationRequest *extendedAuthRequest = [QBASessionCreationRequest request];
    extendedAuthRequest.userLogin = _username;
    extendedAuthRequest.userPassword = _password;
    
	[QBAuth createSessionWithExtendedRequest:extendedAuthRequest delegate:self];
}

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
    // Do any additional setup after loading the view from its nib.
    
    self.tapLabel.textAlignment = NSTextAlignmentCenter;
    self.tapLabel.center = self.view.center;
    self.tapLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    
    self.tapLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.tapLabel.layer.borderWidth = 2.0;
    
    UITapGestureRecognizer * tap = [UITapGestureRecognizer new];
    [tap addTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
}

- (void) handleTap:(UITapGestureRecognizer *)tap {
    self.view.userInteractionEnabled = NO;
    
//    if (!self.chatController) self.chatController = [ChatController new];
//    self.chatController.delegate = self;
    
    self.loadLabel.text = @"Loading ...";
    
    [self autoLogin];
}

#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
- (void)completedWithResult:(Result *)result {
    // QuickBlox session creation  result
    if([result isKindOfClass:[QBAAuthSessionCreationResult class]]){
        // Success result
        if(result.success){
            
            QBAAuthSessionCreationResult *res = (QBAAuthSessionCreationResult *)result;
            
            // Save current user
            QBUUser *currentUser = [QBUUser user];
            currentUser.ID = res.session.userID;
            currentUser.login = _username;
            currentUser.password = _password;
            //
            [[MCLocalStorageService shared] setCurrentUser:currentUser];
            
            // show chat view
            self.loadLabel.text = nil;
            
            [MCPresentViewUtil dismissViewController:self];
        }else{
            NSString *errorMessage = [[result.errors description] stringByReplacingOccurrencesOfString:@"(" withString:@""];
            errorMessage = [errorMessage stringByReplacingOccurrencesOfString:@")" withString:@""];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errors" message:errorMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
