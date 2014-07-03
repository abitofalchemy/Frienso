//
//  GeoCDPointAnnotation.m
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 5/26/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "GeoCDPointAnnotation.h"

@interface GeoCDPointAnnotation()
@property (nonatomic, strong) NSArray *object;
@end

@implementation GeoCDPointAnnotation

#pragma mark - Initialization

- (id)initWithObject:(NSArray *)geoArray {
    self = [super init];
    if (self) {
        _object = geoArray;
        NSLog(@"GeoCDPointAnnotation");
        if ([geoArray count] > 3) {
            PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:[[geoArray objectAtIndex:1] doubleValue]
                                                          longitude:[[geoArray objectAtIndex:2] doubleValue]];
            [self setGeoPoint:geoPoint];
            //[self annotationView];
        }
        
    }
    return self;
}
- (MKAnnotationView *) annotationView
{
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"MyCustomAnnotation"];
    annotationView.enabled = YES;
    annotationView.canShowCallout = YES;
    annotationView.image = [UIImage imageNamed:@"profile-24.png"];
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    return annotationView;
}
//#pragma mark - MKAnnotation
//
//// Called when the annotation is dragged and dropped. We update the geoPoint with the new coordinates.
//- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
//    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:newCoordinate.latitude longitude:newCoordinate.longitude];
//    [self setGeoPoint:geoPoint];
//    [self.object setObject:geoPoint forKey:@"currentLocation"];
//    [self.object saveEventually:^(BOOL succeeded, NSError *error) {
//        if (succeeded) {
//            // Send a notification when this geopoint has been updated. MasterViewController will be listening for this notification, and will reload its data when this notification is received.
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"geoPointAnnotiationUpdated" object:self.object];
//        }
//    }];
//}


#pragma mark - ()

- (void)setGeoPoint:(PFGeoPoint *)geoPoint {
    _coordinate = CLLocationCoordinate2DMake(geoPoint.latitude,geoPoint.longitude);
    
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeStyle = NSDateFormatterMediumStyle;
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    }
    
    static NSNumberFormatter *numberFormatter = nil;
    if (numberFormatter == nil) {
        numberFormatter = [[NSNumberFormatter alloc] init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        numberFormatter.maximumFractionDigits = 3;
    }
    
    _title = [NSString stringWithFormat:@"%@",[self.object objectAtIndex:0]];
//    _subtitle = [NSString stringWithFormat:@"%@, %@", [numberFormatter stringFromNumber:[NSNumber numberWithDouble:geoPoint.latitude]],
//                 [numberFormatter stringFromNumber:[NSNumber numberWithDouble:geoPoint.longitude]]];
    _subtitle =[_object objectAtIndex:3];
}
@end
