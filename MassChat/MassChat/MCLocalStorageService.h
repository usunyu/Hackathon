//
//  MCLocalStorageService.h
//  MassChat
//
//  Created by Yu Sun on 8/9/14.
//  Copyright (c) 2014 sunny. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCLocalStorageService : NSObject

@property (nonatomic, strong) QBUUser *currentUser;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, readonly) NSDictionary *usersAsDictionary;

+ (instancetype)shared;

@end
