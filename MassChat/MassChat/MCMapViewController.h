//
//  MCMapViewController.h
//  MassChat
//
//  Created by Yu Sun on 8/17/14.
//  Copyright (c) 2014 sunny. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCMapViewController : UIViewController <TopBarDelegate, MKMapViewDelegate>

@property (strong, nonatomic) TopBar * topBar;
@property (strong, nonatomic) MKMapView *mapView;

@end
