//
//  MCMapPin.h
//  MassChat
//
//  Created by Yu Sun on 8/17/14.
//  Copyright (c) 2014 sunny. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCMapPin : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

- (id)initWithCoordinate: (CLLocationCoordinate2D) _coordinate;

@end
