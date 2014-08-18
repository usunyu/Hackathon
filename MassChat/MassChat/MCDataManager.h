//
//  MCDataManager.h
//  MassChat
//
//  Created by Yu Sun on 8/17/14.
//  Copyright (c) 2014 sunny. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCDataManager : NSObject

@property (nonatomic, strong) NSMutableArray *checkinArray;

+ (instancetype)shared;

@end
