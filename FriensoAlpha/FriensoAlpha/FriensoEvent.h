//
//  FriensoEvent.h
//  FriensoAlpha
//
//  Created by Sal Aguinaga on 2/26/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FriensoEvent : NSManagedObject
@property (nonatomic, retain) NSString * eventContact;
@property (nonatomic, retain) NSString * eventTitle;
@property (nonatomic, retain) NSString * eventSubtitle;
@property (nonatomic, retain) NSString * eventLocation;
@property (nonatomic, retain) NSDate * eventCreated;
@property (nonatomic, retain) NSDate * eventModified;

@end
