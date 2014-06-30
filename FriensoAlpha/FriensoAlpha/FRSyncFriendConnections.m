//
//  FRSyncFriendConnections.m
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 5/14/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
/*  Update CoreData Entity
 *  http://stackoverflow.com/questions/10571786/how-to-update-existing-object-in-core-data/10572134#10572134
 *
 **/

#import "FRSyncFriendConnections.h"
#import "FriensoAppDelegate.h"
#import "CoreFriends.h"
#import <Parse/Parse.h>

@interface FRSyncFriendConnections()
@property (nonatomic,strong) NSMutableArray *uWatchArray;       // array of PFUser objects
@property (nonatomic,strong) NSMutableArray *phNbrCachedArr;    // numbers already in the CoreGroup
@property (nonatomic,strong) NSMutableArray *uWatchGrpNbrsArr;  // array of their phone numbers

@property (nonatomic) NSInteger uWatchCount;

@end

@implementation FRSyncFriendConnections

- (id) init
{
    /* first initialize the base class */
    self = [super init];
    _uWatchGrpNbrsArr = [[NSMutableArray alloc] init];
    _uWatchArray      = [[NSMutableArray alloc] init];
    _phNbrCachedArr   = [[NSMutableArray alloc] init];

    /* finally return the object */
    return self;
}
//- (void) listWatchCoreFriendsForTableView:(UITableView *)table_view
- (void) listWatchCoreFriends
{
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
                            //NSLog(@"with connection to me: %@ with ph: %@",friensoUser.username, [friensoUser objectForKey:@"phoneNumber"]);
                            //[_uWatchArray addObject:friensoUser];
                            //[self addWatchingCoreFriend:friensoUser ifNotInMyCoreCircle:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"CoreFriendsContactInfoDicKey"]];
                            NSDictionary *dic = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"CoreFriendsContactInfoDicKey"];
                            NSInteger j = 0;
                            for (NSString *coreCirclePh in [dic allValues]) {
                                NSString *clnStr = [self stripStringOfUnwantedChars:coreCirclePh];
                                NSString *str = [clnStr substringFromIndex:(clnStr.length - 10)];
                                
                                if ( ![str isEqualToString:[friensoUser objectForKey:@"phoneNumber"] ] ){
                                    //NSLog(@"%@<>%@, %@",str,[friensoUser objectForKey:@"phoneNumber"], friensoUser.username );
                                    j++;
                                }
                                if (j==3) {
                                    //NSLog(@"%@<>%@, %@",str,[friensoUser objectForKey:@"phoneNumber"], friensoUser.username );
                                    [self addFriensoUserToCDCoreFriends:friensoUser]; //[self addFriensoUserToCDCoreFriends:friensoUser andReloadFRCfor:table_view];
                                }
                            }
                        }
                    }//ends for loop
                }
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);  // Log details of the failure
        }
    }];
    
}
- (void) syncUWatchToCoreFriends
{
    NSLog(@"**** syncUWatchToCoreFriends ****");
    
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
                            //NSLog(@"has conn. to me: %@",friensoUser.username);
                            [_uWatchArray addObject:friensoUser];
                            
                            // Check if user user is unique in my Friends list
                            if ([self isFriendUnique:friensoUser]){
                                NSLog(@"Add to friends list: %@", friensoUser.username);
                                [self addFriendToCoreFriends:friensoUser];
                            }
                        }
                    }//ends for loop
                }
            }//ends for
            _uWatchCount    = [_uWatchArray count];
//            for (PFUser *extFriend in _uWatchArray){
//                
//                //[self fetchPhoneNbrForThoseIWatch:extFriend  withCount:_uWatchCount];
//                
//                _uWatchCount--;
//            }
            
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);  // Log details of the failure
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
//- (void) addFriensoUserToCDCoreFriends:(PFUser *)friend2Watch andReloadFRCfor:(UITableView *)table_view{
- (void) addFriensoUserToCDCoreFriends:(PFUser *)friend2Watch
{
//    NSMutableDictionary *locDicCoreFriends = [[NSUserDefaults standardUserDefaults] objectForKey:@"CoreFriendsContactInfoDicKey"];
//    NSArray *coreFriendsPhoneNbrs = [NSMutableArray arrayWithArray:[locDicCoreFriends allValues]];
    
    
    
    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    // First check to see if the objectId already exists
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"CoreFriends"
                                                         inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPredicate:[NSPredicate predicateWithFormat:@"coreObjId like %@",friend2Watch.objectId]];//[pfObj objectForKey:@"resObjId"]]];
    [request setEntity:entityDescription];
    
    BOOL unique = YES;
    NSError  *error;
    NSArray *items = [managedObjectContext executeFetchRequest:request error:&error];
    if(items.count > 0){
        unique = NO;
    } //else { NSLog(@" the object is unique"); }
    
    if (unique) {
        /*********/
        CoreFriends  *coreFriendsHndlr = [NSEntityDescription insertNewObjectForEntityForName:@"CoreFriends"
                                                                       inManagedObjectContext:managedObjectContext];
        if (coreFriendsHndlr != nil)
        {
            
            coreFriendsHndlr.coreNickName  = [[friend2Watch.username substringToIndex:2] uppercaseString];
            coreFriendsHndlr.coreFirstName = [[friend2Watch.username substringToIndex:2] uppercaseString];
            coreFriendsHndlr.coreEmail     = friend2Watch.username;
            coreFriendsHndlr.corePhone     = [friend2Watch objectForKey:@"phoneNumber"];
            coreFriendsHndlr.coreObjId     = friend2Watch.objectId;
            coreFriendsHndlr.coreModified  = [NSDate date];
            coreFriendsHndlr.coreCreated   = [NSDate date];
            coreFriendsHndlr.coreType      = @"oCore Friends";
            
            NSError *savingError = nil;
            if([managedObjectContext save:&savingError]) {
                NSLog(@"Successfully cached the resource");
            } else
                NSLog(@"Failed to save the context. Error = %@", savingError);
            
            
        } else {
            NSLog(@"Failed to create a new event.");
        }
        /*********/
    } else NSLog(@"");//! Parse event is not unique");
    
}


- (void) fetchPhoneNbrForThoseIWatch:(PFUser *)friend2Watch withCount:(NSInteger)currentCount {
    
    //NSLog(@"****    fetchPhoneNbrForThoseIWatch");
    
    NSMutableDictionary *locDicCoreFriends = [[NSUserDefaults standardUserDefaults] objectForKey:@"CoreFriendsContactInfoDicKey"];
    NSArray *coreFriendsPhoneNbrs = [NSMutableArray arrayWithArray:[locDicCoreFriends allValues]];
    
    
    
    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    // First check to see if the objectId already exists
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"CoreFriends"
                                                         inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPredicate:[NSPredicate predicateWithFormat:@"coreObjId like %@",friend2Watch.objectId]];//[pfObj objectForKey:@"resObjId"]]];
    [request setEntity:entityDescription];
    
    BOOL unique = YES;
    NSError  *error;
    NSArray *items = [managedObjectContext executeFetchRequest:request error:&error];
    if(items.count > 0){
        unique = NO;
    } //else { NSLog(@" the object is unique"); }
    
    if (unique) {
        /*********/
        PFQuery *newQuery = [PFQuery queryWithClassName:@"UserConnection"];
        [newQuery whereKey:@"user" equalTo:friend2Watch];
        [newQuery findObjectsInBackgroundWithBlock:^(NSArray *connObjects, NSError *error)
        {
            if (!error) {
                //  NSLog (@"%d, %@", (int)[connObjects count], connObjects);
                for (PFObject *newObject in connObjects) {
                    NSString *str1 = [newObject objectForKey:@"userNumber"];
                    NSString *str1a = [str1 substringWithRange:NSMakeRange(str1.length-10, 10)];
                    
                    NSDictionary *dic = [[NSDictionary alloc] initWithObjects:@[friend2Watch] forKeys:@[str1a]];
                    [_uWatchGrpNbrsArr addObject:dic]; // watchFriend pfuser: phone number
                    //NSLog(@"comparing: %@ to:",str1a);
                    for (NSString *coreNbr in coreFriendsPhoneNbrs ) {
                        NSString *coreNbrStr = [coreNbr substringWithRange:NSMakeRange(coreNbr.length-10, 10)];
                        if ([str1a longLongValue] == [coreNbrStr longLongValue]){
                            [_phNbrCachedArr addObject:coreNbr]; // these numbers have to be ommitted from CoreFriends
                        }
//                        else
//                            NSLog(@"Unique friend to add under Watching coreFriend category: %@", str1a  );
                    } // ends coreNbr loop
                    //NSLog(@"[0]");
                } // ends other loop
                if ( _uWatchGrpNbrsArr.count == [_uWatchArray count] ) // Finished checking the uWatch ph nbrs against the coreFriends nbrs
                    [self insertUniqueUWatchFriends];
             } else {
                 // Log details of the failure
                 NSLog(@"Error: %@ %@", error, [error userInfo]);
             }
        }];// ends 2nd query
        /*********/
    } else NSLog(@"");//! Parse event is not unique");

}

-(void) updateCoreFriendsWhereCorePhone:(NSString *)phoneNumber withObjectId:(NSString *)coreObjectId{

    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    // First check to see if the objectId already exists
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"CoreFriends"
                                                         inManagedObjectContext:managedObjectContext];

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPredicate:[NSPredicate predicateWithFormat:@"corePhone like %@",phoneNumber]];//[pfObj objectForKey:@"resObjId"]]];
    [request setEntity:entityDescription];

    NSError  *error;
    NSArray *items = [managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"[items count]: %ld", (unsigned long)[items count]);
    CoreFriends  *coreFriend = [items objectAtIndex:0];
    coreFriend.coreObjId = coreObjectId;
    
    NSError *savingError = nil;
    if(![managedObjectContext save:&savingError])
    /*
     NSLog(@"Successfully updated coreObjId.");
    } else
    */
        NSLog(@"Failed to save the context. Error = %@", savingError);
    
}
- (void) insertUniqueUWatchFriends {
    NSLog(@"****    insertUniqueUWatchFriends");

    for (NSDictionary *watchFriendDic in _uWatchGrpNbrsArr) {
        NSArray *watchFriendPhNbr = [watchFriendDic allKeys];
        NSString *watchStr = [watchFriendPhNbr objectAtIndex:0];
        NSString *removeObject = nil;
        for (NSString *coreFriendPhNbr in _phNbrCachedArr) {

            if ([[watchStr substringFromIndex:watchStr.length-10] isEqualToString:[coreFriendPhNbr substringFromIndex:coreFriendPhNbr.length-10]])
            {    // add contact to CoreFriends
                //
                //NSLog(@"match: %@: %@",watchStr,coreFriendPhNbr);
                removeObject = coreFriendPhNbr;
                break;
            } else {
                PFUser *watchUserObj = [watchFriendDic valueForKey:watchStr];
                NSLog(@"new contact:%@,%@,%@",watchStr, watchUserObj.username, watchUserObj.objectId);
                FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
                CoreFriends  *coreFriendsHndlr = [NSEntityDescription insertNewObjectForEntityForName:@"CoreFriends"
                                                                            inManagedObjectContext:managedObjectContext];
                if (coreFriendsHndlr != nil)
                {

                    coreFriendsHndlr.coreNickName  =  [[watchUserObj.username substringToIndex:2] uppercaseString];
                    coreFriendsHndlr.coreEmail     = watchUserObj.username;
                    coreFriendsHndlr.corePhone     = watchStr;
                    coreFriendsHndlr.coreObjId     = watchUserObj.objectId;
                    coreFriendsHndlr.coreModified  = [NSDate date];
                    coreFriendsHndlr.coreCreated   = [NSDate date];
                    coreFriendsHndlr.coreType      = @"OCore Friends";

                    NSError *savingError = nil;
                    if([managedObjectContext save:&savingError]) {
                         NSLog(@"Successfully cached the resource");
                    } else
                         NSLog(@"Failed to save the context. Error = %@", savingError);


                 } else {
                     NSLog(@"Failed to create a new event.");
                 }
            }
        }
        if ( removeObject != nil)
            [_phNbrCachedArr removeObject:removeObject];
    }
}
-(void) addWatchingCoreFriend:(PFUser *)friensoUser ifNotInMyCoreCircle:(NSDictionary *)coreCircleDic
{
    for (NSString *coreCirclePh in [coreCircleDic allValues]) {
        if (![coreCirclePh isEqualToString:[friensoUser objectForKey:@"phoneNumber"]]) // if not in corecircle
            NSLog(@"User %@ with Ph: %@ not in coreCircle", friensoUser.username, [friensoUser objectForKey:@"phoneNumber"]);
    }
    
}
-(BOOL) isFriendUnique:(PFUser *)friensoUser{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"CoreFriendsContactInfoDicKey"];
    NSArray *cfPhoneNumbers =  [dic allValues];
    NSArray *cfStrippedPhNbrs = [self stripPhoneNumbers:cfPhoneNumbers];
    
//    if ([friensoUser.username isEqualToString:@"nyadav@nd.edu"])
//        NSLog(@"is %@ in [%@]", [friensoUser objectForKey:@"phoneNumber"], cfStrippedPhNbrs);
    
    if([cfStrippedPhNbrs containsObject:[friensoUser objectForKey:@"phoneNumber"]])
        return NO;
    else
        return YES;
}
-(NSArray*) stripPhoneNumbers:(NSArray*) phoneNumbersArray {
    NSMutableArray *retArray = [NSMutableArray new];
    NSUInteger j = 0;
    for ( NSString *phNbr in phoneNumbersArray )
    {
        NSString *string =[self stripStringOfUnwantedChars:phNbr];
        [retArray insertObject:[string substringFromIndex:(string.length-10)] atIndex:j++];
    }
    return [NSArray arrayWithArray:retArray];
}
- (void) addFriendToCoreFriends:(PFUser*)friensoUser
{
    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    CoreFriends  *coreFriendsHndlr = [NSEntityDescription insertNewObjectForEntityForName:@"CoreFriends"
                                                                   inManagedObjectContext:managedObjectContext];
    if (coreFriendsHndlr != nil)
    {
        
        coreFriendsHndlr.coreNickName  = [[friensoUser.username substringToIndex:2] uppercaseString];
        coreFriendsHndlr.coreEmail     = friensoUser.username;
        coreFriendsHndlr.corePhone     = [friensoUser objectForKey:@"phoneNumber"];
        coreFriendsHndlr.coreObjId     = friensoUser.objectId;
        coreFriendsHndlr.coreModified  = [NSDate date];
        coreFriendsHndlr.coreCreated   = [NSDate date];
        coreFriendsHndlr.coreType      = @"oCore Friends";
        
        NSError *savingError = nil;
        if([managedObjectContext save:&savingError]) {
            NSLog(@"Successfully cached the resource");
        } else
            NSLog(@"Failed to save the context. Error = %@", savingError);
        
        
    } else {
        NSLog(@"Failed to create a new event.");
    }

}
@end
