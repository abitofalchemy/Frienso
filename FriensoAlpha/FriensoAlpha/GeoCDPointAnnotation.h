//
//  GeoCDPointAnnotation.h
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 5/26/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface GeoCDPointAnnotation : NSObject <MKAnnotation>

- (id)initWithObject:(NSArray *)geoArray;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;


@end
