//
//  NewCoreCircleTVC.m
//  FriensoAlpha
//
//  Created by Sal Aguinaga on 3/10/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "NewCoreCircleTVC.h"
#import <CoreData/NSFetchedResultsController.h>
#import <AddressBook/AddressBook.h>
#import <AddressBook/ABAddressBook.h>
#import <AddressBook/ABPerson.h>
#import <Parse/Parse.h>
#import "FriensoEvent.h"
#import "CoreFriends.h"
#import "FriensoViewController.h"
#import "FriensoAppDelegate.h"


@interface NewCoreCircleTVC ()
{
    BOOL checkCloud;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *frc;
@property (nonatomic, strong) NSMutableArray *coreCircleOfFriends;
@property (nonatomic, strong) NSMutableArray *coreCircleContacts;
@property (nonatomic, assign) NSInteger cellNumberSelected;
@end

@implementation NewCoreCircleTVC
@synthesize checkCloud = _checkCloud;

#pragma mark - Core Data access
- (void) createNewEvent:(NSString *) eventTitleStr{
    
    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *managedObjectContext =
    appDelegate.managedObjectContext;
    
    FriensoEvent *newEvent =
    [NSEntityDescription insertNewObjectForEntityForName:@"FriensoEvent"
                                  inManagedObjectContext:managedObjectContext];
    
    if (newEvent != nil){
        
        newEvent.eventTitle = eventTitleStr;
        newEvent.eventSubtitle = @"Added to your Frienso Core Friends list.";
        //TODO: Need to figure out core location
        newEvent.eventLocation  = @"Here";
        newEvent.eventContact   = [[NSUserDefaults standardUserDefaults] objectForKey:@"adminID"];
        newEvent.eventCreated   = [NSDate date];
        newEvent.eventModified  = [NSDate date];
        
        NSError *savingError = nil;
        
        if ([managedObjectContext save:&savingError]){
            NSLog(@"Successfully saved event.");
        } else {
            NSLog(@"Failed to save the managed object context.");
        }
        
    } else {
        NSLog(@"Failed to create the new person object.");
    }
    
}

#pragma mark - Navigation bar actions
- (void) save {
    NSLog(@"[ Save Core Circle of Friends ]");
    
    // Update newUserFlag
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"newUserFlag"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    /* Save the circle of friends to NSUserDefaults &
     * push them to Parse encrypted                     */
    
    NSMutableDictionary *coreCircleDic = [[NSMutableDictionary  alloc] init];
    NSInteger i = 0;

    for (NSString *circleContactName in self.coreCircleOfFriends){
        NSString *cleanedContactName = [self stripStringOfUnwantedChars:circleContactName];
        //NSLog(@"circleContactName: %@", circleContactName);
        //NSLog(@"phone: %@", [self.coreCircleContacts objectAtIndex:i++]);
        [coreCircleDic setValue:[self.coreCircleContacts objectAtIndex:i] forKey:cleanedContactName];
        i += 1;
    }
    
    NSLog(@"%@", coreCircleDic);
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:coreCircleDic forKey:@"CoreFriendsContactInfoDicKey"];
    [userDefaults synchronize];
    
    //if ([self liveNetCon]) {
    [self uploadCoreFriends:coreCircleDic]; // upload to Parse
    //}
    
    /*
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"  bundle:nil];
    FriensoViewController  *nxtVC = (FriensoViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"dashboardVC"];
    [self.navigationController pushViewController:nxtVC animated:YES];
     */
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isUserNew"])
//        [self presentDashboardViewController];
//    else
//        [self.navigationController popViewControllerAnimated:YES];
    

}
//-(void) presentDashboardViewController {
//    [self performSegueWithIdentifier:@"presentDashboard" sender:self];
//}

- (void) cancel {
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"coreCircleSet"])
        [self.navigationController popViewControllerAnimated:YES];
//        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//    else {
//        // set default values
//        NSMutableDictionary *coreCircleDic = [[NSMutableDictionary  alloc] init];
//        NSInteger i = 0;
//        for (NSString *circleContactName in self.coreCircleOfFriends){
//            [coreCircleDic setValue:[self.coreCircleContacts objectAtIndex:i++] forKey:circleContactName];
//        }
//        
//        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//        [userDefaults setObject:coreCircleDic forKey:@"CoreFriendsContactInfoDicKey"];
//        [userDefaults synchronize];
//    }
//    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"  bundle:nil];
//    FriensoViewController  *nxtVC = (FriensoViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"dashboardVC"];
//    [self.navigationController pushViewController:nxtVC animated:YES];



}



- (void)viewDidLoad
{
    [super viewDidLoad];
    printf("[ setup core circle ]\n");
    
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Setup Core Circle";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(save)];
    
    [self updateLocalArray:self.coreCircleOfFriends];
    self.coreCircleContacts = [[NSMutableArray alloc] initWithObjects:@"0",@"0",@"0",nil]; //stores phone #s
    
    // add tableview
    self.tableView = [[UITableView alloc] init];
    [self.tableView setFrame:CGRectMake(0, 0, self.view.bounds.size.width,
                                        self.view.bounds.size.height*0.70)];
    
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    [self.view addSubview:self.tableView];
    [self.tableView setCenter:self.view.center];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    //NSLog(@"%lu", (unsigned long)self.coreCircleOfFriends.count);
    return self.coreCircleOfFriends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [self.coreCircleOfFriends objectAtIndex:indexPath.row];
    // ok NSLog(@"what?f%@",[coreCircleOfFriends objectAtIndex:0]);
    NSString *path = [[NSBundle mainBundle] pathForResource:@"profile" ofType:@"png"];
    UIImage *theImage = [UIImage imageWithContentsOfFile:path];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.imageView.image = theImage;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showPickerForIndex:indexPath.row];
    
}

#pragma mark - Local Methods
- (void)showPickerForIndex:(NSInteger)indexPath

{
    self.cellNumberSelected = indexPath;
    
    ABPeoplePickerNavigationController *picker =
    
    [[ABPeoplePickerNavigationController alloc] init];
    
    picker.peoplePickerDelegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
    
}

-(NSString *) stripStringOfUnwantedChars:(NSString *)dirtyContactName {
    return  [dirtyContactName stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@".$() -"]];
}

#pragma mark - Parse related methods
-(void) uploadCoreFriends:(NSDictionary *)friendsDictionary
{
    NSLog(@"dictionary: %@", friendsDictionary);
    PFObject *userCoreFriends = [PFObject objectWithClassName:@"UserCoreFriends"];
    [userCoreFriends setObject:friendsDictionary forKey:@"userCoreFriends"];
    
    // Login to Parse
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [PFUser logInWithUsernameInBackground:[userDefaults objectForKey:@"adminID"]
                                 password:[userDefaults objectForKey:@"adminPass"]
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            PFUser *currentUser = [PFUser currentUser];
                                            if (currentUser) {
                                                NSLog(@"%@, login successful",currentUser.email);
                                            } else {
                                                // show the signup or login screen
                                                NSLog(@"no current user");
                                            }
                                        } else {
                                            NSLog(@"The login failed. Check error to see why. %@",error);
                                        }
                                    }];
    
    // Set the proper ACLs
    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [ACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:ACL withAccessForCurrentUser:YES];
    //comment.ACL = ACL;
    // Set the access control list to current user for security purposes
    userCoreFriends.ACL = ACL;// [PFACL ACLWithUser:[PFUser currentUser]];
    
    PFUser *user = [PFUser currentUser];
    NSLog(@"%@",user.email);
    [userCoreFriends setObject:user forKey:@"user"];
    [userCoreFriends saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            //[self refresh:nil];
            NSLog(@"[ CoreFriends Dictionary for User upload attempted. ]");
        }
        else{
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
}

-(void) updateLocalArray:(NSArray *)localCoreFriendsArray
{
    NSLog(@"--- updateLocalArray ");
    //[self showCoreCircle];
    
    NSDictionary *retrievedCoreFriendsDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"CoreFriendsContactInfoDicKey"]; // immutable
    
    
    if ( [retrievedCoreFriendsDictionary count] > 0) {
        
        NSEnumerator *enumerator = [retrievedCoreFriendsDictionary keyEnumerator];
        self.coreCircleOfFriends = [[NSMutableArray alloc] initWithArray:[enumerator allObjects]];
        self.coreCircleContacts =  [[NSMutableArray alloc] initWithArray:[retrievedCoreFriendsDictionary allValues]];

        // Handle if the array has less than 3 objects
        switch ([self.coreCircleOfFriends count]) {
            case 0:
                self.coreCircleOfFriends = [[NSMutableArray alloc] initWithObjects:@"CoreFriend 1",
                                       @"CoreFriend 2", @"CoreFriend 3",nil];
                //NSLog(@"[ 0 ]%lu",(unsigned long)[self.coreCircleOfFriends count]);
                break;
            case 1:
                [self.coreCircleOfFriends addObject:@"CoreFriend X"];
                [self.coreCircleOfFriends addObject:@"CoreFriend Y"];
                break;
            case 2:
                [self.coreCircleOfFriends addObject:@"CoreFriend Z"];
                break;
            default:
                break;
                
        }
        
    } else {
//        if (self.checkCloud)
//            [self checkCloudForCircle];
//        else
        self.coreCircleOfFriends = [[NSMutableArray alloc] initWithObjects:@"Core Friend 1",@"Core Friend 2",@"Core Friend 3", nil];
        
    }
}
-(void) checkCloudForCircle {
    
}


#pragma mark - AddressBook delegate methods
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    
    NSMutableString *tempStr = [[NSMutableString alloc] init];
    NSString *firstName = (__bridge_transfer NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
    NSString *lastName  = (__bridge_transfer NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
    //NSLog(@"%@", lastName);
    if ( firstName != nil ) {
        [tempStr appendString: firstName];
        [tempStr appendString:@" "];
    } else if ( lastName != nil){
        [tempStr appendString:lastName];
    } else if ((__bridge_transfer NSString *)(ABRecordCopyValue(person, kABPersonOrganizationProperty)) != nil){
        [tempStr appendString:(__bridge_transfer NSString *)(ABRecordCopyValue(person, kABPersonOrganizationProperty))];
    } else
        [tempStr appendString:@"unknow"];
    
    ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
    //NSLog(@"%@", phones);
    //[tmpStr appendString: (__bridge_transfer NSString *)(ABMultiValueCopyValueAtIndex(phones, 0));
    //NSLog(@"phone# %@",(__bridge_transfer NSString *)(ABMultiValueCopyValueAtIndex(phones, 0)));
#warning check for all potential phone numbers
    NSString *contactPhoneNumber = (__bridge_transfer NSString *)(ABMultiValueCopyValueAtIndex(phones, 0));
    NSCharacterSet *toExclude = [NSCharacterSet characterSetWithCharactersInString:@"/.()-  "];
    contactPhoneNumber = [[contactPhoneNumber componentsSeparatedByCharactersInSet:toExclude] componentsJoinedByString:@""];
    //NSLog(@"phone# %@",contactPhoneNumber);
    
    if (contactPhoneNumber == nil) {
        NSLog(@"Alert! no phone# for this friend");
        contactPhoneNumber = @"000-111-2222";
        
    }
    // Alert some-how if the phone # is invalid
    [self.coreCircleContacts replaceObjectAtIndex:self.cellNumberSelected
                                  withObject:contactPhoneNumber];//(__bridge_transfer NSString *)(ABMultiValueCopyValueAtIndex(phones, 0))];
    //NSLog(@"%@", self.coreCircleContacts);
    [self.coreCircleOfFriends replaceObjectAtIndex:self.cellNumberSelected withObject:tempStr];
    
    // Add name to CoreData
    [self createNewEvent:tempStr];
    NSArray *contactArray = [[NSArray alloc] initWithObjects:firstName, (lastName == NULL) ? @"" : lastName, contactPhoneNumber, nil];
    [self coreDataAddContact:contactArray];
    
    NSLog(@"%@",contactPhoneNumber);
    //send the core friend request to Parse.
    [self sendCoreFriendRequest:contactPhoneNumber];
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows]
                          withRowAnimation:UITableViewRowAnimationNone];
    
    return NO;
}
- (void) sendCoreFriendRequest:(NSString *) phoneNumber {
    if(phoneNumber == nil) {
        NSLog(@"Invalid number. no request send to parse");
        return;
    }
    //Remove dash from phone Number
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    //TODO: check if this request already exists.
    
    PFUser *curUser = [PFUser currentUser];
    if(curUser == nil) {
        NSLog(@"current user object is nill");
        return;
    }
    
    PFQuery * pfquery = [PFUser query];
    //it should be phone number instead of username
    [pfquery whereKey:@"phoneNumber" equalTo:phoneNumber];
    [pfquery findObjectsInBackgroundWithBlock:^(NSArray *objects,
                                                NSError *error) {
        if (!error) {
            PFUser * pfuser = [objects firstObject];
            if(pfuser == nil) {
                NSLog(@"User not found in the User list");
                //we are sending pending requests here, for users who do not exist in parse yet.
                PFObject * pfobject = [PFObject
                                       objectWithClassName:@"CoreFriendNotOnFriensoYet"];
                [pfobject setObject:curUser forKey:@"sender"];
                [pfobject setObject:phoneNumber forKey:@"recipientPhoneNumber"];
                [pfobject saveInBackground];
                return;
            }

            //A user was found
            //TODO: remove this log
            NSLog(pfuser.email );
            PFObject * pfobject = [PFObject
                                   objectWithClassName:@"CoreFriendRequest"];
            [pfobject setObject:curUser forKey:@"sender"];
            [pfobject setObject:pfuser forKey:@"recipient"];
            [pfobject setObject:@"send" forKey:@"status"];
            [pfobject setObject:@"recipient" forKey:@"awaitingResponseFrom" ];
            [pfobject saveInBackground];
        } else {
            NSLog(@"%@", error);
        }
    }];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{   // Dismisses the people picker and shows the application when users tap Cancel.
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CoreData Methods
-(void) coreDataAddContact:(NSArray *)contactInfo
{
    // Adds contact info to CoreData
    NSUInteger coreCircleSize = [self showCoreCircle];
    
    CoreFriends *cFriends = nil;
    if(coreCircleSize < 3)
    {
        cFriends = [NSEntityDescription insertNewObjectForEntityForName:@"CoreFriends"
                                  inManagedObjectContext:[self managedObjectContext]];
    } else{
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"CoreFriends"
                                                  inManagedObjectContext:[self managedObjectContext]];
        
        [fetchRequest setEntity:entity];
        NSError *error;
        NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil) {
            // Handle the error.
        }
        cFriends = [fetchedObjects objectAtIndex:self.cellNumberSelected];

    }
    if (cFriends != nil){
        NSLog(@"[contactInfo: %@]", contactInfo);
        cFriends.coreFirstName = [contactInfo objectAtIndex:0];
        cFriends.coreLastName  = ([contactInfo objectAtIndex:1] == nil) ? @"" : [contactInfo objectAtIndex:1];
        cFriends.corePhone     = ([contactInfo objectAtIndex:2] == nil) ? @"" : [contactInfo objectAtIndex:2];
        cFriends.coreModified  = [NSDate date];
        NSString *lastInitial  = [cFriends.coreLastName isEqualToString:@""] ? @"" : [cFriends.coreLastName substringToIndex:1];
        cFriends.coreNickName  = [NSString stringWithFormat:@"%@%@",[[contactInfo objectAtIndex:0] substringToIndex:1], lastInitial];
        cFriends.coreType      = @"Person";
        
        NSError *savingError = nil;
        
        if ([[self managedObjectContext] save:&savingError]){
            NSLog(@"Successfully saved contact to CoreCircle.");
        } else {
            NSLog(@"Failed to save the managed object context.");
        }
        
    } else {
        NSLog(@"Failed to create the new person object.");
    }
}

- (NSUInteger) showCoreCircle {
    NSLog(@"-- showCoreCircle --");
    NSUInteger returnValue = 0;
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
    
    self.frc.delegate = self;
    NSError *fetchingError = nil;
    if ([self.frc performFetch:&fetchingError]){
        NSLog(@"Successfully fetched coreCircle.");
        //NSLog(@"Sections: %ld", (unsigned long)[[self.frc sections] count]);
        id <NSFetchedResultsSectionInfo> sectionInfo = self.frc.sections[0];
        //NSLog(@"No. of objects in section 0: %ld",(unsigned long)sectionInfo.numberOfObjects);
        returnValue = sectionInfo.numberOfObjects;
    } else {
        NSLog(@"Failed to fetch.");
        
    }
    
    return returnValue;
}
- (NSManagedObjectContext *) managedObjectContext{
    
    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
    
}

@end
