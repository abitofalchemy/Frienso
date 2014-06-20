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
- (void) trackRequestOfType:(NSString *)requestType
                    forUser:(PFUser *)cloudUser
                 withStatus:(NSString *)status
{
//    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhone"]);
    // update the cloud-store for pfuser with new state; subqueries should be on the same Class
//    PFQuery *query = [PFQuery queryWithClassName:@"TrackRequest"];
//    [query whereKey:@"SenderPh" equalTo:[cloudUser objectForKey:@"phoneNumber"]];
//    [query whereKey:@"RecipientPh" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:@"userPhone"]];
//    PFQuery *sentByQuery = [PFQuery queryWithClassName:@"TrackRequest"];
//    [sentByQuery whereKey:@"SenderPh" equalTo:[cloudUser objectForKey:@"phoneNumber"]];
    
    PFQuery *sentToQuery = [PFQuery queryWithClassName:@"TrackRequest"];
    [sentToQuery whereKey:@"RecipientPh" equalTo:[[NSUserDefaults standardUserDefaults] objectForKey:@"userPhone"]];
    
//    PFQuery *query = [PFQuery orQueryWithSubqueries:@[sentByQuery,sentToQuery]]; // query with multiple constraints
    [sentToQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // Found requestTrack
            //NSLog(@"requestType: %@, %@", objects, requestType);
            if (objects.count == 0) {
                PFObject *requestTrack = [PFObject objectWithClassName:@"TrackRequest" ];
                [requestTrack setObject:[cloudUser objectForKey:@"phoneNumber"] forKey:@"SenderPh"];
                [requestTrack setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userPhone"]
                                 forKey:@"RecipientPh"];
                [requestTrack setObject:status forKey:@"status"];
                [requestTrack setObject:requestType forKey:@"requestType"];
                [requestTrack saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"Tracking event record added");
                    } else {
                        NSLog(@"%@", error);
                    }
                }];
            } else {
                // find those that match the Sender
                for (PFObject *trackRequest in objects) {
                    if ([[trackRequest objectForKey:@"SenderPh"] isEqualToString:[cloudUser objectForKey:@"phoneNumber"]])
                    {    // update this trackRequest->'requestType'
                        //NSLog(@"%@", [trackRequest objectForKey:@"requestType"]);
                        [trackRequest setObject:status forKey:@"status"];
                        [trackRequest setObject:requestType forKey:@"requestType"];
                        [trackRequest saveInBackground];
                    }
                }
            }
//            [requestTrack setObject:status      forKey:@"status"];
//            [requestTrack setObject:requestType forKey:@"requestType"];
//            [requestTrack saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                if (succeeded) {
//                    NSLog(@"Tracking event record added");
//                } else {
//                    NSLog(@"Update failed! ... %@", error);
//                }
//            }];
        } else {
            // Did not find any TrackRequest for the user, so we need to create it.
            NSLog(@"trackReques Error: %@", error);
            
        }
    }];
}

-(void) setPersonalEvent
{
    NSDictionary *dic = [[NSDictionary alloc] initWithObjects:@[_alertType,_startDateTime,[self nextHourDate:_startDateTime]]
                                                      forKeys:@[@"alertType",@"startDateTime", @"endDateTime"]];
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"alertDic"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
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
    //    PFObject *userEvent = [PFObject objectWithClassName:@"UserEvent" ];
    //    [userEvent setObject:@"watch" forKey:@"alertType"];
    //    [userEvent setObject:[NSNumber numberWithBool:YES] forKey:@"eventActive"];
    //    [userEvent setObject:[self nextHourDate:_startDateTime]  forKey:@"endDateTime"];
    //    [userEvent setObject:[PFUser currentUser] forKey:@"friensoUser"];
    //    [userEvent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    //        if (succeeded) {
    //            NSLog(@"Saved event for user:%@", [PFUser currentUser].email);
    //        } else {
    //            NSLog(@"%@", error);
    //        }
    //    }];
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
}
- (void) disableEvent
{
    NSDictionary *dic = NULL;
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"alertDic"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserEvent"];
    [query whereKey:@"friensoUser" equalTo:[PFUser currentUser]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * userEvent, NSError *error) {
        if (!error) {
            // Found UserStats
            //[userEvent setObject:@"watch" forKey:@"alertType"];
            [userEvent setObject:[NSNumber numberWithBool:NO] forKey:@"eventActive"];
            //[userEvent setObject:[self nextHourDate:_startDateTime]  forKey:@"endDateTime"];
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
#pragma mark
#pragma mark - Helper methods
- (NSString *) stripStringOfUnwantedChars:(NSString *)phoneNumber {
   NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
   return cleanedString;
}
@end
