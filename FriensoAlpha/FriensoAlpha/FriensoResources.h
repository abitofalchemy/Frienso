//
//  FriensoResources.h
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 4/23/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FriensoResources : NSManagedObject

@property (nonatomic, retain) NSDate * resCreated;
@property (nonatomic, retain) NSDate * resUpdated;
@property (nonatomic, retain) NSString * resTitle;
@property (nonatomic, retain) NSString * resDetail;
@property (nonatomic, retain) NSString * resUrlLink;
@property (nonatomic, retain) NSString * resContactPhone;
@property (nonatomic, retain) NSString * resInstitution;

@end
