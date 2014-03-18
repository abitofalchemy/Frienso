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
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *frc;
@property (nonatomic, strong) NSMutableArray *coreCircleOfFriends;
@property (nonatomic, strong) NSMutableArray *coreCircleContacts;
@property (nonatomic, assign) NSInteger cellNumberSelected;
@end

@implementation NewCoreCircleTVC

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
    /* Save the circle of friends to NSUserDefaults &
     * push them to Parse encrypted                     */
    
    NSMutableDictionary *coreCircleDic = [[NSMutableDictionary  alloc] init];
    NSInteger i = 0;
    //NSLog(@"%@",coreCircleContacts);
    for (NSString *circleContactName in self.coreCircleOfFriends){
        NSString *cleanedContactName = [self stripStringOfUnwantedChars:circleContactName];
        [coreCircleDic setValue:[self.coreCircleContacts objectAtIndex:i++] forKey:cleanedContactName];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:coreCircleDic forKey:@"CoreFriendsContactInfoDicKey"];
    [userDefaults synchronize];
    
    //if ([self liveNetCon]) {
    NSLog(@"%@",coreCircleDic);
    [self uploadCoreFriends:coreCircleDic]; // upload to Parse
    //}
    
    /*
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"  bundle:nil];
    FriensoViewController  *nxtVC = (FriensoViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"dashboardVC"];
    [self.navigationController pushViewController:nxtVC animated:YES];
     */
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) cancel {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"coreCircleSet"])
        [self.navigationController popViewControllerAnimated:YES];
    else {
        // set default values
        NSMutableDictionary *coreCircleDic = [[NSMutableDictionary  alloc] init];
        NSInteger i = 0;
        for (NSString *circleContactName in self.coreCircleOfFriends){
            [coreCircleDic setValue:[self.coreCircleContacts objectAtIndex:i++] forKey:circleContactName];
        }
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:coreCircleDic forKey:@"CoreFriendsContactInfoDicKey"];
        [userDefaults synchronize];
        
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"  bundle:nil];
    FriensoViewController  *nxtVC = (FriensoViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"dashboardVC"];
    [self.navigationController pushViewController:nxtVC animated:YES];
        
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Setup Core Circle";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    
    //
    [self updateLocalArray:self.coreCircleOfFriends];

    
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
    NSLog(@"%lu", (unsigned long)self.coreCircleOfFriends.count);
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
    return  [dirtyContactName stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@".$"]];
}

#pragma mark - Parse related methods
-(void) uploadCoreFriends:(NSDictionary *)friendsDictionary
{
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
                                                NSLog(@"%@",currentUser.email);
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
    NSLog(@"[2]");
    
    [userCoreFriends saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            //[self refresh:nil];
            NSLog(@"[ CoreFriends Dictionary for User upload attempted. ]");
        }
        else{
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void) updateLocalArray:(NSArray *)localCoreFriendsArray
{
    NSLog(@"updateLocalArray:");
    NSDictionary *retrievedCoreFriendsDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"CoreFriendsContactInfoDicKey"]; // immutable
    if ( retrievedCoreFriendsDictionary != NULL) {
        
        NSEnumerator *enumerator = [retrievedCoreFriendsDictionary keyEnumerator];
        self.coreCircleOfFriends = [[NSMutableArray alloc] initWithArray:[enumerator allObjects]];
        
        // Handle if the array has less than 3 objects
        switch ([self.coreCircleOfFriends count]) {
            case 0:
                self.coreCircleOfFriends = [[NSMutableArray alloc] initWithObjects:@"CoreFriend 1",
                                       @"CoreFriend 2", @"CoreFriend 3",nil];
                NSLog(@"[ 0 ]%lu",(unsigned long)[self.coreCircleOfFriends count]);
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
        NSLog(@"[ 1 ]");
        self.coreCircleOfFriends = [[NSMutableArray alloc] initWithObjects:@"Core Friend 1",@"Core Friend 2",@"Core Friend 3", nil];
    }
}

#pragma mark - AddressBook delegate methods
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    
    NSMutableString *tempStr = [[NSMutableString alloc] init];
    NSString *firstName = (__bridge_transfer NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
    NSString *lastName  = (__bridge_transfer NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
    
    if ( firstName != nil ) {
        [tempStr appendString: firstName];
        [tempStr appendString:@" "];
    } else if ( lastName != nil){
        [tempStr appendString:lastName];
    } else if ((__bridge_transfer NSString *)(ABRecordCopyValue(person, kABPersonOrganizationProperty)) != nil){
        [tempStr appendString:(__bridge_transfer NSString *)(ABRecordCopyValue(person, kABPersonOrganizationProperty))];
    } else
        [tempStr appendString:@"Name unknow"];
    
    ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
    //[tmpStr appendString: (__bridge_transfer NSString *)(ABMultiValueCopyValueAtIndex(phones, 0));
    NSLog(@"phone# %@",(__bridge_transfer NSString *)(ABMultiValueCopyValueAtIndex(phones, 0)));
    NSString *contactPhoneNumber = (__bridge_transfer NSString *)(ABMultiValueCopyValueAtIndex(phones, 0));
    
    if(contactPhoneNumber == nil) {
        NSLog(@"Alert! no phone# for this friend");
        contactPhoneNumber = @"000-111-2222";
        
    }
    // Alert some-how if the phone # is invalid
    [self.coreCircleContacts replaceObjectAtIndex:self.cellNumberSelected
                                  withObject:contactPhoneNumber];//(__bridge_transfer NSString *)(ABMultiValueCopyValueAtIndex(phones, 0))];
    
    [self.coreCircleOfFriends replaceObjectAtIndex:self.cellNumberSelected withObject:tempStr];
    
    // Add name to CoreData
    NSLog(@"%@", tempStr);
    [self createNewEvent:tempStr];
    NSArray *contactArray = [[NSArray alloc] initWithObjects:firstName, lastName, contactPhoneNumber, nil];
    [self coreDataAddContact:contactArray];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows]
                          withRowAnimation:UITableViewRowAnimationNone];
    
    return NO;
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
    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *managedObjectContext =
    appDelegate.managedObjectContext;
    
    CoreFriends *cFriends =
    [NSEntityDescription insertNewObjectForEntityForName:@"CoreFriends"
                                  inManagedObjectContext:managedObjectContext];
    
    if (cFriends != nil){
        
        cFriends.coreFirstName = [contactInfo objectAtIndex:0];
        cFriends.coreLastName  = [contactInfo objectAtIndex:1];
        cFriends.corePhone     = [contactInfo objectAtIndex:2];
        cFriends.coreModified  = [NSDate date];
        
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
@end
