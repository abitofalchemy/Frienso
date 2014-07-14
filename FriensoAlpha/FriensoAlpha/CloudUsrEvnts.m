//
//  CloudUsrEvnts.m
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 6/2/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "CloudUsrEvnts.h"
#import "FriensoAppDelegate.h"
#import "FriensoEvent.h"


@implementation CloudUsrEvnts
- (id)initWithAlertType:(NSString*)alertType
{
    self = [super init];
    if (self)
    {
        _alertType = alertType;
    }
    return self;
}
- (id)initWithAlertType:(NSString*)alertType eventStartDateTime:(NSDate *)startDateTime
{
    self = [super init];
    if (self)
    {
        _alertType = alertType;
        _startDateTime = startDateTime;
    }
    return self;
}
//-(NSArray *) ongoingAlertsCheck {
//    PFQuery *query = [PFQuery queryWithClassName:@"UserEvent"];
//    [query whereKey:@"eventActive" equalTo:[PFUser currentUser]];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
//            
//            return objects;
//        } else {
//            // Did not find any UserStats for the current user
//            NSLog(@"Error: %@", error);
//            
//        }
//    }];
//
//    
//}
- (void) isUserInMy2WatchList:(PFUser *)friensoUser
{
    PFQuery *sentToQuery = [PFQuery queryWithClassName:@"TrackRequest"];
    [sentToQuery whereKey:@"SenderPh" equalTo:[friensoUser valueForKey:@"phoneNumber"]];
    [sentToQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *trackRequest in objects) {
                if ([[trackRequest valueForKey:@"status"] isEqualToString:@"accepted"]) {
                    NSLog(@"Accepted request from: %@", [trackRequest valueForKey:@"SenderPh"] );
                }
            }
        } else {
            // Did not find any TrackRequest for the user, so we need to create it.
            NSLog(@"trackReques Error: %@", error);
        }
    }];
}
- (void) trackingUserEvent:(PFObject*) userEventObjId
                withStatus:(NSString*) status
                 trackedBy:(PFUser  *) friensoUser
{
//    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhone"]);
    // update the cloud-store for pfuser with new state; subqueries should be on the same Class
//    PFQuery *query = [PFQuery queryWithClassName:@"TrackRequest"];
//    [query whereKey:@"SenderPh" equalTo:[cloudUser objectForKey:@"phoneNumber"]];
//    [query whereKey:@"RecipientPh" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:@"userPhone"]];
//    PFQuery *sentByQuery = [PFQuery queryWithClassName:@"TrackRequest"];
//    [sentByQuery whereKey:@"SenderPh" equalTo:[cloudUser objectForKey:@"phoneNumber"]];
    /** Parse/Frienso/UserEventTracking Class
     ** This class tracks who has reviewed and taken action on a userEventRequest
     **         status: is the action will be either: accepted or rejected
     **    userEventId: is a pointer to the UserEvent record
     ** reviewedByUser: is the friend that reviewed the request and took action on it
     ** */
    
    PFObject *requestTrack = [PFObject objectWithClassName:@"UserEventTracking" ];
    [requestTrack setObject:userEventObjId forKey:@"userEventId"];
    [requestTrack setObject:status forKey:@"status"];
    [requestTrack setObject:friensoUser forKey:@"reviewedByUser"];
    [requestTrack saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded)
            NSLog(@"Error saving event tracking info: %@", error);
    }];
    
}

-(void) setPersonalEvent
{
    
//    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"watchObjId"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
-(BOOL) activeAlertCheck {
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"alertDic"];
    if (dic != NULL)
        return YES;
    else
        return NO;
}
-(void) sendNotificationsToCoreCircle{
    NSDictionary *dic =[[NSUserDefaults standardUserDefaults]
                        dictionaryForKey:@"CoreFriendsContactInfoDicKey"];
    
    for (NSString *coreFriendPh in [dic allValues]) {
        NSString *minPhString = [self stripStringOfUnwantedChars:coreFriendPh];
        NSString *personalizedChannelNumber =[NSString stringWithFormat:@"Ph%@",
                                              [minPhString substringFromIndex:minPhString.length-10]];
        if(!([minPhString rangeOfString:@"3394087"].location == NSNotFound))
        {
            NSLog(@"Phone Number for this friend is: %@", personalizedChannelNumber);
            PFPush *push = [[PFPush alloc] init];
            
            // Be sure to use the plural 'setChannels' if you are sending to more than one channel.
            [push setChannel:personalizedChannelNumber];
            NSString *coreRqstHeader = @"WATCH REQUEST FROM: ";
            NSString *coreFrndMsg = [coreRqstHeader stringByAppendingString:[[PFUser currentUser] objectForKey:@"username"]];
            
            [push setMessage:coreFrndMsg];
            [push sendPushInBackground];
        }
    }
}
-(void) sendToCloud
{
    PFObject *userEvent = [PFObject objectWithClassName:@"UserEvent" ];
    [userEvent setObject:self.alertType forKey:@"eventType"];
    [userEvent setObject:[NSNumber numberWithBool:YES] forKey:@"eventActive"];
    [userEvent setObject:[PFUser currentUser] forKey:@"friensoUser"];
    [userEvent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            
            
            NSLog(@"! error adding userEvent to cloud-store: %@", error);
        } else {
            NSLog(@"Event logged  on cloud-store");
            if ([self.alertType isEqualToString:@"watchMe"])
                [[NSUserDefaults standardUserDefaults] setObject:userEvent.objectId forKey:@"watchObjId"];
            else {
                [[NSUserDefaults standardUserDefaults] setObject:userEvent.objectId forKey:@"helpObjId"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }];
    /**
    PFQuery *query = [PFQuery queryWithClassName:@"UserEvent"];
    [query whereKey:@"friensoUser" equalTo:[PFUser currentUser]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * userEvent, NSError *error) {
        if (!error) {
            // Found UserStats
            //[userEvent setObject:@"watch" forKey:@"alertType"];
            [userEvent setObject:[NSNumber numberWithBool:YES] forKey:@"eventActive"];
            [userEvent saveInBackground];
        } else {
            // Did not find any UserStats for the current user
            NSLog(@"Error: %@", error);
            PFObject *userEvent = [PFObject objectWithClassName:@"UserEvent" ];
            [userEvent setObject:@"watch" forKey:@"eventType"];
            [userEvent setObject:[NSNumber numberWithBool:YES] forKey:@"eventActive"];
            [userEvent setObject:[self nextHourDate:_startDateTime]  forKey:@"endDateTime"];
            [userEvent setObject:[PFUser currentUser] forKey:@"friensoUser"];
            [userEvent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Saved event for user:%@", [PFUser currentUser].email);
                } else {
                    NSLog(@"%@", error);
                }
            }];
        }
    }];
     ***/
}
- (void) disableEvent
{

    PFQuery *query = [PFQuery queryWithClassName:@"UserEvent"];
    if ([self.alertType isEqualToString:@"watchMe"])
        [query whereKey:@"objectId" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:@"watchObjId"]];
    else
        [query whereKey:@"objectId" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:@"helpObjId"]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * userEvent, NSError *error) {
        if (!error) {
            // Found UserStats
            [userEvent setObject:[NSNumber numberWithBool:NO] forKey:@"eventActive"];
            //NSLog(@"%@", userEvent.objectId);
            // Save
            [userEvent saveInBackground];
            NSLog(@"... disabled WatchMe");
        }
    }];
}
- (NSDate*) nextHourDate:(NSDate*)inDate{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components: NSEraCalendarUnit|NSYearCalendarUnit| NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit fromDate: inDate];
    [comps setHour: [comps hour]+1]; // Here you may also need to check if it's the last hour of the day
    return [calendar dateFromComponents:comps];
}
- (void) logEventOnFriensoEvent:(NSString*)objId
{
    NSLog(@"--------- logEvent to FriensoEvent: %@", objId);
    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    
    FriensoEvent *firstFriensoEvent = [NSEntityDescription insertNewObjectForEntityForName:@"FriensoEvent"
                                                                    inManagedObjectContext:managedObjectContext];
    /** What the right way to manage geolocation points between coredata and parse.com? **/
    if (firstFriensoEvent != nil){
        
        firstFriensoEvent.eventTitle     = [NSString stringWithFormat:@"%@ event triggered!", self.alertType];
        //firstFriensoEvent.eventLocation  = [NSString stringWithFormat:@"%f,%f", self.coordinate.latitude, self.coordinate.longitude];
        firstFriensoEvent.eventContact   = [[NSUserDefaults standardUserDefaults] objectForKey:@"adminID"];
        firstFriensoEvent.eventObjId     = objId;
        firstFriensoEvent.eventCreated   = [NSDate date];
        firstFriensoEvent.eventModified  = [NSDate date];
        
        NSError *savingError = nil;
        if([managedObjectContext save:&savingError]) {
            NSLog(@"%@ event stored locally",self.alertType);
        } else { NSLog(@"Failed to save the context. Error = %@", savingError); }
    } else {
        NSLog(@"Failed to create a new event.");
    }
    
}
#pragma mark
#pragma mark - Helper methods
- (NSString *) stripStringOfUnwantedChars:(NSString *)phoneNumber {
   NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
   return cleanedString;
}
@end
