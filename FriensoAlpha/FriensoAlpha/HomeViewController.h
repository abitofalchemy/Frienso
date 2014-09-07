//
//  HomeViewController.h
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 8/16/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/NSFetchedResultsController.h>
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MessageUI.h>
#import "ABALoginTVC.h"
#import "TrackingFriendButton.h"
#import "CloudEntityContacts.h"

@interface HomeViewController : UIViewController <NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate,UITableViewDelegate,UITableViewDataSource,MKMapViewDelegate,CLLocationManagerDelegate,UIAlertViewDelegate,UIScrollViewDelegate,MFMessageComposeViewControllerDelegate>

@property (nonatomic,retain) CLLocationManager* locationManager;
@property (nonatomic,strong) MKMapView*         mapView;
//@property (nonatomic, strong) UIButton*         helpMeNowBtn;

- (void) setInitialLocation:(CLLocation *)aLocation;
- (void) actionAddFriensoUserLocation:(PFGeoPoint *)geoPoint forUser:(NSString *)friend;
- (void) configureOverlay;

@end