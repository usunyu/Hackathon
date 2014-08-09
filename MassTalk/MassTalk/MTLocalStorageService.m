//
//  MTLocalStorageService.m
//  MassTalk
//
//  Created by Yu Sun on 8/8/14.
//  Copyright (c) 2014 sunny. All rights reserved.
//

#import "MTLocalStorageService.h"

@implementation MTLocalStorageService

+ (instancetype)shared
{
	static id instance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		instance = [[self alloc] init];
	});
	
	return instance;
}

- (void)setUsers:(NSArray *)users
{
    _users = users;
    
    NSMutableDictionary *__usersAsDictionary = [NSMutableDictionary dictionary];
    for(QBUUser *user in users){
        [__usersAsDictionary setObject:user forKey:@(user.ID)];
    }
    
    _usersAsDictionary = [__usersAsDictionary copy];
}

@end
