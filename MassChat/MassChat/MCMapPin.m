//
//  MCMapPin.m
//  MassChat
//
//  Created by Yu Sun on 8/17/14.
//  Copyright (c) 2014 sunny. All rights reserved.
//

#import "MCMapPin.h"

@implementation MCMapPin
@synthesize  coordinate;
@synthesize title, subtitle;

- (id)initWithCoordinate: (CLLocationCoordinate2D) _coordinate{
    self = [super init];
    if(self){
        self.coordinate = _coordinate;
    }
    
	return self;
}

@end
