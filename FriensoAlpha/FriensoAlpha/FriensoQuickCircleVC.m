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

static NSString *coreFriendsCell = @"coreFriendsCell";


@interface FriensoQuickCircleVC ()
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSFetchedResultsController *frc;
@property (nonatomic,strong) NSDictionary *friendToContactDic;

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
    self.navigationItem.title = @"Friends & Contacts";
    
    [self.navigationController setToolbarHidden:YES];
    
    
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
        NSLog(@"CoreCircle fetched with nbr of categories:%lu",(unsigned long)[[self.frc sections] count]);
    } else {
        NSLog(@"Failed to fetch.");
    }
    
    // Update this user's current location
    //FRCoreDataParse *frCDPObject = [[FRCoreDataParse alloc] init];
    //[frCDPObject updateThisUserLocation];
    //[frCDPObject updateCoreFriendsLocation];
    
    
	
    // [[[FRSyncFriendConnections alloc] init] listWatchCoreFriends]; // List those uWatch
    [[[FRSyncFriendConnections alloc] init] syncUWatchToCoreFriends]; // Sync those uWatch
    
    
    // sync coreCircle of friends
    // NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //NSLog(@"%@", [self.frc sections] ob);
    
    
//    if ([userDefaults objectForKey:@"coreCircleStatus"] == NULL )
//    {
//        NSDictionary *coreFriendsDic = [userDefaults dictionaryForKey:@"CoreFriendsContactInfoDicKey"];
//        if ( coreFriendsDic != NULL) {
//            for (NSString *name in [coreFriendsDic allKeys]){
//                CoreFriends *cFriends = [NSEntityDescription insertNewObjectForEntityForName:@"CoreFriends"
//                                                                      inManagedObjectContext:[self managedObjectContext]];                NSLog(@"%@ : %@", name, [coreFriendsDic objectForKey:name]);
//                
//                if (cFriends != nil){
//                    cFriends.coreFirstName = name;
//                    cFriends.corePhone     = [coreFriendsDic objectForKey:name];
//                    cFriends.coreCreated   = [NSDate date];
//                    cFriends.coreModified  = [NSDate date];
//                    cFriends.coreType      = @"iCore Friends";
//                    //NSLog(@"%@",[coreCircle objectAtIndex:i] );
//                    NSError *savingError = nil;
//                    
//                    if ([[self managedObjectContext] save:&savingError]){
//                        NSLog(@"Successfully saved contacts to CoreCircle.");
//                    } else {
//                        NSLog(@"Failed to save the managed object context.");
//                    }
//                } else {
//                    NSLog(@"Failed to create the new person object.");
//                }
//            }
//        }
//        [userDefaults setObject:@"set" forKey:@"coreCircleStatus"];
//        [userDefaults synchronize];
//    }
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
#pragma mark - NSFetchedResultsController delege methods
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    printf("refreshing frc\n");
    [self.tableView reloadData];
}

#pragma mark - TableView methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionNbr = [[self.frc sections] count];
    return sectionNbr;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.frc.sections[section];
    return sectionInfo.numberOfObjects;
}
// handling the sections for these data
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.frc sections] objectAtIndex:section];
    // Temporary fix
    /*if ([[sectionInfo name] isEqualToString:@"iCore Friends"])
        return @"Core Friends";
    else if ([[sectionInfo name] isEqualToString:@"WatchCircle"])
        return @"Friends";
    else
        return @"Emergency";
    */
    return [sectionInfo name];
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.frc sectionIndexTitles];
}
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.frc sectionForSectionIndexTitle:title atIndex:index];
}

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
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",(friend.coreLocation == NULL) ? @"..." : friend.coreLocation];
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
    } else
        cell.textLabel.text = friend.coreTitle;
    
    cell.textLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:14.0];
    //    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",(friend.corePhone == NULL) ? @"..." : friend.corePhone];
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
    NSLog(@"%f,%f", cell.accessoryView.frame.origin.x,cell.accessoryView.frame.origin.y );
    
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
    else if ([friend.coreType isEqualToString:@"OnWatch"])
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
    NSLog(@"calling: %@", [NSString stringWithFormat:@"%@",[self.friendToContactDic allValues]]);
    
	[self presentViewController:picker animated:YES completion:NULL];
}
#pragma mark - UIAlert delegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    NSLog(@"button index: %ld, %@", (long)buttonIndex, title );
    
    switch (buttonIndex) {
        case 0:
            NSLog(@"Cancel");
            break;
        case 1:{
            NSString *phoneNumber = [NSString stringWithFormat:@"tel://%@",[self.friendToContactDic allValues][0]];
            @try {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception.reason); }
            @finally {
                NSLog(@"Call: %@",[NSString stringWithFormat:@"tel://%@",[self.friendToContactDic allValues][0]]);}
            
            /*@try {
                NSString *phoneNumber = [@"tel://" stringByAppendingString:[NSString stringWithFormat:@"%@",[self.friendToContactDic allValues]]];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception.reason); }
            @finally {
                NSLog(@"Call: %@",[@"tel://" stringByAppendingString:[NSString stringWithFormat:@"%@",[self.friendToContactDic allValues]]]);}
            */
            break;
        }
        case 2:
            NSLog(@"Message");
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
        NSLog(@"Device not configured to send SMS.");
    }
}

#pragma mark - Helper Methods
-(NSString *) stripStringOfUnwantedChars:(NSString *)phoneNumber {
    NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    
    //    return  [dirtyContactName stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"-()"]];
    return cleanedString;
}

@end
/** References:
    http://stackoverflow.com/questions/7175412/calculate-distance-between-two-place-using-latitude-longitude-in-gmap-for-iphone
 **/