//
//  MCMapViewController.m
//  MassChat
//
//  Created by Yu Sun on 8/17/14.
//  Copyright (c) 2014 sunny. All rights reserved.
//

#import "MCMapViewController.h"
#import "MCMapPin.h"
#import "MCDataManager.h"

@interface MCMapViewController ()

@end

@implementation MCMapViewController

@synthesize mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    // add pins to map
    if([mapView.annotations count] <= 1){
        for(QBLGeoData *geodata in [MCDataManager shared].checkinArray){
            CLLocationCoordinate2D coord = {.latitude= geodata.latitude, .longitude= geodata.longitude};
            MCMapPin *pin = [[MCMapPin alloc] initWithCoordinate:coord];
            pin.subtitle = geodata.status;
            pin.title = geodata.user.login ? geodata.user.login : geodata.user.email;
            [mapView addAnnotation:pin];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    mapView.showsUserLocation = YES;
    mapView.mapType = MKMapTypeHybrid;
    mapView.delegate = self;
    [self.view addSubview:mapView];
    
    _topBar = [[TopBar alloc]init];
//    _topBar.title = @"Chat Everywhere";
    _topBar.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    _topBar.delegate = self;
    
    [self.view addSubview:_topBar];
}

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    CLLocationCoordinate2D location;
    location.latitude = aUserLocation.coordinate.latitude;
    location.longitude = aUserLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [aMapView setRegion:region animated:YES];
}

-(void) topLeftPressed {
    [MCPresentViewUtil dismissViewController:self];
}

- (void) topRightPressed {
    
}

- (void) topMiddlePressed {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
