//
//  CloudEntityContacts.h
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 6/16/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloudEntityContacts : NSObject

@property (nonatomic, copy, readonly) NSString *serviceName, *phoneNumber, *contactType;

- (id)initWithCampusDomain:(NSString*)eduDomain;
- (void) fetchEmergencyContacts:(NSString*)contactType;

@end
