//
//  CloudLocationServices.m
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 8/5/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "CloudLocationServices.h"

@interface CloudLocationServices()
@property (nonatomic, strong) PFObject *object;
@end

@implementation CloudLocationServices
@synthesize coordinate = _coordinate;
@synthesize distance = _distance;


#pragma mark - Initialization

//- (id)initWithObject:(PFObject *)aObject {
- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate {
    self = [super init];
    if (self) {
        //_object = aObject;
        _coordinate = aCoordinate;
//
//        
//        PFGeoPoint *geoPoint = self.object[@"currentLocation"];
        [self estimateDistance];
    }
    return self;
}
- (void)estimateDistance {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    _title = @"Me";
    
    _subtitle = [NSString stringWithFormat:@"Center: (%@, %@) Radius: %@ m",
                 [numberFormatter stringFromNumber:[NSNumber numberWithFloat:_coordinate.latitude]],
                 [numberFormatter stringFromNumber:[NSNumber numberWithFloat:_coordinate.longitude]],
                 [numberFormatter stringFromNumber:[NSNumber numberWithInt:_radius]]
                 ];
}

@end
