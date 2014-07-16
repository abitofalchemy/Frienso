//
//  FriensoViewController.h
//  FriensoAlpha
//
//  Created by Sal Aguinaga on 2/26/14.
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


@interface FriensoViewController : UIViewController <NSFetchedResultsControllerDelegate,
UITableViewDelegate,UITableViewDataSource,MKMapViewDelegate,CLLocationManagerDelegate,UIAlertViewDelegate,UIScrollViewDelegate,MFMessageComposeViewControllerDelegate>
{
    UISwitch       *helpMeNowSwitch;
}
//@property (nonatomic,strong) UISwitch       *helpMeNowSwitch;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic) UIButton       *helpMeNowBtn;
//@property (nonatomic,weak) UISwitch       *helpMeNowSwitch;

//- (void) loginCurrentUserToCloudStore;
- (void) setInitialLocation:(CLLocation *)aLocation;
- (void) actionAddFriensoUserLocation:(PFGeoPoint *)geoPoint forUser:(NSString *)friend;
- (void) configureOverlay;
//- (void) helpMeNowSwitchAction:(UISwitch*)sender;

@end
