//
//  CloudUsrEvnts.h
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 6/2/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloudUsrEvnts : NSObject

@property (nonatomic, copy, readonly) NSString *alertType, *friensoUser;//, *genre, *coverUrl, *year;
@property (nonatomic, copy, readonly) NSDate   *startDateTime;//, *genre, *coverUrl, *year;


- (id)initWithAlertType:(NSString*)alertType eventStartDateTime:(NSDate *)startDateTime;
- (void) setPersonalEvent;
- (void) sendToCloud;
- (void) disableEvent;
- (BOOL) activeAlertCheck;
//- (NSArray *) ongoingAlertsCheck;

@end