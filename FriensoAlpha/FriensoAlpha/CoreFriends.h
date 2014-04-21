//
//  CoreFriends.h
//  FriensoAlpha
//
//  Created by Sal Aguinaga on 3/1/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CoreFriends : NSManagedObject

@property (nonatomic, retain) NSString * coreFirstName;
@property (nonatomic, retain) NSString * coreLastName;
@property (nonatomic, retain) NSString * coreNickName;
@property (nonatomic, retain) NSString * corePhone;
@property (nonatomic, retain) NSString * coreEmail;
@property (nonatomic, retain) NSString * coreLocation;
@property (nonatomic, retain) NSDate * coreModified;

@end
