//
//  FriensoQuickCircleVC.m
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 3/15/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//
//  //////////////////////////////////////////////////////
//  Getting the compose SMS and 'call' user working

#import "FriensoQuickCircleVC.h"
#import "FriensoAppDelegate.h"
#import "CoreFriends.h"
#import "FRCoreDataParse.h"
#import <Parse/Parse.h>
#import "FRStringImage.h"
#import "FRSyncFriendConnections.h"
#import "NewCoreCircleTVC.h"
#import "CloudEntityContacts.h"

static NSString *coreFriendsCell = @"coreFriendsCell";


@interface FriensoQuickCircleVC ()
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSFetchedResultsController *frc;
@property (nonatomic,strong) NSDictionary *friendToContactDic;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editFriensoContacts;
- (IBAction)editFriensoContactsAction:(id)sender;

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
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:16.0], NSFontAttributeName,nil]];
    self.navigationItem.title = @"Contacts";
    
    [self.navigationController setToolbarHidden:NO];
    
    //[[[FRSyncFriendConnections alloc] init] syncUWatchToCoreFriends]; // Sync those uWatch
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"amdinID"] == NULL )
        [[[FRSyncFriendConnections alloc] init] addStaticEntriesToOptionsMenu];
    
    // At first install, cache univesity/college emergency contacts
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"amdinID"] == NULL )
        [[[CloudEntityContacts alloc] initWithCampusDomain:@"nd.edu"] updateEmergencyContacts:@"inst,contact"];
    
    //  Add new table view
    self.tableView = [[UITableView alloc] init];
    [self.tableView setFrame:CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height*0.90)];
    
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    [self.view addSubview:self.tableView];
    
    // Create the fetch request first 
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]
                                    initWithEntityName:@"CoreFriends"];
    fetchRequest.fetchBatchSize = 20;
    
    NSSortDescriptor *modifiedSort =  [[NSSortDescriptor alloc] initWithKey:@"coreType"
                                ascending:YES];
    
    NSSortDescriptor *eventTitleSort =  [[NSSortDescriptor alloc] initWithKey:@"coreFirstName"
                                ascending:NO];
    
    fetchRequest.sortDescriptors = @[modifiedSort, eventTitleSort];
    
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                   managedObjectContext:[self managedObjectContext]
                                                     sectionNameKeyPath:@"coreType"
                                                              cacheName:nil];
    self.frc.delegate      = self;
    NSError *fetchingError = nil;
    if ([self.frc performFetch:&fetchingError]){
        if (!DBG) NSLog(@"CoreCircle fetched with nbr of categories:%lu",(unsigned long)[[self.frc sections] count]);
    } else {
        if (DBG) NSLog(@"Failed to fetch.");
    }
    
    /***
     //Update this user's current location
    FRCoreDataParse *updateLocation = [[FRCoreDataParse alloc] init];
    //[frCDPObject updateThisUserLocation];
    [updateLocation updateCoreFriendsLocation];
    **/
    
    //NSDictionary *coreFriendsDic = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"CoreFriendsContactInfoDicKey"];
    //NSLog(@"%@", [coreFriendsDic allKeys]);
    //NSLog(@"%@", [coreFriendsDic allValues]);
	
    
    
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.navigationController setToolbarHidden:NO];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//- (void)viewDidLayoutSubviews
//{
//    CGFloat tabBarHeight = 60.0f;
//    CGRect frame = self.view.frame;
//    self.navigationController.navigationBar.frame = CGRectMake(0, 0, frame.size.width, tabBarHeight);
//}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (DBG) NSLog(@"Prapre for segue");
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"segueToCoreFriends"]){

    }
    
}

#pragma mark - NSFetchedResultsController delege methods
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    printf("refreshing frc\n");
    [self.tableView reloadData];
}

#pragma mark - TableView methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionNbr = [[self.frc sections] count];
    NSLog(@"Number of sections: %ld", (long)sectionNbr);
    return sectionNbr;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.frc.sections[section];
    if (DBG) NSLog(@"%ld", (long) sectionInfo.numberOfObjects);
    return sectionInfo.numberOfObjects;
}
// handling the sections for these data
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.frc sections] objectAtIndex:section];
    return [sectionInfo name];

}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.frc sectionIndexTitles];
}
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
//    return [self.frc sectionForSectionIndexTitle:title atIndex:index];
//}

- (UITableViewCell *)tableView:(UITableView *)theTableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:coreFriendsCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:coreFriendsCell];
    }
    
    CoreFriends *friend = [self.frc objectAtIndexPath:indexPath];
    if ([friend.coreType isEqualToString:@"iCore Friends"]){
        cell.textLabel.text = (friend.coreNickName == NULL) ? friend.coreFirstName : friend.coreNickName;
        cell.imageView.image = [UIImage imageNamed:@"Profile-256.png"];
        
        /*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
         *-*- computing location distance -*-*
         *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
        if ( friend.coreLocation != nil)
            cell.detailTextLabel.text = friend.coreLocation;
        else
            cell.detailTextLabel.text = @"";
        
        PFQuery *query = [PFUser query];
        NSString* phoneNumberStr =[self stripStringOfUnwantedChars:friend.corePhone];
        [query whereKey:@"phoneNumber" containsString:phoneNumberStr];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error && objects.count > 0)
            {
                for (PFUser* parseUser in objects) {
                    PFGeoPoint* fGeoPoint = [parseUser objectForKey:@"currentLocation"];
                    CLLocation *locA = [[CLLocation alloc] initWithLatitude:fGeoPoint.latitude
                                                                  longitude:fGeoPoint.longitude];
                    PFGeoPoint *myPointLoc = [[PFUser currentUser] objectForKey:@"currentLocation"];
                    CLLocation *locB = [[CLLocation alloc] initWithLatitude:myPointLoc.latitude
                                                                  longitude:myPointLoc.longitude];
                    
                    CLLocationDistance distance = [locA distanceFromLocation:locB] * 0.000621371; //
                    // Location last update
                    NSString* dateTimeAgo = [self getTimestampForDate:parseUser.updatedAt];
                    
                    
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f mi (%@)",distance,
                                                 dateTimeAgo];
                    
                    /** Adding currentLocation to coreData causes Parse error code 154 on the console
                     ** we need to look into some how
                     **
                    friend.coreLocation = [NSString stringWithFormat:@"%.1f mi",distance];
                    NSError *savingError = nil;
                    if (![[self managedObjectContext] save:&savingError])
                        NSLog(@"Failed to save the managed object context.");
                     */
                    
                }
            }
            else
                NSLog(@"  no objects ... %@", error.localizedDescription);
        }];
        
        
    }
    else if ( [friend.coreType isEqualToString:@"oCore Friends"]){
        cell.textLabel.text = friend.coreNickName == NULL ? friend.coreFirstName : friend.coreNickName;
        cell.imageView.image = [UIImage imageNamed:@"Profile-256.png"];
    }
    else if ([friend.coreType isEqualToString:@"Emergency"]) {
        cell.textLabel.text = friend.coreFirstName;
        FRStringImage *image = [[FRStringImage alloc] init];
        cell.imageView.image = [image imageWithString:@"☏"
                                                 font:[UIFont fontWithName:@"AppleSDGothicNeo-Thin" size:22.0]
                                                 size:CGSizeMake(34, 34)];
    } else if ([friend.coreType isEqualToString:@"Profile"]) {
        cell.textLabel.text = friend.coreFirstName;
        FRStringImage *image = [[FRStringImage alloc] init];
        cell.imageView.image = [image imageWithString:@"☏"
                                                 font:[UIFont fontWithName:@"AppleSDGothicNeo-Thin" size:22.0]
                                                 size:CGSizeMake(34, 34)];
    
    } else
        cell.textLabel.text = friend.coreTitle;
    
    cell.textLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:14.0];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.textColor  = [UIColor blueColor];
    
    UIButton *smsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [smsBtn setTintColor:[UIColor blueColor]];

//    if ([friend.coreType isEqualToString:@"Emergency"]) {
//        FRStringImage *image = [[FRStringImage alloc] init];
//        [smsBtn setBackgroundImage:[image imageWithString:@"☏"
//                                                     font:[UIFont fontWithName:@"AppleSDGothicNeo-Thin" size:32.0]
//                                                     size:CGSizeMake(44, 44)] forState:UIControlStateNormal];
//    } else
//        [smsBtn setBackgroundImage:[UIImage imageNamed:@"cell-phone-ic32.png"] forState:UIControlStateNormal];
//    [smsBtn setBackgroundImage:nil forState:UIControlStateHighlighted];
//    [smsBtn addTarget:self
//               action:@selector(performSMS:withEvent:)
//     forControlEvents:UIControlEventTouchUpInside];
//    [smsBtn setFrame:CGRectMake(0,0,44,44)];
//    [smsBtn setTag:indexPath.row];
//    cell.accessoryView = smsBtn;
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    /*
    UIImageView *lView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,44.,44)];
    if ([friend.coreType isEqualToString:@"Resource"]) {
        FRStringImage *image = [[FRStringImage alloc] init];
        [lView setImage:[image imageWithString:@"☏"
                                                     font:[UIFont fontWithName:@"AppleSDGothicNeo-Thin" size:32.0]
                                                     size:CGSizeMake(44, 44)] ];
    } else
        [lView setImage:[UIImage imageNamed:@"cell-phone-ic32.png"]];
    cell.accessoryType = UITableViewCellAccessoryDetailButton;*/
//    cell.accessoryView = lView;
    
    /* Add to cell phone button
    UIButton *phoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [phoneBtn setBackgroundImage:[UIImage imageNamed:@"cell-phone-ic32.png"] forState:UIControlStateNormal];
    [phoneBtn addTarget:self
                 action:@selector(performSMS:)
       forControlEvents:UIControlEventTouchUpInside];
    if (DBG) NSLog(@"%f,%f", cell.accessoryView.frame.origin.x,cell.accessoryView.frame.origin.y );
    
    [phoneBtn setFrame:CGRectMake(cell.frame.size.width-smsBtn.frame.size.width*4.0 ,0,44.0, 44.0)];
    [phoneBtn setCenter:CGPointMake(phoneBtn.center.x, cell.center.y)];
    [cell.contentView addSubview:phoneBtn];*/
    
    /***** NSLog(@"%@ --", friend.corePhone);
     update coredata coreFriends entity with friend's location
     [self updateCoreFriendsCurrentLocation:friend.corePhone];
     *****/
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // if Resource, we should just dial it!
    CoreFriends *friend = [self.frc objectAtIndexPath:indexPath];
    self.friendToContactDic = [[NSDictionary alloc] initWithObjects:@[[self  stripStringOfUnwantedChars:friend.corePhone]]
                                                            forKeys:@[friend.coreFirstName]];
    
    if (friend!=NULL && [friend.coreType isEqualToString:@"Emergency"]) {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:nil
                                   delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"📞 Call", nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:nil
                                   delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"📞 Call",@"💬 SMS", nil] show];
    }
    
    
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    CoreFriends *friend = [self.frc objectAtIndexPath:indexPath];
    
    NSString *cellText = cell.textLabel.text;
    if (friend!=NULL && [friend.coreType isEqualToString:@"Emergency"])
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:cellText
                              message:[NSString stringWithFormat:@"%@",friend.corePhone]
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alertView show];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:cellText
                                  /*message:[NSString stringWithFormat:@"%@, %@, %@",(cell.detailTextLabel.text == NULL) ? friend.coreEmail : cell.detailTextLabel.text , friend.corePhone, friend.coreFirstName]
                                   */
                                  message:(friend.coreEmail == NULL) ? friend.corePhone : [NSString stringWithFormat:@"%@, %@",friend.coreEmail, friend.corePhone]
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
    
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
        return [tableView rowHeight]*1.15;
}


#pragma mark - Actions
-(void) performSMS:(UIButton *)sender withEvent:(UIEvent *) event {
    [UIView animateWithDuration:1.0
                     animations:^{
                         sender.center = CGPointMake(sender.center.x, sender.center.y*0.5);
                         sender.center = CGPointMake(sender.center.x, sender.center.y*2.0);
                         
                     } completion:nil];
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: [[[event touchesForView: sender] anyObject] locationInView: self.tableView]];
    if ( indexPath == nil )
        return;
    [self.tableView.delegate tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
    CoreFriends *friend     = [self.frc objectAtIndexPath:indexPath];
    if ( [friend.coreType isEqualToString:@"Resource"])
        self.friendToContactDic = [[NSDictionary alloc] initWithObjects:@[[self  stripStringOfUnwantedChars:friend.corePhone]]
                                                                forKeys:@[friend.coreTitle]];
    else if ([friend.coreType isEqualToString:@"oCore Friends"])
        self.friendToContactDic = [[NSDictionary alloc] initWithObjects:@[[self  stripStringOfUnwantedChars:friend.corePhone]] forKeys:@[friend.coreNickName]];
    else
        self.friendToContactDic = [[NSDictionary alloc] initWithObjects:@[friend.corePhone] forKeys:@[friend.coreFirstName]];
}

// -------------------------------------------------------------------------------
//	messageComposeViewController:didFinishWithResult:
//  Dismisses the message composition interface when users tap Cancel or Send.
//  Proceeds to update the feedback message field with the result of the
//  operation.
// -------------------------------------------------------------------------------
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


// -------------------------------------------------------------------------------
//	displayMailComposerSheet
//  Displays an SMS composition interface inside the application.
// -------------------------------------------------------------------------------
- (void)displaySMSComposerSheet
{
	MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
	picker.messageComposeDelegate = self;
	
    // You can specify one or more preconfigured recipients.  The user has
    // the option to remove or add recipients from the message composer view
    // controller.
    
    // You can specify the initial message text that will appear in the message
    // composer view controller.
    picker.body = @"Are you Okay?";
    /* picker.recipients = @[@"Phone number here"]; */
    picker.recipients = @[[NSString stringWithFormat:@"%@",[self.friendToContactDic allValues]]];
    if (DBG) NSLog(@"calling: %@", [NSString stringWithFormat:@"%@",[self.friendToContactDic allValues]]);
    
	[self presentViewController:picker animated:YES completion:NULL];
}
#pragma mark - UIAlert delegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if (DBG) NSLog(@"button index: %ld, %@", (long)buttonIndex, title );
    
    switch (buttonIndex) {
        case 0:
            if (DBG) NSLog(@"Cancel");
            break;
        case 1:{
            NSString *phoneNumber = [NSString stringWithFormat:@"tel://%@",[self.friendToContactDic allValues][0]];
            @try {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
            }
            @catch (NSException *exception) {
                if (DBG) NSLog(@"%@", exception.reason); }
            @finally {
                if (DBG) NSLog(@"Call: %@",[NSString stringWithFormat:@"tel://%@",[self.friendToContactDic allValues][0]]);}
            
            /*@try {
                NSString *phoneNumber = [@"tel://" stringByAppendingString:[NSString stringWithFormat:@"%@",[self.friendToContactDic allValues]]];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
            }
            @catch (NSException *exception) {
                if (DBG) NSLog(@"%@", exception.reason); }
            @finally {
                if (DBG) NSLog(@"Call: %@",[@"tel://" stringByAppendingString:[NSString stringWithFormat:@"%@",[self.friendToContactDic allValues]]]);}
            */
            break;
        }
        case 2:
            if (DBG) NSLog(@"Message");
            [self showSMSPicker:alertView];
            break;
        default:
            break;
    }
    
}
// -------------------------------------------------------------------------------
//	showSMSPicker:
//  IBAction for the Compose SMS button.
// -------------------------------------------------------------------------------
- (void)showSMSPicker:(id)sender
{
    // You must check that the current device can send SMS messages before you
    // attempt to create an instance of MFMessageComposeViewController.  If the
    // device can not send SMS messages,
    // [[MFMessageComposeViewController alloc] init] will return nil.  Your app
    // will crash when it calls -presentViewController:animated:completion: with
    // a nil view controller.
    if ([MFMessageComposeViewController canSendText])
        // The device can send email.
    {
        [self displaySMSComposerSheet];
    }
    else
        // The device can not send email.
    {
        //        self.feedbackMsg.hidden = NO;
        //		self.feedbackMsg.text = @"Device not configured to send SMS.";
        if (DBG) NSLog(@"Device not configured to send SMS.");
    }
}

#pragma mark - Helper Methods
//- (NSString *)relativeDateStringForDate:(NSDate *)date
//{
//    NSCalendarUnit units = NSDayCalendarUnit | NSWeekOfYearCalendarUnit |
//    NSMonthCalendarUnit | NSYearCalendarUnit;
//    
//    // if `date` is before "now" (i.e. in the past) then the components will be positive
//    NSDateComponents *components = [[NSCalendar currentCalendar] components:units
//                                                                   fromDate:date
//                                                                     toDate:[NSDate date]
//                                                                    options:0];
//    
//    if (components.year > 0) {
//        return [NSString stringWithFormat:@"%ld years ago", (long)components.year];
//    } else if (components.month > 0) {
//        return [NSString stringWithFormat:@"%ld months ago", (long)components.month];
//    } else if (components.weekOfYear > 0) {
//        return [NSString stringWithFormat:@"%ld weeks ago", (long)components.weekOfYear];
//    } else if (components.day > 0) {
//        if (components.day > 1) {
//            return [NSString stringWithFormat:@"%ld days ago", (long)components.day];
//        } else {
//            return @"Yesterday";
//        }
//    } else {
//        return @"Today";
//    }
//}
-(NSString *) stripStringOfUnwantedChars:(NSString *)phoneNumber {
    NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    
    //    return  [dirtyContactName stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"-()"]];
    return cleanedString;
}
- (void) coreFriendsAction:(id) sender {
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];

    [self performSegueWithIdentifier:@"segueToCoreFriends" sender:self];
    
}
- (void) editRightBarButtonAction:(UIBarButtonItem *)sender{
    if (sender.tag == 2) {
        if (DBG) NSLog(@"Right bar button item: edit");
        [self coreFriendsAction:nil];
    }
    else
        if (DBG) NSLog(@"Right bar button item: add Contacts");
    
}
- (IBAction)editFriensoContactsAction:(id)sender {
    [self performSelector:@selector(coreFriendsAction:) withObject:self afterDelay:0.0f];
    
    /**
 [UIView animateWithDuration:1.0
                     animations:^{
                         UIBarButtonItem *editBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editRightBarButtonAction:)];
                         editBtn.tag = 2;
                         UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(editRightBarButtonAction:)];
                         addBtn.tag = 3;
                         self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:editBtn, addBtn,nil];
//                         self.navigationItem.rightBarButtonItem = nil;
//                         self.navigationItem.rightBarButtonItem = nil;
//                         UIButton *backButton = [[UIButton ;
//                         UIImage *backImage = [[UIImage imageNamed:@"back_button_normal.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12.0f, 0, 12.0f)];
//                         [backButton setBackgroundImage:backImage  forState:UIControlStateNormal];
//                         [backButton setTitle:@"Back" forState:UIControlStateNormal];
//                         [backButton addTarget:self action:@selector(popBack) forControlEvents:UIControlEventTouchUpInside];
//                         UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
//                         self.navigationItem.rightBarButtonItem =
//                           
//                           
//                           //
//                           UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
//                         label.backgroundColor = [UIColor clearColor];
//                         label.font = [UIFont boldSystemFontOfSize:10.0];
//                         label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
//                         label.textAlignment = NSTextAlignmentLeft;
//                         //    ^-Use UITextAlignmentCenter for older SDKs.
//                         label.textColor = [UIColor yellowColor]; // change this color
//                         self.navigationItem.titleView = label;
//                         label.text = NSLocalizedString(@"Contacts", @"");
//                         [label sizeToFit];
                         //self.navigationController.navigationBar.titleTextAttributes tit= nil;
//                         UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, 150, 20)];
//                         lblTitle.backgroundColor = [UIColor clearColor];
//                         lblTitle.textColor = [UIColor blackColor];
//                         lblTitle.textAlignment = NSTextAlignmentLeft;
//                         [lblTitle setText:@"Contacts"];
//                         [self.navigationController.navigationItem.titleView addSubview:lblTitle];
                         //[self.view addSubview:lblTitle];
                         //UIBarButtonItem *typeField = [[UIBarButtonItem alloc] initWithCustomView:lblTitle];
                         //toolBar.items = [NSArray arrayWithArray:[NSArray arrayWithObjects:backButton,spaceBar,lblTitle, nil]];
                         //self.navigationItem.titleView = label;
                         // [self.navigationController.navigationItem
//        CGFloat tabBarHeight = 80.0f;
//        CGRect frame = self.view.frame;
//        self.navigationController.navigationBar.frame = CGRectMake(0, 0, frame.size.width, tabBarHeight);
                         if (!DBG) NSLog(@"Edit Contacts");

                         } completion:nil];
 ***/
}
- (NSString*) getTimestampForDate:(NSDate*)date{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setAMSymbol:@"am"];
    [dateFormatter setPMSymbol:@"pm"];
    
    NSString* timestamp;
    int timeIntervalInHours = (int)[[NSDate date] timeIntervalSinceDate:date] /3600;
    
    int timeIntervalInMinutes = [[NSDate date] timeIntervalSinceDate:date] /60;
    
    if (timeIntervalInMinutes <= 2){//less than 2 minutes old
        
        timestamp = @"Just Now";
        
    }else if(timeIntervalInMinutes < 15){//less than 15 minutes old
        
        timestamp = @"A few minutes ago";
        
    }else if(timeIntervalInHours < 24){//less than 1 day
        
        [dateFormatter setDateFormat:@"h:mm a"];
        timestamp = [NSString stringWithFormat:@"Today at %@",[dateFormatter stringFromDate:date]];
        
    }else if (timeIntervalInHours < 48){//less than 2 days
        
        [dateFormatter setDateFormat:@"h:mm a"];
        timestamp = [NSString stringWithFormat:@"Yesterday at %@",[dateFormatter stringFromDate:date]];
        
    }else if (timeIntervalInHours < 168){//less than  a week
        
        [dateFormatter setDateFormat:@"EEEE"];
        timestamp = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
        
    }else if (timeIntervalInHours < 8765){//less than a year
        
        [dateFormatter setDateFormat:@"d MMMM"];
        timestamp = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
        
    }else{//older than a year
        
        [dateFormatter setDateFormat:@"d MMMM yyyy"];
        timestamp = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:date]];
        
    }
    
    return timestamp;
}
@end
/** References:
    http://stackoverflow.com/questions/7175412/calculate-distance-between-two-place-using-latitude-longitude-in-gmap-for-iphone
 **/