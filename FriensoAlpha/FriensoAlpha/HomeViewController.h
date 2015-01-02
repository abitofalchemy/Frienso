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

@property (nonatomic,strong) CLLocationManager* locationManager;
//
@property int seconds;
@property float distance;
@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) NSTimer *timer;
//
@property (nonatomic,strong) MKMapView*         mapView;
/*@property (nonatomic, strong) UIButton*         helpMeNowBtn;*/

- (void) setInitialLocation:(CLLocation *)aLocation;
- (void) actionAddFriensoUserLocation:(PFGeoPoint *)geoPoint forUser:(NSString *)friend;
/*****************************
 *  I want to simplify (improve significantly) 
 *  this method:
 - (void) configureOverlay;
 *****************************/
- (void) checkUsersStatus;
- (void) watchMeSwitchEnabled:(UISwitch*) sender;
@end
