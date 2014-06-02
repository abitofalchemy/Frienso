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
#import <Parse/Parse.h>


@implementation CloudUsrEvnts
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
            [userEvent setObject:@"watch" forKey:@"alertType"];
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

@end
