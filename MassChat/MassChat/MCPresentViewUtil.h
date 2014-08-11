//
//  MCPresentViewUtil.h
//  MassChat
//
//  Created by Yu Sun on 8/10/14.
//  Copyright (c) 2014 sunny. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCPresentViewUtil : NSObject

+ (void) present:(UIViewController *)mainController ViewController:(UIViewController *)viewController;
+ (void) dismissViewController:(UIViewController *)mainController;

+ (void) present:(UIViewController *)mainController ViewController:(UIViewController *)viewController withPushDirection: (NSString *) direction;
+ (void) dismiss:(UIViewController *)mainController ViewControllerWithPushDirection:(NSString *) direction;

@end
