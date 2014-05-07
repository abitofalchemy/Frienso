//
//  SearchViewController.h
//  Geolocations
//
//  Created by Héctor Ramos on 8/16/12.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/NSFetchedResultsController.h>

@interface SearchViewController : UIViewController <MKMapViewDelegate,CLLocationManagerDelegate,NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UISlider *slider;

- (void)setInitialLocation:(CLLocation *)aLocation;
//- (void)setFrame:(CGRect)frame;//- (void) setText:(NSString *)paramText;


@end
