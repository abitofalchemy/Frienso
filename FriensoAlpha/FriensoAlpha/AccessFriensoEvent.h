//
//  AccessFriensoEvent.h
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 7/11/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccessFriensoEvent : NSObject

@property (nonatomic, copy, readonly) NSString *alertType;

- (id)initWithAlertType:(NSString*)alertType;

@end
