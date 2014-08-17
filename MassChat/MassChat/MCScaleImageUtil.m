//
//  MCScaleImageUtil.m
//  MassChat
//
//  Created by Yu Sun on 8/17/14.
//  Copyright (c) 2014 sunny. All rights reserved.
//

#import "MCScaleImageUtil.h"

@implementation MCScaleImageUtil

+ (UIImage*) scale:(UIImage *)originImage toSize:(CGSize)size {
    // Create a bitmap graphics context
    // This will also set it as the current context
    UIGraphicsBeginImageContext(size);
    
    // Draw the scaled image in the current context
    [originImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    // Create a new image from current context
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Pop the current context from the stack
    UIGraphicsEndImageContext();
    
    return scaledImage;
    
}

@end
