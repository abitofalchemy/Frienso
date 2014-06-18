//
//  CloudEntityContacts.m
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 6/16/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "CloudEntityContacts.h"
#import <Parse/Parse.h>
#import "FriensoAppDelegate.h"
#import "CoreFriends.h"


@implementation CloudEntityContacts

- (id)initWithCampusDomain:(NSString*)eduDomain
{
    self = [super init];
    if (self)
    {
//        _serviceName    = serviceName;
//        _phoneNumber    = phoneNumber;
//        _contactType    = contactType;
    }
    return self;
}

-(void) fetchEmergencyContacts:(NSString *)contactType {
    PFQuery *resQuery = [PFQuery queryWithClassName:@"Resources"];
    [resQuery whereKey:@"categoryType" equalTo:contactType];
    [resQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *emergencyContact in objects) {
                //NSLog(@"Contact: %@",[emergencyContact objectForKey:@"resource"]);
                [self cacheEmergencyContact2CDCoreFriends:emergencyContact];
            }
        } else {
            // Did not find any TrackRequest for the user, so we need to create it.
            NSLog(@"trackReques Error: %@", error);
        }
    }];
}
#pragma mark - CoreData Methods
-(void) cacheEmergencyContact2CDCoreFriends:(PFObject *)contactInfo
{
    
    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;

    CoreFriends *cFriends = nil;
    cFriends = [NSEntityDescription insertNewObjectForEntityForName:@"CoreFriends"
                                                 inManagedObjectContext:managedObjectContext];
    if (cFriends != nil){
        cFriends.coreFirstName = [contactInfo objectForKey:@"resource"];
        cFriends.coreLastName  = nil;
        cFriends.coreNickName  = nil;
        cFriends.corePhone     = [contactInfo objectForKey:@"phonenumber"];
        cFriends.coreModified  = [NSDate date];
        cFriends.coreType      = @"Emergency";
        cFriends.coreObjId     = contactInfo.objectId;
        
        NSError *savingError = nil;
        if ([managedObjectContext save:&savingError]){
            NSLog(@"Added Emergency Contact: %@",[contactInfo objectForKey:@"resource"]);
        } else {
            NSLog(@"Failed to save emergency contact.");
        }
        
    } else {
        NSLog(@"Failed to create the new person object.");
    }
}
@end
