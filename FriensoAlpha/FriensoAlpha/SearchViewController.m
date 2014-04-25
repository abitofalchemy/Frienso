//
//  SearchViewController.m
//  Geolocations
//
//  Created by Héctor Ramos on 8/16/12.
//

#import <Parse/Parse.h>

#import "SearchViewController.h"
#import "CircleOverlay.h"
#import "GeoPointAnnotation.h"
#import "GeoQueryAnnotation.h"
#import "CoreFriends.h"
#import "FriensoAppDelegate.h"


enum PinAnnotationTypeTag {
    PinAnnotationTypeTagGeoPoint = 0,
    PinAnnotationTypeTagGeoQuery = 1
};

@interface SearchViewController ()
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, assign) CLLocationDistance radius;
@property (nonatomic, strong) CircleOverlay *targetOverlay;
@end

@implementation SearchViewController
@synthesize locationManager = _locationManager;


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName,
      [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:18.0], NSFontAttributeName,nil]];
    self.title = @"LOCATE FRIENDS";
    [self.locationManager startUpdatingLocation];
    [self setInitialLocation:self.locationManager.location];

    self.mapView.region = MKCoordinateRegionMake(self.location.coordinate, MKCoordinateSpanMake(0.05f, 0.05f));
    [self configureOverlay];
}

-(void) fetchCurrentLocationForUser:(NSString *) coreFriendObjectId {
    /** fetchCurrentLocationForUser
        coreFriendObjectId: objectId in Parse User class
     
        the connection has to be done via the phone nbr.
     
     **/
    //NSLog(@"fetchCurrentLocationForUser: %@", coreFriendObjectId);
    
    PFQuery *query = [PFUser query];
    [query getObjectInBackgroundWithId:coreFriendObjectId
                                 block:^(PFObject *object, NSError *error)
    {
        if (!error) {
            NSLog(@"%@, %@", (NSString *)[object valueForKey:@"email"], (PFGeoPoint *)[object valueForKey:@"currentLocation"]);
            [self updateCoreFriendEntity:(NSString *)[object valueForKey:@"email"]
                            withLocation:(PFGeoPoint *)[object valueForKey:@"currentLocation"]];
            GeoPointAnnotation *geoPointAnnotation = [[GeoPointAnnotation alloc] initWithObject:object];
            [self.mapView addAnnotation:geoPointAnnotation];

        } else
            NSLog(@"Error: %@ %@", error, [error userInfo]); // Log details of the failure
    }];
    
    
//    [query whereKey:@"user" equalTo:coreFriendObjectId];
//    //PFQuery *query = [PFQuery queryWithClassName:@"User"];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            // The find succeeded.
//            NSLog(@"Successfully retrieved %ld scores.", objects.count);
//            // Do something with the found objects
//            for (PFObject *object in objects) {
//                NSLog(@"%@", object.objectId);
//            }
//        } else {
//
//            NSLog(@"Error: %@ %@", error, [error userInfo]); // Log details of the failure
//        }
//    }];
    //    PFQuery *query = [PFQuery queryWithClassName:@"User"];
//    [query whereKey:@"objectId" equalTo:coreFriendObjectId];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            // The find succeeded.
//            NSLog(@"Successfully retrieved %ld scores.", objects.count);
//            // Do something with the found objects
//            for (PFObject *object in objects) {
//                NSLog(@"%@", object.objectId);
//            }
//        } else {
//            // Log details of the failure
//            NSLog(@"Error: %@ %@", error, [error userInfo]);
//        }
//    }];
    
}
#pragma mark - Update CoreData with currentLocation
- (NSManagedObjectContext *) managedObjectContext{
    
    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
    
}

-(void) updateCoreFriendEntity:(NSString *)friendEmail
                  withLocation:(PFGeoPoint *)friendCurrentLoc
{
    // NOT WORKING!!
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity  = [NSEntityDescription entityForName:@"CoreFriends"
                                               inManagedObjectContext:[self managedObjectContext]];
    
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"coreEmail like %@",@"nd.edu"];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest
                                                                         error:&error];
    if (fetchedObjects == nil) {
        // Handle the error.
        NSLog(@"Handle the error: %@", error);
    } else {
        for (NSManagedObject *object in fetchedObjects) {
            
            NSLog(@"%@", object);
            
        }
    }
}

#pragma mark - MasterViewController

/**
 Return a location manager -- create one if necessary.
 */
- (CLLocationManager *)locationManager {
	
    if (_locationManager != nil) {
		return _locationManager;
	}
	//NSLog(@"[1]");
	_locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    _locationManager.delegate = self;
    //_locationManager.purpose = @"Your current location is used to demonstrate PFGeoPoint and Geo Queries.";
	
	return _locationManager;
}
#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString *GeoPointAnnotationIdentifier = @"RedPinAnnotation";
    static NSString *GeoQueryAnnotationIdentifier = @"PurplePinAnnotation";
    
    if ([annotation isKindOfClass:[GeoQueryAnnotation class]]) {
        MKPinAnnotationView *annotationView =
        (MKPinAnnotationView *)[mapView
                                dequeueReusableAnnotationViewWithIdentifier:GeoQueryAnnotationIdentifier];
        
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc]
                              initWithAnnotation:annotation
                              reuseIdentifier:GeoQueryAnnotationIdentifier];
            annotationView.tag = PinAnnotationTypeTagGeoQuery;
            annotationView.canShowCallout = YES;
            annotationView.pinColor = MKPinAnnotationColorPurple;
            annotationView.animatesDrop = NO;
            annotationView.draggable = YES;
        }
        
        return annotationView;
    } else if ([annotation isKindOfClass:[GeoPointAnnotation class]]) {
        MKPinAnnotationView *annotationView =
        (MKPinAnnotationView *)[mapView
                                dequeueReusableAnnotationViewWithIdentifier:GeoPointAnnotationIdentifier];
        
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc]
                              initWithAnnotation:annotation
                              reuseIdentifier:GeoPointAnnotationIdentifier];
            annotationView.tag = PinAnnotationTypeTagGeoPoint;
            annotationView.canShowCallout = YES;
            annotationView.pinColor = MKPinAnnotationColorRed;
            annotationView.animatesDrop = YES;
            annotationView.draggable = NO;
        }
        
        return annotationView;
    } 
    
    return nil;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    static NSString *CircleOverlayIdentifier = @"Circle";
    
    if ([overlay isKindOfClass:[CircleOverlay class]]) {
        CircleOverlay *circleOverlay = (CircleOverlay *)overlay;

        MKCircleView *annotationView =
        (MKCircleView *)[mapView dequeueReusableAnnotationViewWithIdentifier:CircleOverlayIdentifier];
        
        if (!annotationView) {
            MKCircle *circle = [MKCircle
                                circleWithCenterCoordinate:circleOverlay.coordinate
                                radius:circleOverlay.radius];
            annotationView = [[MKCircleView alloc] initWithCircle:circle];
        }

        if (overlay == self.targetOverlay) {
            annotationView.fillColor = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.3f];
            annotationView.strokeColor = [UIColor redColor];
            annotationView.lineWidth = 1.0f;
        } else {
            annotationView.fillColor = [UIColor colorWithWhite:0.3f alpha:0.3f];
            annotationView.strokeColor = [UIColor purpleColor];
            annotationView.lineWidth = 2.0f;
        }
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    if (![view isKindOfClass:[MKPinAnnotationView class]] || view.tag != PinAnnotationTypeTagGeoQuery) {
        return;
    }
    
    if (MKAnnotationViewDragStateStarting == newState) {
        [self.mapView removeOverlays:self.mapView.overlays];
    } else if (MKAnnotationViewDragStateNone == newState && MKAnnotationViewDragStateEnding == oldState) {
        MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView *)view;
        GeoQueryAnnotation *geoQueryAnnotation = (GeoQueryAnnotation *)pinAnnotationView.annotation;
        self.location = [[CLLocation alloc] initWithLatitude:geoQueryAnnotation.coordinate.latitude longitude:geoQueryAnnotation.coordinate.longitude];
        [self configureOverlay];
    }
}


#pragma mark - SearchViewController

- (void)setInitialLocation:(CLLocation *)aLocation {
    self.location = aLocation;
    self.radius = 1000;
    //NSLog(@"%.2f,%.2f",self.location.coordinate.latitude, self.location.coordinate.longitude);
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
            NSNumber *lat = [NSNumber numberWithDouble:geoPoint.latitude];
            NSNumber *lon = [NSNumber numberWithDouble:geoPoint.longitude];
            NSDictionary *userLocation=@{@"lat":lat,@"long":lon};
            
            [[NSUserDefaults standardUserDefaults] setObject:userLocation forKey:@"userLocation"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
            [[PFUser currentUser] saveInBackground];
        }
    }];
}


#pragma mark - ()

- (IBAction)sliderDidTouchUp:(UISlider *)aSlider {
    if (self.targetOverlay) {
        [self.mapView removeOverlay:self.targetOverlay];
    }

    [self configureOverlay];
}

- (IBAction)sliderValueChanged:(UISlider *)aSlider {
    self.radius = aSlider.value;
    
    if (self.targetOverlay) {
        [self.mapView removeOverlay:self.targetOverlay];
    }

    self.targetOverlay = [[CircleOverlay alloc] initWithCoordinate:self.location.coordinate radius:self.radius];
    [self.mapView addOverlay:self.targetOverlay];
}

- (void)configureOverlay {
    if (self.location) {
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView removeOverlays:self.mapView.overlays];
        
        CircleOverlay *overlay = [[CircleOverlay alloc] initWithCoordinate:self.location.coordinate radius:self.radius];
        [self.mapView addOverlay:overlay];
        
        GeoQueryAnnotation *annotation = [[GeoQueryAnnotation alloc] initWithCoordinate:self.location.coordinate radius:self.radius];
        [self.mapView addAnnotation:annotation];
        
        [self updateLocations];
    }
}

- (void)updateLocations {
    // Get geopoints for coreF
    NSDictionary *retrievedCoreFriendsDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"CoreFriendsContactInfoDicKey"];
    
    if ( [retrievedCoreFriendsDictionary count] > 0) {
        NSArray *connectionKeyArray =  [[NSArray alloc]
                                        initWithArray:[retrievedCoreFriendsDictionary allValues]];
        
        for (NSString *pNumber in connectionKeyArray) {
            //NSLog(@"CoreF contact: %@", pNumber);
            PFQuery *query = [PFQuery queryWithClassName:@"UserConnection"];
            NSRange substrRange = NSMakeRange(pNumber.length-10, 10);
            [query whereKey:@"userNumber" containsString:[pNumber substringWithRange:substrRange]];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
             {
                 if (!error) { // The find succeeded.
                     for (PFObject *object in objects) { // Do something w/ found objects
                         //NSLog(@"%@", object);
                         //NSLog(@"%@", [[object valueForKey:@"user"] objectId]);
                         [self fetchCurrentLocationForUser:[[object valueForKey:@"user"] objectId]];
                     }
                 } else {
                     // Log details of the failure
                     NSLog(@"Error: %@ %@", error, [error userInfo]);
                 }
             }];
            
            
            
            
            
        }
    }

    /*CGFloat kilometers = self.radius/1000.0f;

    
    
    PFQuery *query = [PFQuery queryWithClassName:@"Location"];
    [query setLimit:1000];
    [query whereKey:@"location"
       nearGeoPoint:[PFGeoPoint geoPointWithLatitude:self.location.coordinate.latitude
                                           longitude:self.location.coordinate.longitude]
   withinKilometers:kilometers];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //NSLog(@"%ld", (unsigned long)[objects count]);
            
            for (PFObject *object in objects) {
                GeoPointAnnotation *geoPointAnnotation = [[GeoPointAnnotation alloc]
                                                          initWithObject:object];
                // NSLog(@"%.2f,%.2f", geoPointAnnotation.coordinate.latitude,
                //                    geoPointAnnotation.coordinate.longitude);
     
                
                NSLog(@"user %@", [object valueForKey:@"user"]);
                [self.mapView addAnnotation:geoPointAnnotation];
            }
        }
    }];
     */
}

@end
