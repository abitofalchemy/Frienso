//
//  HomeViewController.h
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 5/29/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/NSFetchedResultsController.h>
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ABALoginTVC.h"

@interface HomeViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDelegate,UITableViewDataSource, MKMapViewDelegate,CLLocationManagerDelegate,UIScrollViewDelegate>

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, strong) MKMapView *mapView;

- (void) setInitialLocation:(CLLocation *)aLocation;
- (void) actionAddFriensoUserLocation:(PFGeoPoint *)geoPoint forUser:(NSString *)friend;

@end