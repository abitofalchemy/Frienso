//
//  FRCoreDataParse.m
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 4/23/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "FRCoreDataParse.h"
#import <Parse/Parse.h>
#import "CoreFriends.h"
#import "FriensoAppDelegate.h"

@implementation FRCoreDataParse

- (NSManagedObjectContext *) managedObjectContext{
    
    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
    
}
- (void) showCoreFriendsEntityData {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CoreFriends"
                                              inManagedObjectContext:[self managedObjectContext]];
    
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error.
    } else
        for (NSManagedObject *mObject in fetchedObjects) {
            NSLog(@"%@,%@, %@",
                  [mObject valueForKey:@"coreFirstName"],
                  [mObject valueForKey:@"corePhone"],
                  [mObject valueForKey:@"coreLocation"]
                  );
        }
}
- (void) updateThisUserLocation
{
    NSLog(@"updating my location");
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            NSLog(@"I am currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
            NSNumber *lat = [NSNumber numberWithDouble:geoPoint.latitude];
            NSNumber *lon = [NSNumber numberWithDouble:geoPoint.longitude];
            NSDictionary *userLocation=@{@"lat":lat,@"long":lon};
            
            [[NSUserDefaults standardUserDefaults] setObject:userLocation forKey:@"userLocation"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        
            [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
            [[PFUser currentUser] saveInBackground];
        } else NSLog(@"An error occurred: %@", error.localizedDescription);
    }];
}
- (void) updateCoreFriendsLocation
{
    NSLog(@"  Updating coreFriends location ...");
    NSDictionary *coreFriendsDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"CoreFriendsContactInfoDicKey"];
    
    if ( [coreFriendsDic count] > 0) {
       for (NSString *pNumber in [coreFriendsDic allValues])
       {
           //NSLog(@" cf phn %@", pNumber);
           
           PFQuery *query = [PFUser query];
           [query   whereKey:@"phoneNumber" containsString:[self stripStringOfUnwantedChars:pNumber]];
           [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
           {
               if ( !error && objects.count > 0) {
                   for (PFUser* friensoUser in objects) {
                      [self fetchCurrentLocationForUser:friensoUser.objectId
                                            includePhone:[self stripStringOfUnwantedChars:pNumber]];
                   }
               } else
                   NSLog(@"%@", error ? error.localizedDescription : @"  ... No objects?");
               
           }];
           
       } // ends for
    } // ends if
}
- (void) updateCoreDataFriendsLocationFor:(NSString*)friendPhoneNbr withDistance:(CLLocationDistance)distance
{
    
}

- (void) updateCoreFriendsCurrentLocation:(NSString *)corePhone {
    PFQuery *query = [PFQuery queryWithClassName:@"UserConnection"];
    NSRange substrRange = NSMakeRange(corePhone.length-10, 10);
    [query whereKey:@"userNumber" containsString:[corePhone substringWithRange:substrRange]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
         if (!error) { // The find succeeded.
             for (PFObject *object in objects) { // Do something w/ found objects
                 //NSLog(@"%@", object);
                 //NSLog(@"%@", [[object valueForKey:@"user"] objectId]);
                 [self fetchCurrentLocationForUser:[[object valueForKey:@"user"] objectId]
                                      includePhone:corePhone];
             }
         } else
             NSLog(@"Error: %@ %@", error, [error userInfo]);  // Log details of the failure
         
     }];
}

-(void) fetchCurrentLocationForUser:(NSString *)coreFriendObjectId
                       includePhone:(NSString *)fPhoneStr
{
    /** 16Jun14:SA
     **
     ** */
    PFQuery *query = [PFUser query];
    [query getObjectInBackgroundWithId:coreFriendObjectId
                                 block:^(PFObject *object, NSError *error)
     {
         if (!error) {
             PFGeoPoint *friendLocation   = (PFGeoPoint *)[object valueForKey:@"currentLocation"];
             NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
             
             NSEntityDescription *entity  = [NSEntityDescription entityForName:@"CoreFriends"
                                                       inManagedObjectContext:[self managedObjectContext]];
             
             [fetchRequest setEntity:entity];
             NSPredicate *predicate = [NSPredicate predicateWithFormat:@"corePhone endswith %@",fPhoneStr];
             [fetchRequest setPredicate:predicate];
             
             NSError *error;
             NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest
                                                                                  error:&error];
             if (fetchedObjects == nil) {
                 // Handle the error.
                 NSLog(@"%@", error);
             } else {
                 //NSLog(@"from coredata: %@",fetchedObjects);
                 for (NSManagedObject *mObject in fetchedObjects) {
                     
                     CLLocation *locA = [[CLLocation alloc] initWithLatitude:friendLocation.latitude longitude:friendLocation.longitude];
                     NSDictionary *userLocDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"userLocation"];
                     CLLocation *locB = [[CLLocation alloc] initWithLatitude:(CLLocationDegrees)[[userLocDic objectForKey:@"lat"] doubleValue]
                                                                   longitude:(CLLocationDegrees)[[userLocDic objectForKey:@"long"] doubleValue]];
                     
                     CLLocationDistance distance = [locA distanceFromLocation:locB] * 0.000621371;
                     //NSLog(@"%@", [NSString stringWithFormat:@"%.2f meters away from you", distance]);
                     //[mObject setValue:[NSString stringWithFormat:@"%.2f meters away from you", distance] forKey:@"coreLocation"];
                     [mObject setValue:[NSString stringWithFormat:@"%.1f",distance]
                                forKey:@"coreLocation"];
                     
                     NSError *savingError = nil;
                     
                     if ([[self managedObjectContext] save:&savingError]){
                         NSLog(@"Successfully saved loc info for %@",(NSString *)[object valueForKey:@"email"]);
                     } else {
                         NSLog(@"Failed to save the managed object context.");
                     }
                 }//ends for
            }
         } else
             NSLog(@"Error: %@ %@", error, [error userInfo]); // Log details of the failure
     }];
}
#pragma mark - Helper Methods
-(NSString *) stripStringOfUnwantedChars:(NSString *)phoneNumber {
    NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    
    //    return  [dirtyContactName stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"-()"]];
    return cleanedString;
}


@end
