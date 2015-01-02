//
//  CloudUsrEvnts.h
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 6/2/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface CloudUsrEvnts : NSObject

@property (nonatomic, copy, readonly) NSString *alertType, *friensoUser;//, *genre, *coverUrl, *year;
@property (nonatomic, copy, readonly) NSDate   *startDateTime;//, *genre, *coverUrl, *year;

- (id)initWithAlertType:(NSString*)alertType;
- (id)initWithAlertType:(NSString*)alertType eventStartDateTime:(NSDate *)startDateTime;
- (void) setPersonalEvent;
- (void) sendToCloud;
- (void) sendNotificationsToCoreCircle;
- (void) disableEvent;
- (NSString*) checkWatchMeStatus;
- (BOOL) activeAlertCheck;
- (void) trackingUserEvent:(PFObject*) userEventObjId
                withStatus:(NSString*) status
                 trackedBy:(PFUser  *) parseUser;
- (void) isUserInMy2WatchList:(PFUser *)friensoUser;
- (void)cloudCheckForCircleEvents;

@end
