//
//  FriensoEvent.h
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 5/3/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Parse/Parse.h>


@interface FriensoEvent : NSManagedObject

@property (nonatomic, retain) NSString * eventCategory;
@property (nonatomic, retain) NSString * eventContact;
@property (nonatomic, retain) NSDate   * eventCreated;
@property (nonatomic, retain) NSString * eventLocation;
@property (nonatomic, retain) NSDate   * eventModified;
@property (nonatomic, retain) NSString * eventSubtitle;
@property (nonatomic, retain) NSString * eventTitle;
@property (nonatomic, retain) NSString * eventObjId;
@property (nonatomic, retain) NSString * eventImage;
@property (nonatomic, retain) NSNumber * eventPriority;

@end
