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
    
    
    [MCPresentViewUtil dismissViewController:self];
    

//    [self autoLogin];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
