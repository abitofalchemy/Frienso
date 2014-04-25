//
//  FriensoQuickCircleVC.m
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 3/15/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "FriensoQuickCircleVC.h"
#import "FriensoAppDelegate.h"
#import "CoreFriends.h"
#import "FRCoreDataParse.h"
#import <Parse/Parse.h>

static NSString *coreFriendsCell = @"coreFriendsCell";


@interface FriensoQuickCircleVC ()
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *frc;

@end

@implementation FriensoQuickCircleVC
- (NSManagedObjectContext *) managedObjectContext{
    
    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Update this user's current location
    FRCoreDataParse *frCDPObject = [[FRCoreDataParse alloc] init];
    [frCDPObject updateThisUserLocation];
    
	//  Add new table view
    self.tableView = [[UITableView alloc] init];
    [self.tableView setFrame:CGRectMake(0, 0, self.view.bounds.size.width,
                                        self.view.bounds.size.height*0.70)];
    
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    [self.view addSubview:self.tableView];
    
    /* Create the fetch request first */
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]
                                    initWithEntityName:@"CoreFriends"];
    
    NSSortDescriptor *modifiedSort =
    [[NSSortDescriptor alloc] initWithKey:@"coreLastName"
                                ascending:NO];
    
    NSSortDescriptor *eventTitleSort =
    [[NSSortDescriptor alloc] initWithKey:@"coreFirstName"
                                ascending:NO];
    
    fetchRequest.sortDescriptors = @[modifiedSort, eventTitleSort];
    
    self.frc =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:[self managedObjectContext]
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
    
    self.frc.delegate      = self;
    NSError *fetchingError = nil;
    if ([self.frc performFetch:&fetchingError]){
        NSLog(@"Successfully fetched coreCircle.");
    } else {
        NSLog(@"Failed to fetch.");
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return 1;
    return [[self.frc sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.frc.sections[section];
    //NSLog(@"%lu",sectionInfo.numberOfObjects);
    return sectionInfo.numberOfObjects;
    
}
- (UITableViewCell *)tableView:(UITableView *)theTableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:coreFriendsCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:coreFriendsCell];
    }
    
    CoreFriends *friend = [self.frc objectAtIndexPath:indexPath];
    
    cell.textLabel.text = friend.coreFirstName;// stringByAppendingFormat:@" %@", person.lastName];
    cell.textLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:14.0];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",(friend.coreLocation == NULL) ? @"..." : friend.coreLocation];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.textColor  = [UIColor blueColor];
    cell.imageView.image = [UIImage imageNamed:@"Profile-256.png"];
    /***** NSLog(@"%@ --", friend.corePhone);
     update coredata coreFriends entity with friend's location
     [self updateCoreFriendsCurrentLocation:friend.corePhone];
     *****/
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellText = cell.textLabel.text;
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:cellText
                              message:cell.detailTextLabel.text
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
}

//- (void) updateCoreFriendsCurrentLocation:(NSString *)corePhone {
//    PFQuery *query = [PFQuery queryWithClassName:@"UserConnection"];
//    NSRange substrRange = NSMakeRange(corePhone.length-10, 10);
//    [query whereKey:@"userNumber" containsString:[corePhone substringWithRange:substrRange]];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//     {
//         if (!error) { // The find succeeded.
//             for (PFObject *object in objects) { // Do something w/ found objects
//                 //NSLog(@"%@", object);
//                 //NSLog(@"%@", [[object valueForKey:@"user"] objectId]);
//                 [self fetchCurrentLocationForUser:[[object valueForKey:@"user"] objectId] includePhone:corePhone];
//             }
//         } else {
//             // Log details of the failure
//             NSLog(@"Error: %@ %@", error, [error userInfo]);
//         }
//     }];
//}
//
//-(void) fetchCurrentLocationForUser:(NSString *) coreFriendObjectId includePhone:(NSString *)fPhoneStr
//{
//    PFQuery *query = [PFUser query];
//    [query getObjectInBackgroundWithId:coreFriendObjectId
//                                 block:^(PFObject *object, NSError *error)
//    {
//         if (!error) {
//             NSLog(@"%@", (NSString *)[object valueForKey:@"email"]);
//             /*  NSLog(@"%@, %@", (NSString *)[object valueForKey:@"email"], (PFGeoPoint *)[object valueForKey:@"currentLocation"]); */
//             PFGeoPoint *friendLocation = (PFGeoPoint *)[object valueForKey:@"currentLocation"];
//             NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//             
//             NSEntityDescription *entity = [NSEntityDescription entityForName:@"CoreFriends"
//                                                       inManagedObjectContext:[self managedObjectContext]];
//             
//             [fetchRequest setEntity:entity];
//             NSPredicate *predicate = [NSPredicate predicateWithFormat:@"corePhone like %@",fPhoneStr];
//             [fetchRequest setPredicate:predicate];
//             
//             NSError *error;
//             NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
//             if (fetchedObjects == nil) {
//                 // Handle the error.
//             } else
//                 //NSLog(@"from coredata: %@",fetchedObjects);
//                 for (NSManagedObject *mObject in fetchedObjects) {
//                     // Ref [0]
//                     CLLocation *locA = [[CLLocation alloc] initWithLatitude:friendLocation.latitude longitude:friendLocation.longitude];
//                     NSDictionary *userLocDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"userLocation"];
//                     CLLocation *locB = [[CLLocation alloc]
//                                         initWithLatitude:(CLLocationDegrees)[[userLocDic objectForKey:@"lat"] doubleValue]
//                                         longitude:(CLLocationDegrees)[[userLocDic objectForKey:@"long"] doubleValue]];
//                     
//                     CLLocationDistance distance = [locA distanceFromLocation:locB];
//                     
//                     [mObject setValue:[NSString stringWithFormat:@"%.2f meters away from you", distance] forKey:@"coreLocation"];
//                     
//                     NSError *savingError = nil;
//                     
//                     if ([[self managedObjectContext] save:&savingError]){
//                         NSLog(@"Successfully saved loc info for %@",(NSString *)[object valueForKey:@"email"]);
//                     } else {
//                         NSLog(@"Failed to save the managed object context.");
//                     }
//                 }
//             
//         } else
//             NSLog(@"Error: %@ %@", error, [error userInfo]); // Log details of the failure
//     }];
//}
@end
/** References:
    http://stackoverflow.com/questions/7175412/calculate-distance-between-two-place-using-latitude-longitude-in-gmap-for-iphone
 **/