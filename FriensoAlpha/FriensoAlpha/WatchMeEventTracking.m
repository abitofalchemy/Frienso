//
//  WatchMeEventTracking.m
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 5/24/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//  http://blog.parse.com/2013/03/22/stay-classy-objective-c-introducing-native-subclasses-for-parse-objects/
//  https://parse.com/questions/updating-a-field-without-retrieving-the-object-first
//
//


#import "WatchMeEventTracking.h"
#import "FriensoAppDelegate.h"
#import "FriensoEvent.h"
#import <Parse/Parse.h>


@implementation WatchMeEventTracking
- (id)initWithEventType:(NSString*)eventType eventStartDateTime:(NSDate *)startDateTime
{
    self = [super init];
    if (self)
    {
        _eventType = eventType;
        _startDateTime = startDateTime;
    }
    return self;
}

-(void) setPersonalEvent
{
    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *managedObjectContext =
    appDelegate.managedObjectContext;
    FriensoEvent *friensoEvent = [NSEntityDescription insertNewObjectForEntityForName:@"FriensoEvent"
                                                                    inManagedObjectContext:managedObjectContext];
    
    if (friensoEvent != nil)
    {
        
        friensoEvent.eventTitle     = @"Watch me!";
        friensoEvent.eventSubtitle  = @"loction";
        friensoEvent.eventLocation  = @"";
        friensoEvent.eventCategory  = @"watch";
        friensoEvent.eventCreated   = _startDateTime;
        friensoEvent.eventModified  = [NSDate date];
        //firstFriensoEvent.eventImage     =
        friensoEvent.eventPriority  = [NSNumber numberWithInteger:3];
        
        NSError *savingError = nil;
        if([managedObjectContext save:&savingError]) {
            NSLog(@"Successfully saved WATCH event");
        } else
            NSLog(@"Failed to save the context. Error = %@", savingError);
    } else {
        NSLog(@"Failed to create a new event.");
    }
}

-(void) sendToCloud
{
//    PFObject *userEvent = [PFObject objectWithClassName:@"UserEvent" ];
//    [userEvent setObject:@"watch" forKey:@"eventType"];
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
            //[userEvent setObject:@"watch" forKey:@"eventType"];
            [userEvent setObject:[NSNumber numberWithBool:YES] forKey:@"eventActive"];
            //[userEvent setObject:[self nextHourDate:_startDateTime]  forKey:@"endDateTime"];
            // Save
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
    PFQuery *query = [PFQuery queryWithClassName:@"UserEvent"];
    [query whereKey:@"friensoUser" equalTo:[PFUser currentUser]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * userEvent, NSError *error) {
        if (!error) {
            // Found UserStats
            //[userEvent setObject:@"watch" forKey:@"eventType"];
            [userEvent setObject:[NSNumber numberWithBool:NO] forKey:@"eventActive"];
            //[userEvent setObject:[self nextHourDate:_startDateTime]  forKey:@"endDateTime"];
            // Save
            [userEvent saveInBackground];
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
