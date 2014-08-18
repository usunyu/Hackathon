//
//  MCDataManager.m
//  MassChat
//
//  Created by Yu Sun on 8/17/14.
//  Copyright (c) 2014 sunny. All rights reserved.
//

#import "MCDataManager.h"

@implementation MCDataManager

@synthesize checkinArray;

+ (instancetype)shared
{
	static id instance_ = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		instance_ = [[self alloc] init];
	});
	
	return instance_;
}

@end
