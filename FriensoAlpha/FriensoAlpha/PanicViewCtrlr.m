//
//  PanicViewCtrlr.m
//  Frienso_iOS
//
//  Created by Sal Aguinaga on 2/16/14.
//  Copyright (c) 2014 Salvador Aguinaga. All rights reserved.
/*  References:
 *  http://www.appcoda.com/customize-navigation-status-bar-ios-7/
 *
 * */

#import "PanicViewCtrlr.h"
#import "FriensoEvent.h"
#import <Parse/Parse.h>
#import "FriensoAppDelegate.h"
#import "FriensoViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "CloudUsrEvnts.h"
#import "FRStringImage.h"


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:0.8]

static NSString *contactCell          = @"contactCell";


@interface PanicViewCtrlr ()
{
    int time;
    bool overrideTimer;
    UIImageView     *circleImageView;
    NSMutableArray  *helpMeNowContactsArr;
    UITableView     *contactsTableView;

}
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *lowerLabel;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel* timerLabel;
@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic, strong) NSFetchedResultsController *frc;
@property (nonatomic, strong) UITableView     *contactsTableView;
@property (nonatomic, strong) NSMutableArray  *helpMeNowContactsArr;
@end

@implementation PanicViewCtrlr
@synthesize contactsTableView = _contactsTableView;
@synthesize helpMeNowContactsArr = _helpMeNowContactsArr;


- (void)viewDidLoad
{
    [super viewDidLoad];
	NSLog(@"HelpMeNow (PanicViewCtrlr)");
    
    /* [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0xbdc3c7)];
    [self.view setBackgroundColor:UIColorFromRGB(0xecf0f1)];
    */
    
//    NSShadow *shadow = [[NSShadow alloc] init];
//    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
//    shadow.shadowOffset = CGSizeMake(0, 1);
//    [self.navigationController.navigationBar setTranslucent:YES];
//    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
//                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
//                                                           shadow, NSShadowAttributeName,
//                                                           [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:21.0], NSFontAttributeName, nil]];
    self.title = @"Help Me Now!";
    
    [self setupCoreContactsDataModel];
    [self setupCancelButton];
    //[self setupTopLabel];
    [self setupLowerLabel];
    //[self setupNavigationBarImage];
    [self initializeTimer];
    // Hide the tool bar
    [self.navigationController setToolbarHidden:YES];
    
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:NO];
}
#pragma mark - Data model for emergency contacts
-(void) setupCoreContactsDataModel
{
    NSDictionary *coreFriendsDic = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"CoreFriendsContactInfoDicKey"];
    
    helpMeNowContactsArr = [[NSMutableArray alloc] init];
    [coreFriendsDic enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        NSLog(@"%@ = %@", key, object);
        [helpMeNowContactsArr addObject:key];
    }];
    
    [helpMeNowContactsArr addObject:@"ND Security Police"]; // ND security police
    
    // Add contacts table
    contactsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    contactsTableView.delegate = self;
    contactsTableView.dataSource = self;
    UIColor *color = [UIColor lightGrayColor];
    contactsTableView.layer.shadowColor = [color CGColor];
    contactsTableView.layer.shadowRadius = 4.0f;
    contactsTableView.layer.shadowOpacity = .9;
    contactsTableView.layer.shadowOffset = CGSizeZero;
    contactsTableView.layer.masksToBounds = NO;
    [self.view addSubview:contactsTableView];
    //[contactsTableView setFrame:CGRectMake(0,80,self.view.frame.size.width * 0.9,self.view.frame.size.height*0.4)];
    [contactsTableView setHidden:YES];
    
}
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
        newEvent.eventSubtitle = @"Panic alarm timed out and alerts were sent";
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
#pragma mark - PanicViewCtrl
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (NSAttributedString *) attributedText: (NSString*)theString
{
    
//    NSString *string = @"We will email and text\n"
//                        "everyone in your\n"
//                        "Core Circle of Friends";
    
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc]
                                         initWithString:theString];
    
//    NSDictionary *attributesForFirstWord = @{
//                                             NSFontAttributeName : [UIFont boldSystemFontOfSize:48.0f],
//                                             NSForegroundColorAttributeName : [UIColor redColor],
//                                             NSBackgroundColorAttributeName : [UIColor blackColor]
//                                             };
//    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor darkGrayColor];
    shadow.shadowOffset = CGSizeMake(1.5f, 1.5f);
    
    UIFont *myFont = [ UIFont fontWithName: @"HelveticaNeue-Medium" size: 20.0 ];
    NSDictionary *attributesForSecondWord = @{
                                              NSFontAttributeName : myFont,
                                              NSForegroundColorAttributeName : [UIColor redColor],
                                              NSBackgroundColorAttributeName : [UIColor clearColor],
                                              NSShadowAttributeName : shadow
                                              };
    
//    /* Find the string "iOS" in the whole string and sets its attribute */
//    [result setAttributes:attributesForFirstWord
//                    range:[string rangeOfString:@"iOS"]];
    
    /* Do the same thing for the string "SDK" */
    [result setAttributes:attributesForSecondWord
                    range:[theString rangeOfString:theString]];
    
    return [[NSAttributedString alloc] initWithAttributedString:result];
    
}


-(void) setupNavigationBarImage{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,100.f,40.0f)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *image = [UIImage imageNamed:@"frienso-dashboard-bar.png"];
    [imageView setImage:image];
    
    self.navigationItem.titleView = imageView;
}
-(void) setupTopLabel{
    self.label = [[UILabel alloc] init];
    self.label.backgroundColor = [UIColor clearColor];
    self.label.text = @"HelpNow!!";
    self.label.font = [UIFont boldSystemFontOfSize:48.0f];
    self.label.textColor = [UIColor blackColor];
    self.label.shadowColor = [UIColor lightGrayColor];
    self.label.shadowOffset = CGSizeMake(2.0f, 2.0f);
    [self.label sizeToFit];
    
    self.label.center = CGPointMake(self.view.center.x,self.view.bounds.size.height*0.1);
    [self.view addSubview:self.label];
}
-(void) setupLowerLabel{
    self.lowerLabel = [[UILabel alloc] init];
    self.lowerLabel.backgroundColor = [UIColor clearColor];
    self.lowerLabel.attributedText = [self attributedText:@"We will email and text\n"
                                      "everyone in your\n"
                                      "Core Circle of Friends"];
    self.lowerLabel.numberOfLines = 3;
    self.lowerLabel.textAlignment = NSTextAlignmentCenter;
    [self.lowerLabel sizeToFit];
    
    self.lowerLabel.center = CGPointMake(self.view.center.x,
                                         self.button.frame.origin.y*0.9 );
    [self.view addSubview:self.lowerLabel];
}

-(void) cancelPanicMethod:(id) sender {
    //[[(FriensoViewController *)self.navigationController.parentViewController helpMeNowSwitch] setSelected:NO];
    if ( self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"helpNowCancelled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
//    [[(FriensoViewController *)self.navigationController.parentViewController helpMeNowSwitch] removeFromSuperview];
    
      
    NSLog(@"[ HelpNow!ing Cancelled ]");
    [self.navigationController popViewControllerAnimated:YES];
    //[self dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController.navigationItem.leftBarButtonItem SET];
    
    
}
// Update our timer label
- (void) timerUpdate {
    time -= 1;
    self.timerLabel.text = [NSString stringWithFormat:@":%2ds", time];
    if (time <= 0)
        [self performSelector:@selector(sendHelpNowNotification)
                   withObject:nil afterDelay:0.];
}
-(void) initializeTimer{
    
    // ring background
    UIImage *bgRingImg     = [UIImage imageNamed:@"alert-ring-bg.png"];
    circleImageView = [[UIImageView alloc] initWithImage:bgRingImg];
    //NSLog(@"%f,%f", bgRingImg.size.width, bgRingImg.size.height);
    circleImageView.frame = CGRectMake(0, 0, 168, 168);
    circleImageView.center = self.view.center;
    [self.view addSubview:circleImageView];
    [UIView animateWithDuration:0.9 animations:^{
        circleImageView.layer.affineTransform = CGAffineTransformMakeScale(10.0, 10.0); // To make a view larger:
        //self.view.layer.affineTransform = CGAffineTransformMakeScale(0.0, 0.0); // to make a view smaller
    }];
    // To reset views back to their initial size after changing their sizes:
    [UIView animateWithDuration:0.9 animations:^{
        circleImageView.layer.affineTransform = CGAffineTransformIdentity;
        //otherView.layer.affineTransform = CGAffineTransformIdentity;
    }];
    // Initialize our timer and label
    time = 7;
    overrideTimer = NO;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(timerUpdate)
                                                userInfo:nil
                                                 repeats:YES];
    
    self.timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x, 10, 120, 40)];
    self.timerLabel.backgroundColor = [UIColor clearColor];
    self.timerLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-SemiBold" size:60.];
    self.timerLabel.text = @":07s";
    [self.timerLabel sizeToFit];
    [self.view addSubview:self.timerLabel];

    self.timerLabel.center = self.view.center;
}
-(void) setupCancelButton {
    
    self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.button addTarget:self
                    action:@selector(cancelPanicMethod:)
          forControlEvents:UIControlEventTouchDown];
    [self.button setTitle:@"Cancel" forState:UIControlStateNormal];
    self.button.frame = CGRectMake(0, 0, 160.0, 40.0);
    [self.button setCenter:CGPointMake(self.view.bounds.size.width/2.0f, self.view.frame.size.height*0.85f)];
    self.button.layer.cornerRadius = 8.0f;
    _button.layer.borderWidth = 1.2f;
    _button.layer.borderColor = [UIColor blueColor].CGColor;
    UIFont *myFont = [ UIFont fontWithName: @"AppleSDGothicNeo-SemiBold" size: 14.0 ];
    _button.titleLabel.font = myFont;
    
    [self.view addSubview:_button];
}
-(void) sendHelpNowNotification {
    NSLog(@"[ sending notifications to core friends ]");
    if ( self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    //Code to send HelpNow!s to all friends with your location information
    
    /**************PUSH NOTIFICATIONS: HELP ME NOW!!!! *****************/
    
    //Query Parse to know who your "accepted" core friends are and send them each a notification
    /*
    PFQuery *query = [PFQuery queryWithClassName:@"CoreFriendRequest"];
    [query whereKey:@"status" equalTo:@"accept"];
    [query whereKey:@"sender" equalTo:[PFUser currentUser]];
    [query includeKey:@"recipient"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            //NSLog(@"Successfully retrieved %d scores.", objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                NSString *myString = @"Ph";
                NSString *personalizedChannelNumber = [myString stringByAppendingString:object[@"recipient"][@"phoneNumber"]];
                NSLog(@"Phone Number for this friend is: %@", personalizedChannelNumber);
                
                PFPush *push = [[PFPush alloc] init];
                
                // Be sure to use the plural 'setChannels' if you are sending to more than one channel.
                [push setChannel:personalizedChannelNumber];
                NSString *coreRqstHeader = @"HELP REQUEST FROM: ";
                NSString *coreFrndMsg = [coreRqstHeader stringByAppendingString:[[PFUser currentUser] objectForKey:@"username"]];
                
                [push setMessage:coreFrndMsg];
                [push sendPushInBackground];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
     */
    
    // Log this event on Parse/UserEvents
    CloudUsrEvnts *watchMePushNots = [[CloudUsrEvnts alloc] initWithAlertType:@"helpNow"];
    [watchMePushNots sendToCloud];
    
    NSDictionary *myCoreFriendsDic = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"CoreFriendsContactInfoDicKey"];
    //int i = 0;
    for (id key in myCoreFriendsDic) {
        NSLog(@"reading contact %@",[myCoreFriendsDic objectForKey:key]);
        NSString *coreFriendPh = [self stripStringOfUnwantedChars:[myCoreFriendsDic objectForKey:key]];
        
        NSString *myString = @"Ph";
        NSString *personalizedChannelNumber = [myString stringByAppendingString:coreFriendPh];
        NSLog(@"Phone Number for this friend is: %@", personalizedChannelNumber);
        
        PFPush *push = [[PFPush alloc] init];
        
        // Be sure to use the plural 'setChannels' if you are sending to more than one channel.
        [push setChannel:personalizedChannelNumber];
        NSString *coreRqstHeader = @"HELP NOW REQUEST FROM: ";
        NSString *coreFrndMsg = [coreRqstHeader stringByAppendingString:[[PFUser currentUser] objectForKey:@"username"]];
        
        [push setMessage:coreFrndMsg];
        [push sendPushInBackground];
    }
    /**************END OF PUSH NOTIFICATIONS: HELP ME NOW!!!! *****************/
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self createNewEvent:@"Sent HelpNow! Notification"];
    [contactsTableView setHidden:NO];

    [UIView animateWithDuration:0.9 animations:^{
        //circleImageView.layer.affineTransform = CGAffineTransformIdentity;
        //otherView.layer.affineTransform = CGAffineTransformIdentity;
        [self.button removeFromSuperview]; // Removes the Cancel Btn
        [circleImageView removeFromSuperview];
        [self.timerLabel removeFromSuperview];
        // Add options to call and make this a push vc
        self.lowerLabel.attributedText = [self attributedText:@"Your Core Friends have been notified or will receive SMS"];
        [self.lowerLabel setCenter:CGPointMake(self.view.center.x, self.view.center.y *0.5)];
        [contactsTableView setFrame:CGRectMake(0,0,self.view.frame.size.width * 0.9,self.view.frame.size.height*0.4)];
        
    }];
    [contactsTableView setCenter:CGPointMake(self.view.center.x,
                                             self.navigationController.toolbar.frame.origin.y - contactsTableView.center.y)];
    
    
    [[[UIAlertView alloc] initWithTitle: @"Notifications Sent"
                                message: @"Your core circle has been notified!"
                               delegate: nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}
#pragma mark - Helper methods
- (NSString *) stripStringOfUnwantedChars:(NSString *)phoneNumber {
    NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    return cleanedString;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"contacts %d",helpMeNowContactsArr.count);
    return helpMeNowContactsArr.count;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Emergency Contacts";
}


- (UITableViewCell *)tableView:(UITableView *)theTableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"Cell"];
    }
    
    if (indexPath.section == 0 ) {
        // Configure the cell...
        NSLog(@"%@",[helpMeNowContactsArr objectAtIndex:indexPath.row]);
        cell.textLabel.text = [helpMeNowContactsArr objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:14.0];
        UILabel *composeBtn = [[UILabel alloc] initWithFrame:CGRectZero];
        [composeBtn setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:22.0]];
        [composeBtn setText:@"📞"];
        [composeBtn setTextAlignment:NSTextAlignmentRight];
        [composeBtn setTextColor:[UIColor blueColor]];
        [composeBtn setFrame:CGRectMake(0,0,cell.frame.size.height,cell.frame.size.height)];
        cell.accessoryView = composeBtn;
        //cell.accessoryType = UITableViewCellAccessoryDetailButton;
        
        cell.textLabel.textColor = [UIColor blackColor];
        UIButton *mLocBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 38, 38)];
        UIImage *img =[[FRStringImage alloc] imageWithString:@"👤"
                                                        font:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:22.0]
                                                        size:mLocBtn.frame.size];
        cell.imageView.image     = img;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog (@"%@", [helpMeNowContactsArr objectAtIndex:indexPath.row]);
    
    NSDictionary *coreFriendsDic = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"CoreFriendsContactInfoDicKey"];
    NSLog(@"%@", [coreFriendsDic objectForKey:[helpMeNowContactsArr objectAtIndex:indexPath.row]]);
    if (indexPath.row == 3)
    {
        NSString *phoneNumber = [NSString stringWithFormat:@"tel://1-574-631-5555"];
        @try {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
        }
        @finally {
            NSLog(@"Call: %@",[NSString stringWithFormat:@"tel://1-574-631-5555"]);}
    } else {
        NSString *phoneNumber = [NSString stringWithFormat:@"tel://%@",[coreFriendsDic objectForKey:[helpMeNowContactsArr objectAtIndex:indexPath.row]]];
        @try {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
        }
        @finally {
            NSLog(@"Call: %@",[NSString stringWithFormat:@"tel://%@",[coreFriendsDic objectForKey:[helpMeNowContactsArr objectAtIndex:indexPath.row]]]);}
    }
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
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end
