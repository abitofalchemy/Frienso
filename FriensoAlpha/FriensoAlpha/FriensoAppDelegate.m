//
//  FriensoAppDelegate.m
//  FriensoAlpha
//
//  Created by Sal Aguinaga on 2/26/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
/** https://help.github.com/articles/fork-a-repo
 **
 ** */

#import "FriensoAppDelegate.h"
#import <Parse/Parse.h>
#import "FriensoEvent.h"
#import "CoreFriends.h"
#import "FriensoViewController.h"
#import <Crashlytics/Crashlytics.h>

@implementation FriensoAppDelegate
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel   = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Frienso Parse account
    [Parse setApplicationId:@"ocxutehzKxd4EvmeODaNDl8AwJPYajzTK06QYkzZ"
                  clientKey:@"G70qPOHHCFiUFUwBqbUJvqb2Fel8BrxcjBjntQEc"];
    [Crashlytics startWithAPIKey:@"a6e275099418fb75d38d9f45e6bb9819bc259bf5"];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Override point for customization after application launch.
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    //NSLog(@"My token is: %@", deviceToken);
    NSString *dToken = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    dToken = [dToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //Create subscription channels for the user: this includes channels for Frienso updates
    // TBD: Only add the last 10 digits in the number - add this check
    // TBD: only add the channel if it exists, duplicate channel creation needs to be investigated
    // Only subscribe to channels if the currentuser is not null
    //The globals channel will be used for all Frienso related alerts and messages
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser)
    {
        NSString* userPhoneNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhone"];
        //Channels have to start with a string, we will use "Ph" here
        NSString *myString = @"Ph";
        NSString *personalizedChannelNumber = [myString stringByAppendingString:userPhoneNumber];
        //NSLog(@"channel Name for this user is %@", personalizedChannelNumber);
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation setDeviceTokenFromData:deviceToken];
        currentInstallation.channels = @[@"global", @"ndDOTedu", personalizedChannelNumber];
        [currentInstallation saveInBackground];
        
    } else
        NSLog(@"No current User set for Push Notifications");
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    NSLog(@"Received a JSON object from Parse"); /*********** TAKE ACTION ****/
    if([userInfo objectForKey:@"group"]!=NULL) {
        NSString *myMessage = [NSString stringWithFormat:@"From %@", [userInfo objectForKey:@"group"]];
        //NSLog(@"Group Sending Message %@",[userInfo objectForKey:@"group"]);
        
        /*
         UINavigationController *navigationController = (UINavigationController*)_window.rootViewController;
        FriensoViewController *rootVC = (FriensoViewController*)[navigationController.viewControllers  objectAtIndex:0];
        [rootVC configureOverlay];
        */
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"eventReqPN"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Friend Request"
                                                        message:myMessage
                                                       delegate:self
                                              cancelButtonTitle:@"Accept"
                                              otherButtonTitles:@"Reject", nil];
        alert.tag = 101;
        [alert show];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FriensoAlphaCoreDataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"FriensoAlphaCoreDataModel.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}
#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(void) flushDatabase{
    [_managedObjectContext lock];
    NSArray *stores = [_persistentStoreCoordinator persistentStores];
    for(NSPersistentStore *store in stores) {
        [_persistentStoreCoordinator removePersistentStore:store error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
    }
    [_managedObjectContext unlock];
    _managedObjectModel    = nil;
    _managedObjectContext  = nil;
    _persistentStoreCoordinator = nil;
}
@end
