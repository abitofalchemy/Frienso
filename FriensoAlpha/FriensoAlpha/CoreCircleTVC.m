//
//  CoreCircleTVC.m
//  ObjCTvcLoginParse
//
//  Created by Salvador Aguinaga on 8/8/13.
//  Copyright (c) 2013 Salvador Aguinaga. All rights reserved.
/*
 http://stackoverflow.com/questions/14356406/how-to-acess-contacts-of-iphone-in-ios-6
 http://sugartin.info/2011/09/07/get-information-from-iphone-address-book-in-contacts/
 *
 *  [x] Add core friends to Cloud
 *  12Jan14:SA bug saving new core firends list and their phone #s
 */

#import "CoreCircleTVC.h"
#import "FriensoAppDelegate.h"
#import "FriensoEvent.h"

#import <AddressBook/AddressBook.h>
#import <AddressBook/ABAddressBook.h>
#import <AddressBook/ABPerson.h>
#import <Parse/Parse.h>


@interface CoreCircleTVC ()<NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController *frc;
@end

@implementation CoreCircleTVC
@synthesize coreCircleSections  = _coreCircleSections;
@synthesize coreCircleOfFriends = _coreCircleOfFriends;
@synthesize contactList         = _contactList;
@synthesize lblCoreContact0     = _lblCoreContact0;
@synthesize lblCoreContact1     = _lblCoreContact1;
@synthesize lblCoreContact2     = _lblCoreContact2;
@synthesize coreCircleContacts  = _coreCircleContacts;
@synthesize cellNumberSelected  = _cellNumberSelected;

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

#pragma mark -

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"[ CoreCircleTVC ]"); // Announce the view controller
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    [self.navigationController.navigationBar setHidden:NO];
    self.navigationItem.title = @"Setup Core Circle";
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    
    coreCircleSections = [[NSArray alloc] initWithObjects:@"Core Circle of Friends",
                          @"Permissions", nil];
    [self updateLocalArray:coreCircleOfFriends];
    coreCircleContacts = [[NSMutableArray alloc] initWithObjects:@"0",@"0",@"0",nil];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return [coreCircleSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
        return [coreCircleOfFriends count];
    else
        return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 )
        return 85;
    else
        return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        lbl.textAlignment = NSTextAlignmentCenter;
        NSString *myString = [coreCircleSections objectAtIndex:0];
        
        [lbl setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0]];
        lbl.text = myString;//@"Welcome\nAdmin Sign In";
        lbl.numberOfLines = 2;
        lbl.backgroundColor = [UIColor clearColor];
        return lbl;
    } else
        return nil ;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"coreCircleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    // Configure the cell...
    //NSDictionary *item = (NSDictionary *)[self.content objectAtIndex:indexPath.row];
    
    if ( indexPath.section == 0)
    {
        
        if (indexPath.row == 0) {
            cell.textLabel.text = [coreCircleOfFriends objectAtIndex:0];
            // ok NSLog(@"what?f%@",[coreCircleOfFriends objectAtIndex:0]);
            NSString *path = [[NSBundle mainBundle] pathForResource:@"profile" ofType:@"png"]; 
            UIImage *theImage = [UIImage imageWithContentsOfFile:path];
            cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            cell.imageView.image = theImage;
            
            /*
             username = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 280, 21)];
            NSString *myString = [loginFields objectAtIndex:0];
            username .placeholder = myString;
            username .autocorrectionType = UITextAutocorrectionTypeNo;
            username.keyboardType = UIKeyboardTypeEmailAddress;
            [username setClearButtonMode:UITextFieldViewModeWhileEditing];
            username.delegate = self;
            cell.accessoryView = username;
            */
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = [coreCircleOfFriends objectAtIndex:1];
            
            NSString *path = [[NSBundle mainBundle] pathForResource:@"profile" ofType:@"png"];
            UIImage *theImage = [UIImage imageWithContentsOfFile:path];
            cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            cell.imageView.image = theImage;
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = [coreCircleOfFriends objectAtIndex:2];
            
            NSString *path = [[NSBundle mainBundle] pathForResource:@"profile" ofType:@"png"]; 
            UIImage *theImage = [UIImage imageWithContentsOfFile:path];
            cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            cell.imageView.image = theImage;
        }
                                    
    } else if ( indexPath.section == 1) {
        cell.textLabel.text = @"Permissions";
        NSString *path = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"png"]; //[[NSBundle mainBundle] pathForResource:[item objectForKey:@"imageKey"] ofType:@"png"];
        UIImage *theImage = [UIImage imageWithContentsOfFile:path];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.imageView.image = theImage;
    }
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showPickerForIndex:indexPath.row];
    
//    contactList=[[NSMutableArray alloc] init];
//    ABAddressBookRef m_addressbook = ABAddressBookCreateWithOptions(<#CFDictionaryRef options#>, <#CFErrorRef *error#>)
//    
//    
//    if (!m_addressbook) {
//        NSLog(@"opening address book");
//    }
//    
//    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(m_addressbook);
//    CFIndex nPeople = ABAddressBookGetPersonCount(m_addressbook);
//    
//    for (int i=0;i &lt; nPeople;i++) {
//        NSMutableDictionary *dOfPerson=[NSMutableDictionary dictionary];
//        
//        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
//        
//        //For username and surname
//        ABMultiValueRef phones =(NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty);
//        CFStringRef firstName, lastName;
//        firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
//        lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
//        [dOfPerson setObject:[NSString stringWithFormat:@"%@ %@", firstName, lastName] forKey:@"name"];
//        
//        //For Email ids
//        ABMutableMultiValueRef eMail  = ABRecordCopyValue(ref, kABPersonEmailProperty);
//        if(ABMultiValueGetCount(eMail) &gt; 0) {
//            [dOfPerson setObject:(NSString *)ABMultiValueCopyValueAtIndex(eMail, 0) forKey:@"email"];
//            
//        }
//        
//        //For Phone number
//        NSString* mobileLabel;
//        for(CFIndex i = 0; i &lt; ABMultiValueGetCount(phones); i++) {
//            mobileLabel = (NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
//            if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
//            {
//                [dOfPerson setObject:(NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
//            }
//            else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel])
//            {
//                [dOfPerson setObject:(NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
//                break ;
//            }
//            
//            [contactList addObject:dOfPerson];
//            CFRelease(ref);
//            CFRelease(firstName);
//            CFRelease(lastName);
//        }
//        NSLog(@"array is %@",contactList);
//    }
}

- (void)getPersonOutOfAddressBook
{
    CFErrorRef error = NULL;
    contactList=[[NSMutableArray alloc] init];
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (addressBook != nil)
    {
        NSLog(@"Succesful.");
        
        NSArray *allContacts = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);

        NSLog(@"Number of users: %lu ", (unsigned long)[allContacts count]);
        NSUInteger i = 0;
        for (i = 0; i < [allContacts count]; i++)
        {
            NSMutableDictionary *dOfPerson=[NSMutableDictionary dictionary];

            ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);

            //For username and surname
            ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
            CFStringRef firstName, lastName;
            firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
            lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
            [dOfPerson setObject:[NSString stringWithFormat:@"%@ %@", firstName, lastName]
                          forKey:@"name"];

            //For Email ids
            ABMutableMultiValueRef eMail  = ABRecordCopyValue(ref, kABPersonEmailProperty);
            
            if(ABMultiValueGetCount(eMail) > 0)
            {
                [dOfPerson setObject:(__bridge NSString *)ABMultiValueCopyValueAtIndex(eMail, 0) forKey:@"email"];
            }
            
            //For Phone number
            NSString* mobileLabel;
            for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
                mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
                if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
                {
                    [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
                }
                else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel])
                {
                    [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
                    break ;
                }
                
                [contactList addObject:dOfPerson];
                CFRelease(ref);
                CFRelease(firstName);
                CFRelease(lastName);
            }
        
        }
        //NSLog(@"array is %@",contactList);
    }
    
    CFRelease(addressBook);
}

- (void)showPickerForIndex:(NSInteger)indexPath

{
    cellNumberSelected = indexPath;
    
    ABPeoplePickerNavigationController *picker =
    
    [[ABPeoplePickerNavigationController alloc] init];
    
    picker.peoplePickerDelegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
        
}

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
    [coreCircleContacts replaceObjectAtIndex:cellNumberSelected
                                  withObject:contactPhoneNumber];//(__bridge_transfer NSString *)(ABMultiValueCopyValueAtIndex(phones, 0))];
    
    [coreCircleOfFriends replaceObjectAtIndex:cellNumberSelected withObject:tempStr];
    
    // Add name to CoreData
    NSLog(@"%@", tempStr);
    [self createNewEvent:tempStr];
    
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

- (void) cancel {
    NSLog(@"[ Cancel Core Circle of Friends ]");
    /* When cancel is pressed offer to 'demo' the app
     * Users can be set as dummy to simulate app functionality
     * */
    NSMutableDictionary *coreCircleDic = [[NSMutableDictionary  alloc] init];
    NSInteger i = 0;
    for (NSString *circleContactName in coreCircleOfFriends){
        [coreCircleDic setValue:[coreCircleContacts objectAtIndex:i++] forKey:circleContactName];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:coreCircleDic forKey:@"CoreFriendsContactInfoDicKey"];
    [userDefaults synchronize];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"LoginParseStoryboard"  bundle:nil];
    CoreCircleTVC  *coffController = (CoreCircleTVC*)[mainStoryboard instantiateViewControllerWithIdentifier: @"circleOfFriendsDashboard"];
    [self.navigationController pushViewController:coffController animated:YES];
}

- (void) save {
    NSLog(@"[ Save Core Circle of Friends ]");
    /* Save the circle of friends to NSUserDefaults &
     * push them to Parse encrypted                     */
  
    NSMutableDictionary *coreCircleDic = [[NSMutableDictionary  alloc] init];
    NSInteger i = 0;
    //NSLog(@"%@",coreCircleContacts);
    for (NSString *circleContactName in coreCircleOfFriends){
        NSString *cleanedContactName = [self stripStringOfUnwantedChars:circleContactName];
        [coreCircleDic setValue:[coreCircleContacts objectAtIndex:i++] forKey:cleanedContactName];
    }

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:coreCircleDic forKey:@"CoreFriendsContactInfoDicKey"];
    [userDefaults synchronize];
    
    //if ([self liveNetCon]) {
    NSLog(@"%@",coreCircleDic);
    [self uploadCoreFriends:coreCircleDic];
    //}
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"LoginParseStoryboard"  bundle:nil];
    CoreCircleTVC  *coffController = (CoreCircleTVC*)[mainStoryboard instantiateViewControllerWithIdentifier: @"circleOfFriendsDashboard"];
    [self.navigationController pushViewController:coffController animated:YES];
    
}

-(NSString *) stripStringOfUnwantedChars:(NSString *)dirtyContactName {
    return  [dirtyContactName stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@".$"]];
}
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
        coreCircleOfFriends = [[NSMutableArray alloc] initWithArray:[enumerator allObjects]];
        
        // Handle if the array has less than 3 objects
        switch ([coreCircleOfFriends count]) {
            case 0:
                coreCircleOfFriends = [[NSMutableArray alloc] initWithObjects:@"CoreFriend 1",
                                    @"CoreFriend 2", @"CoreFriend 3",nil];
                break;
            case 1:
                [coreCircleOfFriends addObject:@"CoreFriend X"];
                [coreCircleOfFriends addObject:@"CoreFriend Y"];
                break;
            case 2:
                [coreCircleOfFriends addObject:@"CoreFriend Z"];
                break;
            default:
                break;
                
        }
    } else {
        coreCircleOfFriends = [[NSMutableArray alloc] initWithObjects:@"Core Friend 1",@"Core Friend 2",@"Core Friend 3", nil];
    }
}

-(BOOL) liveNetCon{
    return NO;
}


@end
