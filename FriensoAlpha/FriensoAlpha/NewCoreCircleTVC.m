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
@property (nonatomic, strong) NSMutableArray *coreCircleRequestStatus;
@property (nonatomic, assign) NSInteger cellNumberSelected;
@end

@implementation NewCoreCircleTVC
@synthesize checkCloud = _checkCloud;

static NSString * coreFriendAcceptMessage = @"Request accepted. User added to core circle";
static NSString * coreFriendRejectMessage = @"Request rejected. Click to select someone else";
static NSString * coreFriendRequestSendMessage = @"Request send. Awaiting response";
static NSString * coreFriendNotOnFriensoMessage = @"User not on Frienso";
static NSString * contactingServersForUpdate = @"Trying to get latest status from the servers";
static int MAX_CORE_FRIENDS = 3;
int activeCoreFriends = 0;


- (void)viewDidLoad
{
    [super viewDidLoad];
    printf("[ setup core circle ]\n");
    
    
    self.navigationController.navigationBarHidden = NO;

    self.navigationItem.title = @"Setup Core Circle";
    
    self.coreCircleContacts = [[NSMutableArray alloc] init]; //stores phone #s
    self.coreCircleRequestStatus = [[NSMutableArray alloc] init ]; //stores status of the requests
    self.coreCircleOfFriends =[[NSMutableArray alloc] init]; //stores the name
    
    [self updateLocalArray];
    //self.coreCircleContacts = [[NSMutableArray alloc] initWithObjects:@"0",@"0",@"0",nil];
    
    // add tableview
    self.tableView = [[UITableView alloc] init];
    [self.tableView setFrame:CGRectMake(0, 0, self.view.bounds.size.width,
                                        self.view.bounds.size.height*0.70)];
    
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    [self.view addSubview:self.tableView];
    [self.tableView setCenter:self.view.center];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"newUserFlag"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
      [self copyCoreCircleToCoreFriendsEntity]; // enables user to interact with contacts immediately
    }
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [self.coreCircleOfFriends objectAtIndex:indexPath.row];
    // Status of friendrequest
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:8.0];
    // if the coreCircleOfFriends is not set then
    cell.detailTextLabel.text = [self.coreCircleRequestStatus objectAtIndex:indexPath.row];

    // ok NSLog(@"what?f%@",[coreCircleOfFriends objectAtIndex:0]);
    NSString *path = [[NSBundle mainBundle] pathForResource:@"profile" ofType:@"png"];
    UIImage *theImage = [UIImage imageWithContentsOfFile:path];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.imageView.image = theImage;
    
    return cell;
}


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
    
    [self showAlertBeforeReplacingCoreFriend:indexPath];
    
    ABPeoplePickerNavigationController *picker =
    
    [[ABPeoplePickerNavigationController alloc] init];
    
    picker.peoplePickerDelegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
    
}


-(void) showAlertBeforeReplacingCoreFriend:(NSInteger) indexPath {
    // if the user at index has already accepted the core friend request, we should show a alert box
    // telling that further action will remove the this user.
    //we will get the name and status and display it to the user in a message
    
    NSString * alertTitle;
    NSString * message;
    if([[self.coreCircleRequestStatus objectAtIndex:indexPath] hasPrefix:coreFriendAcceptMessage]) {
       
        //existing user at indexPath has accepted the requests
        alertTitle = [NSString stringWithFormat:@"Remove %@?", [self.coreCircleOfFriends objectAtIndex:indexPath]];
        message = [NSString stringWithFormat:@"%@ has already accepted your request. If you select another person, %@ will be removed from the Core friends.",[self.coreCircleOfFriends objectAtIndex:indexPath],[self.coreCircleOfFriends objectAtIndex:indexPath] ];
        
    } else if ([[self.coreCircleRequestStatus objectAtIndex:indexPath] hasPrefix:coreFriendRequestSendMessage]) {
        
        // request is send, waiting for recipients response
        alertTitle = [NSString stringWithFormat:@"Remove %@?", [self.coreCircleOfFriends objectAtIndex:indexPath]];
        message = [NSString stringWithFormat:@"%@ has already been sent a request. If you select another person, request to %@ will be canceled and removed",[self.coreCircleOfFriends objectAtIndex:indexPath],[self.coreCircleOfFriends objectAtIndex:indexPath] ];
        
    } else {
        
        //Either request is rejected or user not on frienso. In both cases we dont have to display any alert message. hence returning from here
        return;
    }
    
    //The next message will be based on the core friend request status
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(NSString *) stripStringOfUnwantedChars:(NSString *)dirtyContactName {
    return  [dirtyContactName stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@".$() -"]];
}


-(void) updateLocalArray
{
    NSLog(@"--- updateLocalArray ");
    //[self showCoreCircle];
    activeCoreFriends = 0;
    for (int i = 0 ; i < MAX_CORE_FRIENDS; i++) {
        NSString * name = [NSString stringWithFormat:@"Core Friend %d",i+1];
        [self.coreCircleOfFriends addObject:name];
        [self.coreCircleContacts addObject:@""]; // we use this to check if the contact is valid to save.
        [self.coreCircleRequestStatus addObject:@"Click to select a core friend from contacts"];
       // NSLog(@"Added to Array %d",i);
    }
    
    //read from cache
    [self updateFromUserDefaults];
    
    ///update status from Parse:
    PFQuery * pfquery = [PFQuery queryWithClassName:@"CoreFriendRequest"];
    [pfquery includeKey:@"recipient"];
    [pfquery whereKey:@"sender" equalTo:[PFUser currentUser]];
    //[pfquery whereKey:@"awaitingResponseFrom" equalTo:@"sender"];
    [pfquery findObjectsInBackgroundWithBlock:^(NSArray *objects,
                                                NSError *error) {
        NSInteger i = 0;
        
        if(!error) {
            if([objects count] >0) {//if atleast one record is found, then only we want to
                //reload the table view
                
                for (id object in objects) {
                    NSLog(@"Number of active friends %d",activeCoreFriends);
                    if(activeCoreFriends >= MAX_CORE_FRIENDS) {
                        NSLog(@"Atleast %d  core friends found in frienso",MAX_CORE_FRIENDS);
                        break;
                    }
                    PFObject * pfobject = object;
                    PFUser * sender = [pfobject objectForKey:@"recipient"];
                    NSString *senderPhoneNumber = sender[@"phoneNumber"];
                    NSString *response = [pfobject objectForKey:@"status"];
                    NSString *senderName = [pfobject objectForKey:@"recipientName"];
                    [self.coreCircleRequestStatus replaceObjectAtIndex:i withObject:coreFriendRequestSendMessage];
                    [self.coreCircleContacts replaceObjectAtIndex:i withObject:senderPhoneNumber];
                    [self.coreCircleOfFriends replaceObjectAtIndex:i withObject:senderName];

                    if([response isEqualToString:@"send"]) {
                        [self.coreCircleRequestStatus replaceObjectAtIndex:i withObject:coreFriendRequestSendMessage];
                    } else if ([response isEqualToString:@"reject"]) {
                        [self.coreCircleRequestStatus replaceObjectAtIndex:i withObject:coreFriendRejectMessage];
                    } else  if([response isEqualToString:@"accept"]) {
                        [self.coreCircleRequestStatus replaceObjectAtIndex:i withObject:coreFriendAcceptMessage];
                    } else {
                        [self.coreCircleRequestStatus replaceObjectAtIndex:i withObject:response];
                    }
                    i++;
                    activeCoreFriends++;

                }
            }

            //only if max are not found.
            if(activeCoreFriends < MAX_CORE_FRIENDS) {

                // check if the contact is pending list, then show that information
                PFQuery * pfquery = [PFQuery queryWithClassName:@"CoreFriendNotOnFriensoYet"];
                [pfquery whereKey:@"sender" equalTo:[PFUser currentUser]];
                // [pfquery whereKey:@"recipientPhoneNumber" containedIn:self.coreCircleContacts];
                [pfquery findObjectsInBackgroundWithBlock:^(NSArray *objects,
                                                            NSError *error) {
                    if(!error) {
                        int i = activeCoreFriends;
                        if([objects count] >0) {//if atleast one record is found, then only we want to
                            //reload the table view
                            for (id object in objects) {
                                if(activeCoreFriends >= MAX_CORE_FRIENDS) {
                                    NSLog(@"Atleast %d  core friends found",MAX_CORE_FRIENDS);
                                    break;
                                }

                                NSString *senderPhoneNumber = (NSString *)object[@"recipientPhoneNumber"];
                                NSString *senderName = [object objectForKey:@"recipientName"];
                                [self.coreCircleContacts replaceObjectAtIndex:i withObject:senderPhoneNumber];
                                [self.coreCircleOfFriends replaceObjectAtIndex:i withObject:senderName];
                                [self.coreCircleRequestStatus replaceObjectAtIndex:i withObject:coreFriendNotOnFriensoMessage];
                                i++;
                                activeCoreFriends++;
                            }
                        }
                    }else {
                        NSLog(@"%@",error);
                    }
                    [self refresh];
                }];
            } else {
                [self refresh];
            }
        } else {
            NSLog(@"%@",error);
        }
    }];
}


-(void) refresh {
    //This function should be called on any changes received to core friends.
    //To update local cache add methods here
    [self.tableView reloadData];
    //save to NSUserDefaults
    NSMutableDictionary *coreCircleDic = [[NSMutableDictionary  alloc] init];
    NSInteger i = 0;
    
    for (NSString *circleContactName in self.coreCircleOfFriends){
        //check to avoid writing contacts with no phoneNumbers
        if(![[self.coreCircleContacts objectAtIndex:i] isEqualToString:@""]) {
            [coreCircleDic setValue:[self.coreCircleContacts objectAtIndex:i] forKey:circleContactName];
        
        }
        i += 1;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:coreCircleDic forKey:@"CoreFriendsContactInfoDicKey"];
#warning //[userDefaults synchronize];
    /*
     -(void) saveCFDictionaryToNSUserDefaults:(NSDictionary *)friendsDic {
     // From Parse
     NSLog(@"[ saveCFDictionaryToNSUserDefaults ]");
     
     NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
     [userDefaults setObject:friendsDic forKey:@"CoreFriendsContactInfoDicKey"];
     [userDefaults setBool:YES forKey:@"coreFriendsSet"];
     [userDefaults synchronize];
     
     // Save dictionary to CoreFriends Entity (CoreData)
     NSEnumerator    *enumerator = [friendsDic keyEnumerator];
     NSMutableArray  *coreCircle = [[NSMutableArray alloc] initWithArray:[enumerator allObjects]];
     NSArray *valueArray         = [friendsDic allValues]; // holds phone numbers
     
     // Access to CoreData
     for (int i=0; i<[coreCircle count]; i++) {
     CoreFriends *cFriends = [NSEntityDescription insertNewObjectForEntityForName:@"CoreFriends"
     inManagedObjectContext:[self managedObjectContext]];
     if (cFriends != nil){
     cFriends.coreFirstName = [coreCircle objectAtIndex:i];
     cFriends.coreLastName  = @"";
     cFriends.corePhone     = [valueArray objectAtIndex:i];
     cFriends.coreCreated   =  [NSDate date];
     cFriends.coreModified  = [NSDate date];
     cFriends.coreType      = @"iCore Friends";
     //NSLog(@"%@",[coreCircle objectAtIndex:i] );
     NSError *savingError = nil;
     
     if ([[self managedObjectContext] save:&savingError]){
     NSLog(@"Successfully saved contacts to CoreCircle.");
     } else {
     NSLog(@"Failed to save the managed object context.");
     }
     } else {
     NSLog(@"Failed to create the new person object.");
     }
     }
     
     }
     */
}

-(void) updateFromUserDefaults {
    NSDictionary *retrievedCoreFriendsDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"CoreFriendsContactInfoDicKey"];
    int i = 0;
    for (id key in retrievedCoreFriendsDictionary) {
        //NSLog(@"reading contact %@",[retrievedCoreFriendsDictionary objectForKey:key]);
        [self.coreCircleOfFriends replaceObjectAtIndex:i withObject:key];
        [self.coreCircleContacts replaceObjectAtIndex:i  withObject:[retrievedCoreFriendsDictionary objectForKey:key]];
        [self.coreCircleRequestStatus replaceObjectAtIndex:i withObject:contactingServersForUpdate];
        i++;
        if(i == MAX_CORE_FRIENDS) {
            break;
        }
    }
}

-(void) copyCoreCircleToCoreFriendsEntity
{
#warning ensure that this doesn't append to the iCoreFriends section, but instead replaces the record
#warning to be done in the next round 
    
    NSInteger i = 0;
    
    for (NSString *circleContactName in self.coreCircleOfFriends){
        //check to avoid writing contacts with no phoneNumbers
        if(![[self.coreCircleContacts objectAtIndex:i] isEqualToString:@""]) {
            // 25Jun14/SA
            // saving to entity CoreFriends and start interacting with them //
            FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            
            NSManagedObjectContext *managedObjectContext =
            appDelegate.managedObjectContext;
            CoreFriends *cFriends = [NSEntityDescription insertNewObjectForEntityForName:@"CoreFriends"
                                                                  inManagedObjectContext:managedObjectContext];
            if (cFriends != nil){
                cFriends.coreFirstName = circleContactName;
                cFriends.corePhone     = [self.coreCircleContacts objectAtIndex:i];
                cFriends.coreCreated   = [NSDate date];
                cFriends.coreModified  = [NSDate date];
                cFriends.coreType      = @"iCore Friends";
                //NSLog(@"%@",[coreCircle objectAtIndex:i] );
                
                NSError *savingError = nil;
                
                if ([managedObjectContext save:&savingError]){
                    NSLog(@"Successfully saved contacts to CoreCircle.");
                } else {
                    NSLog(@"Failed to save the managed object context.");
                }
            } else {
                NSLog(@"Failed to create the new person object.");
            }
            
        }
        i += 1;
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
    
    //if the same contact is chosen again
    if( ([self.coreCircleContacts count] > self.cellNumberSelected)  && [contactPhoneNumber isEqualToString:[self.coreCircleContacts objectAtIndex:self.cellNumberSelected] ]) {
        //nothing to be done as user already added.
        NSLog(@"Core user not changed. Aborting");
        [self dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }
    
    // if the contact is already selected at other location in core friend list
    for (NSString * number in self.coreCircleContacts) {
        if([contactPhoneNumber isEqualToString:number]) {
            NSLog(@"User already present at another slot. Aborting");
            NSString * message =[NSString stringWithFormat:@"%@ already added to Core Friends. Please select someone else", tempStr];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error: Already in Core Friends"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return NO;
        }
    }
    

    // Alert some-how if the phone # is invalid or nill
    if (contactPhoneNumber == nil) {

        //Show error and cancel request.
        NSString * message =[NSString stringWithFormat:@"We cannot find a valid phone number for %@", tempStr];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error: Incorrect Phone Number"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    //remove the existing contact from the cloud at the picked location
    [self removeCoreFriendCloud:self.cellNumberSelected];

        NSLog(@"udayan");
    
    //send the core friend request to Parse.
    [self sendCoreFriendRequest:contactPhoneNumber withIndex:self.cellNumberSelected];

    [self.coreCircleContacts replaceObjectAtIndex:self.cellNumberSelected
                                  withObject:contactPhoneNumber];//(__bridge_transfer NSString *)(ABMultiValueCopyValueAtIndex(phones, 0))];
    //NSLog(@"%@", self.coreCircleContacts);
    [self.coreCircleOfFriends replaceObjectAtIndex:self.cellNumberSelected withObject:tempStr];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadRowsAtIndexPaths:[self.tableView indexPathsForVisibleRows]
                          withRowAnimation:UITableViewRowAnimationNone];
    [self refresh];
    return NO;
}

-(void) removeCoreFriendCloud:(NSInteger) index {
    NSString * phoneNumber;
    if(index < [self.coreCircleContacts count]) {
         phoneNumber = [self.coreCircleContacts objectAtIndex:index];
    } else {
        return;
    }

    if(phoneNumber == nil) {
        NSLog(@"Invalid number. no request send to parse");
        return;
    }
    //Remove dash from phone Number
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
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
                NSLog(@"User to be removed not found in the User list");
                //Remove from CoreFriendNotOnFriensoYet
                PFQuery * pfquerynotonfrienso =  [PFQuery queryWithClassName:@"CoreFriendNotOnFriensoYet"];
                
               
                [pfquerynotonfrienso whereKey:@"sender" equalTo:curUser];
                [pfquerynotonfrienso whereKey:@"recipientPhoneNumber" equalTo:phoneNumber ];
                [pfquerynotonfrienso findObjectsInBackgroundWithBlock:^(NSArray *objects,
                                                                        NSError *error) {
                    //remove the pending request.
                    for(PFObject  *object in objects){
                        [object deleteInBackground];
                    }
                }];
                    return;
            }
            //remove if the other person is a frienso user
            //TODO: this can be pushed to parse cloud functionality too.
            PFQuery *remove = [PFQuery queryWithClassName:@"CoreFriendRequest"];
            [remove whereKey:@"sender" equalTo:curUser];
            [remove whereKey:@"recipient" equalTo:pfuser];
            [remove findObjectsInBackgroundWithBlock:^(NSArray *objects,
                                                               NSError *error) {
                if (!error) {
                    if([objects count] != 0) {  //remove all objects
                        for (PFObject * object in objects) {
                            [object deleteInBackground];
                        }
                    } else {
                        NSLog(@"Core friend request already send to this contact %@", phoneNumber);
                    }
                }
            }];
            //TODO: Also remove any pending/ongoing track request.
            
        } else {
            NSLog(@"%@", error);
        }
    }];
}

- (void) sendCoreFriendRequest:(NSString *) phoneNumber withIndex:(NSInteger)cellNumber {
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
                [pfobject setObject:[self.coreCircleOfFriends objectAtIndex:cellNumber] forKey:@"recipientName"];
                [pfobject saveInBackground];
                [self.coreCircleRequestStatus replaceObjectAtIndex:cellNumber
                                                        withObject:coreFriendNotOnFriensoMessage];
                [self refresh];
                return;
            }

            //need to check if the request already exists.

            PFQuery *duplicateCheck = [PFQuery queryWithClassName:@"CoreFriendRequest"];
            [duplicateCheck whereKey:@"sender" equalTo:curUser];
            [duplicateCheck whereKey:@"recipient" equalTo:pfuser];
            [duplicateCheck findObjectsInBackgroundWithBlock:^(NSArray *objects,
                                                        NSError *error) {
                if (!error) {
                    if([objects count] == 0) {  //if no request exists, add now
                        PFACL * pfacl = [PFACL ACL];
                        [pfacl setWriteAccess:YES forUser:pfuser];
                        [pfacl setReadAccess:YES forUser:pfuser];
                        [pfacl setReadAccess:YES forUser:curUser];
                        [pfacl setWriteAccess:YES forUser:curUser];

                        PFObject * pfobject = [PFObject
                                               objectWithClassName:@"CoreFriendRequest"];
                        [pfobject setObject:curUser forKey:@"sender"];
                        [pfobject setObject:pfuser forKey:@"recipient"];
                        [pfobject setObject:[self.coreCircleOfFriends objectAtIndex:cellNumber] forKey:@"recipientName"];
                        [pfobject setObject:@"send" forKey:@"status"];
                        [pfobject setObject:@"recipient" forKey:@"awaitingResponseFrom" ];
                        [pfobject setACL:pfacl];
                        [pfobject saveInBackground];
                        [self.coreCircleRequestStatus replaceObjectAtIndex:cellNumber
                                                                withObject:coreFriendRequestSendMessage];
                        //Reload the TableView as the status has changed.
                        [self refresh];
                        /**************CORE FRIEND REQUEST: PUSH NOTIFICATION STUFF*****************/
                        
                        //Send Push Notification, informing person that they have been sent a friend request
                        NSString *myString = @"Ph";
                        NSString *coreFrndChannel = [myString stringByAppendingString:phoneNumber];
                        
                        
                        //Create Core Friend Request Message
                        
                        
                        
                        PFPush *push = [[PFPush alloc] init];
                        
                        // Be sure to use the plural 'setChannels' if you are sending to more than one channel.
                        [push setChannel:coreFrndChannel];
                        NSString *coreRqstHeader = @"Core Friend Request From: ";
                        NSString *coreFrndMsg = [coreRqstHeader stringByAppendingString:[[PFUser currentUser] objectForKey:@"username"]];
                        
                        [push setMessage:coreFrndMsg];
                        [push sendPushInBackground];
                        
                        /**************END OF PUSH NOTIFICATION STUFF****************/

                    } else {
                        NSLog(@"Core friend request already send to this contact %@", phoneNumber);
                    }
                }
            }];
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
@end
