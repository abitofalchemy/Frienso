//
//  CoreFriends.h
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 5/5/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CoreFriends : NSManagedObject

@property (nonatomic, retain) NSString * coreEmail;
@property (nonatomic, retain) NSString * coreFirstName;
@property (nonatomic, retain) NSString * coreLastName;
@property (nonatomic, retain) NSString * coreLocation;
@property (nonatomic, retain) NSString * coreNickName;
@property (nonatomic, retain) NSString * corePhone;
@property (nonatomic, retain) NSString * coreType;
@property (nonatomic, retain) NSString * coreObjId;
@property (nonatomic, retain) NSString * coreTitle;
@property (nonatomic, retain) NSDate * coreCreated;
@property (nonatomic, retain) NSDate * coreModified;

@end
