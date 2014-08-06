//
//  CloudLocationServices.h
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 8/5/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface CloudLocationServices : NSObject <MKAnnotation>
//- (id)initWithObject:(PFObject *)aObject;
- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *distance;
@end
