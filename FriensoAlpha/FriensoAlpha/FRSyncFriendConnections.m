//
//  FRSyncFriendConnections.m
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 5/14/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "FRSyncFriendConnections.h"
#import "FriensoAppDelegate.h"
#import "CoreFriends.h"
#import <Parse/Parse.h>

@implementation FRSyncFriendConnections

- (id) init
{
    /* first initialize the base class */
    self = [super init];

    /* finally return the object */
    return self;
}
- (void) syncUWatchToCoreFriends
{
    NSMutableArray *uWatchArray = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserCoreFriends"];
    [query includeKey:@"user"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {   // The find succeeded.
            for (PFObject *object in objects) {
                NSMutableDictionary *parseCoreFriendsDic = [object valueForKey:@"userCoreFriends"];
                PFUser   *friensoUser    = [object valueForKey:@"user"];
                //NSLog(@"users safety network: %@", friensoUser);
                NSString *rootPhNbrStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhone"];
                if ( parseCoreFriendsDic != NULL && friensoUser != NULL) {
                    
                    for (NSString *phone_nbr in [parseCoreFriendsDic allValues]){
                        if([[self stripStringOfUnwantedChars:phone_nbr] isEqualToString:rootPhNbrStr])
                        {
                            //NSLog(@"with connection to me: %@]",friensoUser.username);
                            [uWatchArray addObject:friensoUser.username];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self fetchPhoneNbrForThoseIWatch:friensoUser];
                            });

                        }
                    }//ends for loop
                }
            }//ends for
            printf("[ filtered those I am watching ]\n");
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }

    }];
}

#pragma mark - Helper Methods
- (NSString *) stripStringOfUnwantedChars:(NSString *)phoneNumber {
    NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    //    return  [dirtyContactName stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"-()"]];
    return cleanedString;
}

#pragma mark - Async actions
- (void) fetchPhoneNbrForThoseIWatch:(PFUser *)friend2Watch {
    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    // First check to see if the objectId already exists
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"CoreFriends"
                                                         inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    PFObject *pfObj = [self.objects objectAtIndex:indexPath.row];
    [request setPredicate:[NSPredicate predicateWithFormat:@"coreObjId like %@",friend2Watch.objectId]];//[pfObj objectForKey:@"resObjId"]]];
    //NSLog(@"ObjectId: %@, username:%@", friend2Watch.objectId, friend2Watch.username);
    [request setEntity:entityDescription];
    BOOL unique = YES;
    NSError  *error;
    NSArray *items = [managedObjectContext executeFetchRequest:request error:&error];
    if(items.count > 0){
        unique = NO;
    } else { NSLog(@" the object is unique"); }
    
    if (unique) {
        CoreFriends  *coreFResource = [NSEntityDescription insertNewObjectForEntityForName:@"CoreFriends"
                                                                    inManagedObjectContext:managedObjectContext];

        /*********/
        PFQuery *newQuery = [PFQuery queryWithClassName:@"UserConnection"];
        [newQuery whereKey:@"user" equalTo:friend2Watch];
        [newQuery findObjectsInBackgroundWithBlock:^(NSArray *connObjects, NSError *error)
         {
             if (!error) {
                 //NSLog(@"%d", (int)[connObjects count]);
                 for (PFObject *newObject in connObjects) {
                     //[self.watchingOverDic setObject:[newObject objectForKey:@"userNumber"] forKey:friend2Watch.username];
                     //[self.watchingPhoneArray addObject:[newObject objectForKey:@"userNumber"] ];
                     NSLog(@"userNumber: %@, %@", friend2Watch.username, [newObject objectForKey:@"userNumber"]);
                     
                     if (coreFResource != nil) {
                         
                         coreFResource.coreTitle = friend2Watch.username;
                         coreFResource.coreNickName = [friend2Watch.email substringToIndex:2];
                         coreFResource.corePhone = [newObject objectForKey:@"userNumber"];
                         coreFResource.coreObjId     = friend2Watch.objectId;
                         coreFResource.coreModified  = [NSDate date];
                         coreFResource.coreCreated   = [NSDate date];
                         coreFResource.coreType      = @"OnWatch";
                         
                         
                         NSError *savingError = nil;
                         if([managedObjectContext save:&savingError]) {
                             NSLog(@"Successfully cached the resource");
                         } else
                             NSLog(@"Failed to save the context. Error = %@", savingError);
                         
                         
                     } else {
                         NSLog(@"Failed to create a new event.");
                     }
                     
                 }
             } else {
                 // Log details of the failure
                 NSLog(@"Error: %@ %@", error, [error userInfo]);
             }
         }];// ends 2nd query
        /*********/
    } else NSLog(@"! Parse event is not unique");

}
@end
