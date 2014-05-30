//
//  WatchMeEventTracking.h
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 5/24/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <Parse/Parse.h>
//
//@interface UserEvents : PFObject<PFSubclassing>
//
//+ (NSString *)parseClassName;
//@property BOOL eventActive;
//@property (nonatomic,strong) PFUser *user;

@interface WatchMeEventTracking : NSObject

@property (nonatomic, copy, readonly) NSString *alertType, *friensoUser;//, *genre, *coverUrl, *year;
@property (nonatomic, copy, readonly) NSDate   *startDateTime;//, *genre, *coverUrl, *year;


- (id)initWithAlertType:(NSString*)alertType eventStartDateTime:(NSDate *)startDateTime;
- (void) setPersonalEvent;
- (void) sendToCloud;
- (void) disableEvent;
- (BOOL) activeAlertCheck;

@end

//initWithalertType: watchTrackMe
//userName:  currentUser
//startDateTime: now()

