//
//  MCSettingController.m
//  MassChat
//
//  Created by Yu Sun on 8/10/14.
//  Copyright (c) 2014 sunny. All rights reserved.
//

#import "MCSettingController.h"

@interface MCSettingController ()

@end

@implementation MCSettingController

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
    
    // TopBar
    _topBar = [[TopBar alloc]init];
    _topBar.title = @"Settings";
//    _topBar.tintColor = tintColor;
    _topBar.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    _topBar.delegate = self;
    
    // just hide left button for now
    _topBar.leftBtn.hidden = YES;
    // change right button icon
    [_topBar.rightBtn setImage:[UIImage imageNamed:@"Next.png"] forState:UIControlStateNormal];
}

- (void) viewWillAppear:(BOOL)animated
{
    
    // Add views here, or they may create problems when launching in landscape
    
    [self.view addSubview:_topBar];
}

#pragma mark CLEAN UP

- (void) removeFromParentViewController {
    
    [_topBar removeFromSuperview];
    _topBar = nil;
    
    [super removeFromParentViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Custom UIViewControllers Present

- (void) dismissViewControllerWithPushDirection:(NSString *) direction {
    
    [CATransaction begin];
    
    CATransition *transition = [CATransition animation];
//    transition.type = kCATransitionFade;
    transition.type = kCATransitionPush;
    transition.subtype = direction;
    transition.duration = 0.25f;
    transition.fillMode = kCAFillModeForwards;
    transition.removedOnCompletion = YES;
    
    [[UIApplication sharedApplication].keyWindow.layer addAnimation:transition forKey:@"transition"];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [CATransaction setCompletionBlock: ^ {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(transition.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^ {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        });
    }];
    
    [self dismissViewControllerAnimated:NO completion:NULL];
    
    [CATransaction commit];
    
}

#pragma mark TOP BAR DELEGATE

- (void) topLeftPressed {
    // Currently Inactive
}

- (void) topMiddlePressed {
    // Currently Inactive
}

- (void) topRightPressed {
    // Currently Inactive
    [self dismissViewControllerWithPushDirection:@"fromRight"];
}

@end
