//
//  MTLocalStorageService.h
//  MassTalk
//
//  Created by Yu Sun on 8/8/14.
//  Copyright (c) 2014 sunny. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTLocalStorageService : NSObject

@property (nonatomic, strong) QBUUser *currentUser;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, readonly) NSDictionary *usersAsDictionary;

+ (instancetype)shared;

@end
