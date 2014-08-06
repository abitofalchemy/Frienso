//
//  FriensoViewController.m
//  FriensoAlpha
//
//  Created by Sal Aguinaga on 2/26/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//
/*  Actions:
 *  helpMeNowSwitchAction:(UISwitch*)sender
 *      This is intended to turn off the switch and trigger notifications that everthing is ok
 *      Will send PN and SMS?  Should it be controlled from the settings btn?
 *
 ** */

#import "FriensoViewController.h"
#import "FriensoOptionsButton.h"
#import "FriensoCircleButton.h"
#import <QuartzCore/QuartzCore.h>
#import "FriensoAppDelegate.h"
#import "FriensoEvent.h"
#import "CoreFriends.h"
#import "FRCoreDataParse.h"
#import "GeoPointAnnotation.h"
#import "GeoCDPointAnnotation.h"
#import "GeoQueryAnnotation.h"
#import "FriensoResources.h"
#import "FRStringImage.h"
#import "CloudUsrEvnts.h"
#import "FRSyncFriendConnections.h"
#import "UserResponseScrollView.h"
#import "PendingRequestButton.h"
#import "FriensoQuickCircleVC.h"
#import "ProfileSneakPeekView.h"
#import "UserProfileViewController.h"
#import <AddressBook/AddressBook.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define MAPVIEW_DEFAULT_BOUNDS  CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height * 0.5)
#define ARC4RANDOM_MAX  0x100000000
#define UIColorFromRGB(rgbValue)  [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define CELL_CONTENT_MARGIN  10.0f

static NSString *eventCell          = @"eventCell";
static NSString *trackRequest       = @"trackRequest";
static NSString *coreFriendRequest  = @"coreFriendRequest";
static NSString *watchLocation      = @"";

enum PinAnnotationTypeTag {
    PinAnnotationTypeTagGeoPoint = 0,
    PinAnnotationTypeTagGeoQuery = 1
};


@interface FriensoViewController ()
{
    NSMutableArray *coreFriendsArray;
    UISwitch       *trackMeOnOff;
    UIGestureRecognizer *navGestures;
}

@property (nonatomic,strong) UIButton *coreCircleBtn;
@property (nonatomic,strong) NSFetchedResultsController *frc;
@property (nonatomic,strong) UIActivityIndicatorView    *loadingView;
@property (nonatomic,strong) UserResponseScrollView     *scrollView;
@property (nonatomic,retain) NSArray        *appFrameProperties;
@property (nonatomic,retain) NSMutableArray *friendsLocationArray;
@property (nonatomic,retain) NSMutableArray *pendingRqstsArray; // pending requests array
@property (nonatomic,retain) NSMutableArray *watchingCoFrArray; // watching coreFriends array
@property (nonatomic,strong) CLLocation     *location;
@property (nonatomic,assign) CLLocationDistance radius;
@property (nonatomic,strong) UITableView    *tableView;
@property (nonatomic,strong) UIButton       *selectedBubbleBtn;
@property (nonatomic,strong) UIButton       *fullScreenBtn;
@property (nonatomic,strong) ProfileSneakPeekView *profileView;
@property (nonatomic,strong) UISwitch       *trackMeOnOff;
@property (nonatomic,strong) UILabel        *drawerLabel;
@property (nonatomic)        CGFloat scrollViewY;
@property (nonatomic)        CGRect normTableViewRect;
@property (nonatomic) const CGFloat mapViewHeight;


-(void)actionPanicEvent:(UIButton *)theButton;
-(void)viewMenuOptions: (UIButton *)theButton;
-(void)viewCoreCircle:  (UIButton *)theButton;
-(void)makeFriensoEvent:(UIButton *)theButton;
-(void)navigationCtrlrSingleTap;

@end

@implementation FriensoViewController
@synthesize locationManager  = _locationManager;
@synthesize trackMeOnOff     = _trackMeOnOff;
//@synthesize helpMeNowSwitch  = _helpMeNowSwitch;

/** useful calls:
 ** CGRect fullScreenRect=[[UIScreen mainScreen] applicationFrame];
 ** **/

-(void)navigationCtrlrSingleTap {
    NSLog(@"Tapped: %.2f", self.navigationController.navigationBar.frame.size.height);
    self.profileView = [[ProfileSneakPeekView alloc] initWithFrame:self.navigationController.navigationBar.frame];
    [self.profileView setUserEmailString:@"saguinag" withPhoneNumber:@"5743394087"];
    [self.view addSubview:self.profileView];

}
-(void)actionPanicEvent:(UIButton *)theButton {
//    [self animateThisButton:theButton];
//    [theButton setHidden:YES];
//    [theButton.layer setBorderColor:[UIColor redColor].CGColor];
    [self performSegueWithIdentifier:@"panicEvent" sender:self];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:self.navigationItem.backBarButtonItem.style
                                                                            target:nil
                                                                            action:nil];
}
-(void) setupHelpMeNowSwitch
{
    helpMeNowSwitch = [[UISwitch alloc] init];
    [helpMeNowSwitch addTarget:self action:@selector(helpMeNowSwitchAction:)
           forControlEvents:UIControlEventValueChanged];
    helpMeNowSwitch.layer.cornerRadius = helpMeNowSwitch.frame.size.height/2.0;
    helpMeNowSwitch.layer.borderWidth =  1.0;
    helpMeNowSwitch.layer.borderColor = [UIColor whiteColor].CGColor;
    [helpMeNowSwitch setCenter:CGPointMake(self.navigationController.toolbar.center.x, 22)];
    [helpMeNowSwitch setOn:NO animated:YES];
    [helpMeNowSwitch setOnTintColor:[UIColor redColor]];
    [helpMeNowSwitch setBackgroundColor:[UIColor clearColor]];
    [self.navigationController.toolbar addSubview:helpMeNowSwitch];
    if (DBG) NSLog(@"[self.navigationController.toolbar addSubview:helpMeNowSwitch]");
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    [label setText:@"help"];
    [label setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:11.0]];
    [label sizeToFit];
    [label setTag:100];
    [label setCenter:CGPointMake(label.center.x+4.0f, label.center.y + 9)];
    [helpMeNowSwitch addSubview:label];
}
-(void)makeFriensoEvent:(UIButton *)theButton {
    [self animateThisButton:theButton];
    [self performSegueWithIdentifier:@"createEvent" sender:self];
}

-(void)viewMenuOptions:(UIButton *)theButton {
    [self animateThisButton:theButton];
    [self performSegueWithIdentifier:@"showMenuOptions" sender:self];
    [theButton.layer setBorderColor:[UIColor grayColor].CGColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:self.navigationItem.backBarButtonItem.style
                                                                            target:nil
                                                                            action:nil];
}

-(void)viewCoreCircle:(UIButton *)theButton {
    [self animateThisButton:theButton];
    [self performSegueWithIdentifier:@"showMyCircle" sender:self];
    [theButton setEnabled:NO];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:self.navigationItem.backBarButtonItem.style
                                                                            target:nil
                                                                            action:nil];
}


- (NSManagedObjectContext *) managedObjectContext{
    
    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
    
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.frc sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.frc.sections[section];
    return sectionInfo.numberOfObjects;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    FriensoEvent *event = [self.frc objectAtIndexPath:indexPath];
    if([event.eventCategory isEqualToString:@"general"] || [event.eventCategory isEqualToString:@"und"])
        return [tableView rowHeight]*2.0f + CELL_CONTENT_MARGIN;
    else
        return [tableView rowHeight];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:eventCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:eventCell];
    }
    [cell setTag:0];
    FriensoEvent *event = [self.frc objectAtIndexPath:indexPath];

    cell.textLabel.text = event.eventTitle;// stringByAppendingFormat:@" %@", person.lastName];
    cell.textLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:14.0];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",event.eventSubtitle];
    
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.textColor  = UIColorFromRGB(0x83b5dd);
    cell.textLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:10.0];
    cell.detailTextLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:10.0];
    if ([event.eventCategory isEqualToString:@"calendar"]) {
        cell.imageView.image = [self imageWithBorderFromImage:[UIImage imageNamed:@"cal-ic-24.png"]];
        cell.backgroundColor = [UIColor clearColor];
    } else if ([event.eventCategory isEqualToString:@"general"] ||
               [event.eventCategory isEqualToString:@"und"]) {
        [cell.textLabel setNumberOfLines:3];
        [cell.detailTextLabel setNumberOfLines:3];
        NSURL *imageURL = [NSURL URLWithString:event.eventImage];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage *img = [UIImage imageWithData:imageData];
        cell.imageView.image = [self imageWithBorderFromImage:img];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setTag:10];
    } else {
        cell.imageView.image = [self imageWithBorderFromImage:[UIImage imageNamed:@"profile-24.png"]];
        cell.backgroundColor = [UIColor clearColor];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (DBG) NSLog(@"%ld", (long)[tableView cellForRowAtIndexPath:indexPath].tag);
    switch ([tableView cellForRowAtIndexPath:indexPath].tag)
    {
        case 10:
            [self performSegueWithIdentifier:@"instResources" sender:self];
            break;
        default:
            break;
    }
}

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    CGRect  fullScreenRect=[[UIScreen mainScreen] applicationFrame];
    CGFloat tvFrameOriginOffset_y = fullScreenRect.size.height *0.05;
    if (DBG) NSLog(@"table view origin %f", self.tableView.frame.origin.y);
    
    if (scrollView.contentOffset.y == 0 && (self.tableView.frame.origin.y > fullScreenRect.size.height/2.0))
    {
        
        [UIView animateWithDuration:0.5 animations:^{
            CGFloat tvFrameWidth = self.tableView.frame.size.width;
            CGRect tvNewFrame1 = CGRectMake(self.tableView.frame.origin.x+tvFrameWidth*0.1,
                                            self.tableView.frame.origin.y,
                                            self.tableView.frame.size.width * 0.8,
                                            self.tableView.frame.size.height);
            [self.tableView setFrame:tvNewFrame1];
            self.tableView.layer.borderWidth = 1.0;
            self.tableView.layer.borderColor = [UIColor darkGrayColor].CGColor;
            
            [self.tableView setFrame:CGRectMake(0, fullScreenRect.origin.y + tvFrameOriginOffset_y,
                                                fullScreenRect.size.width, fullScreenRect.size.height*.9)];
            
            UIButton *tvHeaderView = [UIButton buttonWithType:UIButtonTypeCustom];
            [tvHeaderView setFrame:CGRectMake(0,0,self.view.bounds.size.width,self.tableView.frame.origin.y)];
            [tvHeaderView setBackgroundColor:[UIColor blackColor]];
            [tvHeaderView.titleLabel setTextAlignment:NSTextAlignmentRight];
            [tvHeaderView setTitle:@"╳ Dismiss" forState:UIControlStateNormal];
            [tvHeaderView addTarget:self action:@selector(closeFullscreenTableViewAction:)
                   forControlEvents:UIControlEventTouchUpInside];//tvFSCloseAction) withSender:self];
            [self.view addSubview:tvHeaderView];
            }];
    }

}

#pragma mark - NSFetchResultsController delegate methods
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

#pragma mark - Local Actions
//- (void) locateCoreFriends {
//    //if (DBG) NSLog(@"! Locate Core Friends");
//    NSString *helpObjId = [[NSUserDefaults standardUserDefaults] objectForKey:@"helpObjId"];
//    if (helpObjId != nil ) {
//        if (DBG) NSLog(@"    We have an active helpMeNow event");
//    } else
//        if (DBG) NSLog(@"    NO active helpMeNow event");
//    
//    //    // round up your core Friends and show them on the map and have access to their location
////    // First check to see if the objectId already exists
//    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"FriensoEvent"
//                                                         inManagedObjectContext:[self managedObjectContext]];
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    [request setPredicate:[NSPredicate predicateWithFormat:@"eventCategory like 'helpNow'"]];
//    [request setEntity:entityDescription];
//    // Create the sort descriptors array.
//    NSSortDescriptor *authorDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eventCreated" ascending:NO];
//    NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eventModified" ascending:NO];
//    NSArray *sortDescriptors = @[authorDescriptor, titleDescriptor];
//    [request setSortDescriptors:sortDescriptors];
//
//    //BOOL unique = YES;
//    NSError  *error;
//    NSArray *items = [[self managedObjectContext] executeFetchRequest:request error:&error];
//    if (DBG) NSLog(@"items: %u", items.count);
//    if (items != nil) {
//        for (NSManagedObject *mObject in items) {
//            if (DBG) NSLog(@"  %@,%@,%@,%@",[mObject valueForKey:@"eventTitle"],[mObject valueForKey:@"eventObjId"],
//                  [mObject valueForKey:@"eventCategory"],[mObject valueForKey:@"eventModified"]);
//        }
//    }
//#warning Add a status to the FriensoEvent entity to maintain the status of the event
//#warning Disable when the user turns off the button; remove coreFriends from mapView
//    
//}
-(void) helpMeNowSwitchAction:(UISwitch*)sender
{
    if ([sender isOn]) {
        for (id subview in [sender subviews])
        {
            UILabel *label = subview;
            if (label.tag > 99)
                [label removeFromSuperview];
        }
        [self actionPanicEvent:nil];
    } else  {
        // log event on the cloud
        CloudUsrEvnts *helpMeEvent = [[CloudUsrEvnts alloc] initWithAlertType:@"helpNow"];
        [helpMeEvent disableEvent];
        
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"helpObjId"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        // switch from ON to OFF
        [helpMeNowSwitch setOn:NO animated:YES];
        // Remove buttons and labels corresponding to coreFriends
        for (id subview in [self.mapView subviews])
        {
            UILabel *label = subview;
            if (label.tag > 99)
                [label removeFromSuperview];
        }
    }
}
-(void) contactByDialingFriendWithEmail:(NSString *)friendEmail
{
    PFQuery *query= [PFUser query];
    [query whereKey:@"username" equalTo:friendEmail];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error)
        {
            //if (DBG) NSLog(@"%@", [object objectForKey:@"phoneNumber"]);
            NSString *phoneNumber = [NSString stringWithFormat:@"tel://%@",[object objectForKey:@"phoneNumber"]];
            @try {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
            }
            @catch (NSException *exception){
                if (DBG) NSLog(@"%@", exception.reason);
            }
            @finally {
                if (DBG) NSLog(@"Calling: %@",friendEmail);
            }
            
        }
        
    }];
    
}
-(void) contactBySMSingFriendWithEmail:(NSString *)friendEmail
{
    /*  the query is not working
        might want to consider querying coreData */
    //if (DBG) NSLog(@"friend email: %@", friendEmail);
    PFQuery *query= [PFUser query];
    [query whereKey:@"username" equalTo:friendEmail];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error)
        {
            //if (DBG) NSLog(@"%@", [object objectForKey:@"phoneNumber"]);
            NSString *phoneNumber = [object objectForKey:@"phoneNumber"];
            // You must check that the current device can send SMS messages before you
            // attempt to create an instance of MFMessageComposeViewController.  If the
            // device can not send SMS messages,
            // [[MFMessageComposeViewController alloc] init] will return nil.  Your app
            // will crash when it calls -presentViewController:animated:completion: with
            // a nil view controller.
            if ([MFMessageComposeViewController canSendText])
            {   // The device can send SMS
                MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
                picker.messageComposeDelegate = self;
                
                // You can specify one or more preconfigured recipients.  The user has
                // the option to remove or add recipients from the message composer view
                // controller.
                
                // You can specify the initial message text that will appear in the message
                // composer view controller.
                // picker.body = @"Are you Okay?";
                /* picker.recipients = @[@"Phone number here"]; */
                picker.recipients = @[phoneNumber];
                
                [self presentViewController:picker animated:YES completion:NULL];
            }
            else
                // The device can not send email.
            {
                //        self.feedbackMsg.hidden = NO;
                //		self.feedbackMsg.text = @"Device not configured to send SMS.";
                if (DBG) NSLog(@"Device not configured to send SMS.");
            }
            
            
        }
     
    }];
    
}
-(void) updateMapViewWithUserBubbles:(NSMutableArray *)trackingFriendsArray
{
    for (id subview in [self.mapView subviews]){
        if ( [subview isKindOfClass:[TrackingFriendButton class]] )
        {
            [subview removeFromSuperview];
        }
    }
    
    
    if (!DBG) NSLog(@"Friends I currently track:");
    NSLog(@"%ld", (long) trackingFriendsArray.count);
    
    NSInteger btnNbr = 0;
    for (PFUser *parseUser  in trackingFriendsArray)
    {
        if (!DBG) NSLog(@"  %@", parseUser.username);
        TrackingFriendButton *mLocBtn = [[TrackingFriendButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        UIImage *img =[[FRStringImage alloc] imageTextBubbleOfSize:mLocBtn.frame.size];
        [mLocBtn setBackgroundImage:img forState:UIControlStateNormal];
        [mLocBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [mLocBtn setTitleColor:UIColorFromRGB(0x8e44ad) forState:UIControlStateHighlighted];
        [mLocBtn setAlpha:0.8];
        [mLocBtn addTarget:self action:@selector(friendLocInteraction:)
          forControlEvents:UIControlEventTouchUpInside];
        [self.mapView addSubview:mLocBtn];
        NSString *bubbleLabel = [[parseUser.username substringToIndex:2] uppercaseString];
        [mLocBtn setTitle:bubbleLabel forState:UIControlStateNormal];
        [mLocBtn setTag:btnNbr];
        
        CGFloat marginOffset = 5.0;
        CGFloat btnCenterX   = mLocBtn.center.x + mLocBtn.center.x*2*btnNbr + marginOffset;
        [mLocBtn setCenter:CGPointMake(btnCenterX, self.mapView.frame.size.height - mLocBtn.center.y*2)];
        
        // Allows access to location info to userBubble
        PFGeoPoint *geoNDIN = [PFGeoPoint geoPointWithLatitude:41.702652
                                                     longitude:-86.239450];// notre dame, in

        [self.friendsLocationArray addObject:([parseUser valueForKey:@"currentLocation"] == NULL)  ? geoNDIN : [parseUser valueForKey:@"currentLocation"]];
        btnNbr++;
    }
    
}
// move to more appropritate spot
- (void) findInFriensoEvents:(PFUser*)parseUser {
    // Search locally for the type of event this user has triggered & we are watching
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"FriensoEvent"
                                                         inManagedObjectContext:[self managedObjectContext]];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPredicate:[NSPredicate predicateWithFormat:@"eventContact like %@",parseUser.username]];
    [request setEntity:entityDescription];
    // Create the sort descriptors array.
    NSSortDescriptor *dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eventCreated" ascending:NO];
    NSArray *sortDescriptors = @[dateDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSError  *error;
    NSArray *items = [[self managedObjectContext] executeFetchRequest:request error:&error];
    if (!DBG) NSLog(@"items: %ld", (unsigned long)items.count);
    //        if (items != nil) {
    //            for (NSManagedObject *mObject in items) {
    //                if (DBG) NSLog(@"  %@,%@,%@,%@",[mObject valueForKey:@"eventTitle"],[mObject valueForKey:@"eventObjId"],
    //                               [mObject valueForKey:@"eventCategory"],[mObject valueForKey:@"eventModified"]);
    //            }
    //        }
}
-(void) addCoreFriendLocationToMap:(PFUser *)parseUser withIndex:(NSInteger)mapIndex
{
    CGPoint refreshLoc;
    for (id subview in [self.mapView subviews]){
        if ( [subview isKindOfClass:[UIButton class]]
            && [[subview titleLabel].text isEqualToString:@"↺"] )
        {
            UIButton *refreshMap = (UIButton *)subview;
            refreshLoc = refreshMap.center;
        }
        
    }
    TrackingFriendButton *cfCircleBtn = [[TrackingFriendButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    UIImage *img =[[FRStringImage alloc] imageTextBubbleOfSize:cfCircleBtn.frame.size];
    [cfCircleBtn setBackgroundImage:img forState:UIControlStateNormal];
    [cfCircleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cfCircleBtn setTitleColor:UIColorFromRGB(0x8e44ad) forState:UIControlStateHighlighted];
    [cfCircleBtn setAlpha:0.8];
    
    PFGeoPoint *geoPoint = [parseUser objectForKey:@"currentLocation"];
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:geoPoint.latitude
                                                  longitude:geoPoint.longitude];
    PFGeoPoint *myPointLoc = [[PFUser currentUser] objectForKey:@"currentLocation"];
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:myPointLoc.latitude
                                                  longitude:myPointLoc.longitude];
    CLLocationDistance distance = [locA distanceFromLocation:locB] * 0.000621371 /* convert to miles */;
    //  NSString *coreFriendDistance = [NSString stringWithFormat:@"%.2f %@ away",distance,@"miles" ];
    
    [cfCircleBtn addTarget:self action:@selector(coreFriendOnMapInteraction:)
      forControlEvents:UIControlEventTouchUpInside];
    [cfCircleBtn setTag:mapIndex+100];
    
    [self.mapView addSubview:cfCircleBtn];
    NSString *bubbleLabel = [[parseUser.username substringToIndex:2] uppercaseString];
    [cfCircleBtn setTitle:[NSString stringWithFormat:@"%@\n%.2f",bubbleLabel,distance] forState:UIControlStateNormal];
    //[cfCircleBtn setSubTitle:coreFriendDistance];
//    [cfCircleBtn setTag:btnNbr];
//    CGFloat marginOffset = 5.0;
//    CGFloat btnCenterX   = cfCircleBtn.center.x + cfCircleBtn.center.x*2*btnNbr + marginOffset;
//    //[cfCircleBtn setCenter:CGPointMake(btnCenterX, self.mapView.frame.size.height - cfCircleBtn.center.y)];
    CGFloat frienYPoint = refreshLoc.y*2 + (cfCircleBtn.center.y*1.5 + 10/*y offset*/) * mapIndex;
    //[coreFriendMapLabel setCenter:CGPointMake(refreshLoc.x + coreFriendMapLabel.center.x , frienYPoint)];
    [cfCircleBtn setCenter:CGPointMake(refreshLoc.x, frienYPoint)];
//
//    
//    // Allows access to location info to userBubble
//    PFGeoPoint *geoNDIN = [PFGeoPoint geoPointWithLatitude:41.702652
//                                                 longitude:--86.239450];// notre dame, in
//    [self.friendsLocationArray insertObject:([parseUser valueForKey:@"currentLocation"] == NULL)  ? geoNDIN : [parseUser valueForKey:@"currentLocation"]  atIndex:btnNbr];
//    
//    NSString *twoInitials = [parseUser.username substringToIndex:2];
//    //[coreFriendMapLabel setText:[twoInitials uppercaseString]];

//    [coreFriendMapLabel setText:[NSString stringWithFormat:@"%@, %@",[twoInitials uppercaseString],
//                                 coreFriendDistance]];
//    [coreFriendMapLabel sizeToFit];
//    [self.mapView addSubview:coreFriendMapLabel];
//    CGFloat frienYPoint = refreshLoc.y*2 + (coreFriendMapLabel.center.y + 10/*y offset*/) * mapIndex;
//    [coreFriendMapLabel setCenter:CGPointMake(refreshLoc.x + coreFriendMapLabel.center.x , frienYPoint)];
    

}
-(void) addUserBubbleToMap:(PFUser *)parseUser withTag:(NSInteger)tagNbr {
    
    //    if (DBG) NSLog(@"add User Bubble To Map: %ld",tagNbr);
    //    if (DBG) NSLog(@"subviews: %ld", [self.mapView subviews].count);
    //
    for (id subview in [self.mapView subviews]){
        if ( [subview isKindOfClass:[UIButton class]] )
        {
            //if (DBG) NSLog(@"subview tag: %ld", [subview tag]);
            if ([subview tag] > 0)
                tagNbr +=1;
        }
    }

    UIButton *mLocBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    UIImage *img =[[FRStringImage alloc] imageTextBubbleOfSize:mLocBtn.frame.size];
    [mLocBtn setBackgroundImage:img forState:UIControlStateNormal];
    NSString *bubbleLabel = [[parseUser.username substringToIndex:2] uppercaseString];
    [mLocBtn setTitle:bubbleLabel forState:UIControlStateNormal];
    
    [mLocBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [mLocBtn setTitleColor:UIColorFromRGB(0x8e44ad) forState:UIControlStateHighlighted];
    [mLocBtn setAlpha:0.8];
    [mLocBtn setTag:tagNbr];
    [mLocBtn addTarget:self action:@selector(friendLocInteraction:)
      forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:mLocBtn];
    
    CGFloat btnCenterX = mLocBtn.center.x*2 + mLocBtn.center.x*2*tagNbr;
    [mLocBtn setCenter:CGPointMake(btnCenterX, self.mapView.frame.size.height - mLocBtn.center.y)];
    
    
    /* HOW DO WE GIVE BUTTON ACCESS TO user's Location?
     *
    // Allows access to location info to userBubble
    PFGeoPoint *geoNDIN = [PFGeoPoint geoPointWithLatitude:41.702652
                                                 longitude:--86.239450];// notre dame, in
    [self.friendsLocationArray insertObject:([parseUser valueForKey:@"currentLocation"] == NULL)  ? geoNDIN : [parseUser valueForKey:@"currentLocation"]  atIndex:tagNbr];
    */
}
-(void) closeFullscreenTableViewAction:(UIButton*)sender {
    [UIView animateWithDuration:0.3 animations:^{
        [self.tableView setFrame:self.normTableViewRect];
        [sender removeFromSuperview];
    }];
    
}
-(void) pendingRqstAction:(id) sender {
    UIButton *btn = (UIButton *) sender;
    if (DBG) NSLog (@"pendingRqstAction ... ");
    
    //NSDictionary *frUserDic = [self.pendingRqstsArray objectAtIndex:btn.tag]; // 10Jun14:SA
    PFObject *frUserEventObj = [self.pendingRqstsArray objectAtIndex:btn.tag]; // 10Jun14:SA
    PFUser *friensoUser = [frUserEventObj objectForKey:@"friensoUser"];  // 10Jun14:SA
    NSString * type = [frUserEventObj objectForKey:@"eventType"];
    if (DBG) NSLog (@"Request type: %@", type );
    
    if([type isEqualToString:coreFriendRequest]) { //if core friend request
        //TODO: we do not need to add the btn.tag here.
        //may be we can extend UIAlertView and add a variable for the index.
        //if (DBG) NSLog(@"btn tag = %d",btn.tag);
        UIAlertView *coreFriendRequestAlertView =
        [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Core Friend Request:%2ld",(long)btn.tag]
                                    message:[NSString stringWithFormat:@"from %@",friensoUser.username]
                                   delegate:self
                          cancelButtonTitle:@"Dismiss"
                         otherButtonTitles:@"Accept",@"Reject", nil];
        [coreFriendRequestAlertView setTag:btn.tag];
        [coreFriendRequestAlertView show];
        
    } else { // for watch or anything else.
        UIAlertView *watchMeRequestAlertView =
        [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Pending Request:%2ld",(long)btn.tag]
                                    message:[NSString stringWithFormat:@"from %@",friensoUser.username]
                                   delegate:self
                          cancelButtonTitle:@"Dismiss"
                         otherButtonTitles:@"Accept",@"Reject", nil];
        [watchMeRequestAlertView setTag:btn.tag];
        [watchMeRequestAlertView show];
    }
}
-(void) refreshMapViewAction:(UIButton*) sender
{
    [self animateThisButton:sender];
    
    [self.pendingRqstsArray removeAllObjects];
    
    // clean the drawer
    for (id subview in [self.scrollView subviews]){
        if ( [subview isKindOfClass:[PendingRequestButton class]] )
        {
            [subview removeFromSuperview];
        }
    }
    
    
    // clean the mapview
    [self.watchingCoFrArray removeAllObjects];
    for (id subview in [self.mapView subviews]){
        if ( [subview isKindOfClass:[TrackingFriendButton class]] )
        {
            [subview removeFromSuperview];
        }
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"adminID"] != NULL)
        [self configureOverlay];
}

-(void) openCloseDrawer
{

    // 16Jun14:SA   - fixed drawer not working on iPhone4, still need to check it works in iPad mini
    CGFloat yOffset = self.view.frame.size.height*0.15;
    CGFloat y_tableViewOffset = yOffset - _drawerLabel.frame.size.height*0.9;
    
    if (self.scrollView.frame.size.height> self.drawerLabel.frame.size.height*1.5)
    {
        [UIView animateWithDuration:0.5 animations:^{
        CGRect closeDrawerRect = CGRectMake(0, self.scrollView.frame.origin.y, self.view.bounds.size.width,_drawerLabel.frame.size.height*0.9);
        [self.scrollView setFrame:closeDrawerRect];
        self.scrollView.contentSize = self.scrollView.frame.size;
        
        [_drawerLabel setTextColor:[UIColor whiteColor]];
        [self.tableView setCenter:CGPointMake(self.tableView.center.x, self.tableView.center.y - y_tableViewOffset)];// remove tableview yOffset
        }];
    } else { // Open Drawer
        
        [UIView animateWithDuration:0.5 animations:^{
            CGRect openDrawerRect = CGRectMake(0, self.scrollView.frame.origin.y, self.view.frame.size.width,
                                               yOffset);
            [self.tableView setCenter:CGPointMake(self.tableView.center.x, self.tableView.center.y + y_tableViewOffset)];
            [self.scrollView setFrame:openDrawerRect];
            self.scrollView.contentSize = self.scrollView.frame.size;
            [_drawerLabel setTextColor:[UIColor darkGrayColor]];
            
        }];
        
    }
}

-(void) mapViewFSToggle:(UIButton *) sender {
    [self animateThisButton:sender];
    if (self.mapView.frame.size.height < self.view.bounds.size.height){
        [self.mapView setFrame:self.view.bounds];
        [self.fullScreenBtn setTitle:@"⇱"/*@""*/ forState:UIControlStateNormal];
        [self.fullScreenBtn sizeToFit];
        [self.fullScreenBtn.titleLabel setTextColor:[UIColor blackColor]];
        [self.fullScreenBtn setCenter:CGPointMake(self.fullScreenBtn.center.x,40.0)];
        [self.tableView setHidden:YES];
        [self openCloseDrawer];
        [self.scrollView setCenter:CGPointMake(self.view.center.x, self.navigationController.toolbar.frame.origin.y - self.scrollView.frame.size.height*1.5)];
    } else { // fullscreen
        //[self.mapView setFrame:MAPVIEW_DEFAULT_BOUNDS];
        [self.mapView setFrame:CGRectMake(0,0,self.view.frame.size.width, self.mapViewHeight)];
        
        [self.fullScreenBtn setTitle:@"⇲"/*@""*/ forState:UIControlStateNormal];
        [self.fullScreenBtn sizeToFit];
        [self.fullScreenBtn setCenter:CGPointMake(_fullScreenBtn.center.x,
                                                  self.mapView.frame.size.height -_fullScreenBtn.frame.size.height/2 * 1.2) ];
        [self.fullScreenBtn.titleLabel setTextColor:[UIColor blackColor]];
        [self.tableView setHidden:NO];
        [self openCloseDrawer];
        CGRect fullScreenRect=[[UIScreen mainScreen] applicationFrame];
        [self.scrollView setCenter:CGPointMake(fullScreenRect.size.width/2.0, self.scrollViewY)];
        
    }
}
-(void) addPendingRequest:(NSArray*)userRequestArray {

    if (!DBG) NSLog(@"addPendingRequest: userRequestArray count: %ld--", (long)[userRequestArray count]);
    [self.scrollView setPendingRequests:self.pendingRqstsArray];
    NSInteger arrayIndex = 0;
    for (PFObject *eventObject in userRequestArray)
    {
        NSString *reqType = ([eventObject valueForKey:@"eventType"]==NULL) ? coreFriendRequest :
                            [eventObject valueForKey:@"eventType"];
        PFUser   *friensoUser = ([eventObject objectForKey:@"friensoUser"] == NULL) ? [eventObject objectForKey:@"sender"] : [eventObject objectForKey:@"friensoUser"];
        if (!DBG) NSLog(@"{%@} requesting: <%@>", friensoUser.username, reqType);
        [self addPendingRequest:friensoUser
                        withTag:arrayIndex
                        reqtype:reqType];
        arrayIndex++;
        
    }
}
-(void) addPendingRequest:(PFUser *)parseFriend withTag:(NSInteger)tagNbr reqtype:(NSString *)type{
    if ([type isEqualToString:@"helpNow"]) {
        [self addPndngRqstButton:[UIColor redColor] withFriensoUser:parseFriend withTag:tagNbr ofType:type];
    } else if ([type isEqualToString:@"coreFriendRequest"]) {
        [self addPndngRqstButton:[UIColor greenColor]
                 withFriensoUser:parseFriend
                         withTag:tagNbr
                          ofType:type];
    } else {
        [self addPndngRqstButton:[UIColor whiteColor] withFriensoUser:parseFriend withTag:tagNbr ofType:type];
        
        PFGeoPoint *geoNDIN = [PFGeoPoint geoPointWithLatitude:41.702652
                                                      longitude:-86.239450];// notre dame, in
        //NSLog(@"[1] tag#:%ld", tagNbr);
//        [self.friendsLocationArray insertObject:([parseFriend valueForKey:@"currentLocation"] == NULL)  ? geoNDIN  : [parseFriend valueForKey:@"currentLocation"]  atIndex:tagNbr];
        [self.friendsLocationArray addObject:([parseFriend valueForKey:@"currentLocation"] == NULL)  ? geoNDIN  : [parseFriend valueForKey:@"currentLocation"]];
    }
}

- (void) addPndngRqstButton: (UIColor *) fontColor  withFriensoUser:(PFUser *)parseFriend withTag:(NSInteger)tagNbr ofType:(NSString *)eventType{
    // addPendingRequest  adds a pending request to drawer+slider that user can interact w/ Pfuser
    PendingRequestButton *pndngRqstBtn= [[PendingRequestButton alloc] initWithFrame:CGRectMake(0,0,44,44)];
    UIImage *img =[[FRStringImage alloc] imageTextBubbleOfSize:pndngRqstBtn.frame.size];
    [pndngRqstBtn setBackgroundImage:img forState:UIControlStateNormal];
    NSString *bubbleLabel = [[parseFriend.username substringToIndex:2] uppercaseString];
    [pndngRqstBtn setTitle:bubbleLabel forState:UIControlStateNormal];
    [pndngRqstBtn setTitleColor:fontColor forState:UIControlStateNormal];
    [pndngRqstBtn setTitleColor:UIColorFromRGB(0x8e44ad) forState:UIControlStateHighlighted];
    [pndngRqstBtn setTag:tagNbr];
    if ([eventType isEqualToString:@"helpNow"]){
        pndngRqstBtn.layer.borderColor = [UIColor blueColor].CGColor;
        pndngRqstBtn.layer.borderWidth = 1.5f;
        pndngRqstBtn.layer.cornerRadius = pndngRqstBtn.center.x;
    }
    [pndngRqstBtn addTarget:self action:@selector(pendingRqstAction:)
           forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:pndngRqstBtn];
    
    CGFloat btnCenterX = pndngRqstBtn.center.x*2 + pndngRqstBtn.center.x*2*tagNbr;
    //if (DBG) NSLog(@"%f",self.scrollView.frame.size.height*1.6);
    [pndngRqstBtn setCenter:CGPointMake(btnCenterX, pndngRqstBtn.center.y*1.3)];
}



-(void) trackMeSwitchEnabled:(UISwitch *)sender {
    if (DBG) NSLog(@"********* trackMeswitchEnabled ****");
    
    if ([sender isOn]){
        for (id subview in [sender subviews])
        {
            UILabel *label = subview;
            if (label.tag > 99)
                [label removeFromSuperview];
        }
        // Alert the user
        [[[UIAlertView alloc] initWithTitle:@"WatchMe"
                                    message:@"CoreCircle of friends will be notified and your location shared."
                                   delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Okay", nil] show];
        
        UILabel *trackMeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [trackMeLabel setText:@"Watch Me"];
        [trackMeLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:12.0]];
        [trackMeLabel setTextAlignment:NSTextAlignmentCenter];
        [trackMeLabel setBounds:CGRectMake(0, 0, sender.bounds.size.width*1.2, sender.bounds.size.height)];
        trackMeLabel.layer.cornerRadius = sender.frame.size.height/2.0;
        trackMeLabel.layer.borderWidth =  1.0;
        trackMeLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        trackMeLabel.layer.masksToBounds = YES;
        [self.navigationController.navigationBar addSubview:trackMeLabel];
        [trackMeLabel setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
        [trackMeLabel setCenter:sender.center];

        // animate help
        [self animateHelpView:trackMeLabel];
        [UIView animateWithDuration:3.0
                         animations:^{trackMeLabel.alpha = 0.0;}
                         completion:^(BOOL finished){ [trackMeLabel removeFromSuperview]; }];
        
        
    } else {
        if (DBG) NSLog(@"Stop the watchMe event");
        [[[UIAlertView alloc] initWithTitle:@"WatchMe"
                                    message:@"Your location sharing will stop"
                                   delegate:self
                          cancelButtonTitle:@"Okay"
                          otherButtonTitles:nil] show];
        CloudUsrEvnts *watchMeEvent = [[CloudUsrEvnts alloc] initWithAlertType:@"watchMe"];
        [watchMeEvent disableEvent];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"watchObjId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
-(void) animateHelpView:(UIView *)helpView {
    // animate the button
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.duration = 3.0;
    anim.repeatCount = 1;
    anim.autoreverses = YES;
    anim.removedOnCompletion = YES;
    anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)];
    [helpView.layer addAnimation:anim forKey:nil];
}
-(void) animateThisButton:(UIButton *)button {
    // animate the button
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.duration = 0.125;
    anim.repeatCount = 1;
    anim.autoreverses = YES;
    anim.removedOnCompletion = YES;
    anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)];
    [button.layer addAnimation:anim forKey:nil];
}
-(void) friensoMapViewCtrlr:(UIButton *)button {
    [self animateThisButton:button];
    [self performSegueWithIdentifier:@"showFriesoMap" sender:self];
}

#define BYPASSFRIENDREQUESTS 0
-(void) logAndNotifyCoreFriendsToWatchMe {
    if (DBG) NSLog(@"logAndNotifyCoreFriendsToWatchMe");
    
    /**************PUSH NOTIFICATIONS: WATCH ME NOW!!!! *****************/
    if (BYPASSFRIENDREQUESTS) {
        CloudUsrEvnts *watchMePushNots = [[CloudUsrEvnts alloc] initWithAlertType:@"watchMe"];
        [watchMePushNots sendNotificationsToCoreCircle];
        
    } else {
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
        }// ends for loop
    /***    
    
    //Query Parse to know who your "accepted" core friends are and send them each a notification
    
    PFQuery *query = [PFQuery queryWithClassName:@"CoreFriendRequest"];
    [query whereKey:@"status" equalTo:@"accept"];
    [query whereKey:@"sender" equalTo:[PFUser currentUser]];
    [query includeKey:@"recipient"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            if (DBG) NSLog(@"Successfully retrieved %ld scores.", (unsigned long)objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                NSString *myString = @"Ph";
                NSString *personalizedChannelNumber = [myString stringByAppendingString:object[@"recipient"][@"phoneNumber"]];
                if (DBG) NSLog(@"Phone Number for this friend is: %@", personalizedChannelNumber);
                
                PFPush *push = [[PFPush alloc] init];
                
                // Be sure to use the plural 'setChannels' if you are sending to more than one channel.
                [push setChannel:personalizedChannelNumber];
                NSString *coreRqstHeader = @"WATCH REQUEST FROM: ";
                NSString *coreFrndMsg = [coreRqstHeader stringByAppendingString:[[PFUser currentUser] objectForKey:@"username"]];
                
                [push setMessage:coreFrndMsg];
                [push sendPushInBackground];
            }
        } else {
            // Log details of the failure
            if (DBG) NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
     ****/
    /**************END OF PUSH NOTIFICATIONS: WATCH ME!!!! *****************/
    }
    
    /*****START GROUP SMS SENDING BUT LOOK AT IF FRIENDS ARE >0 to SET RECIPIENTS*********/
    NSDictionary *myCoreFriendsDic = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"CoreFriendsContactInfoDicKey"];
    NSError *error;
    NSMutableArray *coreSMSArray = [[NSMutableArray alloc] init];
    int friendCount = 0;
    //int i = 0;
    for (id key in myCoreFriendsDic) {
        //NSLog(@"Phone Number for this friend is: %@", object[@"recipient"][@"phoneNumber"]);
        //NSLog(@"reading contact %@",[myCoreFriendsDic objectForKey:key]);
        NSString *coreFriendPh = [self stripStringOfUnwantedChars:[myCoreFriendsDic objectForKey:key]];
        [coreSMSArray addObject:coreFriendPh];
        friendCount++;
    }
    //Only send SMS if you actually have someone in your core friends list
    if (friendCount > 0) {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        PFGeoPoint *myLocation = [[PFUser currentUser] objectForKey:@"currentLocation"];
        NSLog(@"YOUR LOCATION CURRENTLY IS: %f,%f", myLocation.latitude, myLocation.longitude);
        NSString *HelpMeLatitude = [NSString stringWithFormat: @"%f", myLocation.latitude];
        NSString *HelpMeLongitude = [NSString stringWithFormat: @"%f", myLocation.longitude];
        
        
        if([MFMessageComposeViewController canSendText])
        {
            NSLog(@"This View Controller can send SMS messages!!");
            NSLog(@"You have %d friends", friendCount);
            NSString *mainMessage = @"Please watch over me!! I am at: http://maps.google.com/";
            
            NSString *fullMessage = [NSString stringWithFormat:@"%@?q=%@,%@ My exact address is: %@. To find out more, go to http://www.frienso.com", mainMessage, HelpMeLatitude, HelpMeLongitude, watchLocation];
            controller.body = fullMessage;
            
            if(friendCount == 1)
                controller.recipients = [NSArray arrayWithObjects:coreSMSArray[0], nil];
            if(friendCount == 2)
                controller.recipients = [NSArray arrayWithObjects:coreSMSArray[0], coreSMSArray[1], nil];
            if(friendCount == 3)
                controller.recipients = [NSArray arrayWithObjects:coreSMSArray[0], coreSMSArray[1], coreSMSArray[2], nil];
            
            controller.messageComposeDelegate = self;
//            [self presentModalViewController:controller animated:YES];
            [self presentViewController:controller animated:YES completion:nil];
        }
        
        
        
        else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }

    
    // Watch Me event tracking
    CloudUsrEvnts *watchMeEvent = [[CloudUsrEvnts alloc] initWithAlertType:@"watchMe"
                                                        eventStartDateTime:[NSDate date] ];
    //[watchMeEvent setPersonalEvent];
    [watchMeEvent sendToCloud];
    
}
- (void) presentProfileSettingsView:(id) sender
{
    NSLog(@"PROFILE SETTINGS");
    [self.profileView.closeProfileBtn sendActionsForControlEvents: UIControlEventTouchUpInside];
    [self performSegueWithIdentifier:@"userProfileSegue" sender:self];
}

#pragma mark - Interaction with NSUserDefaults
-(BOOL) inYourCoreUserWithPhNumber:(NSString *)phNumberOnWatch  {
    /** inYourCoreUserWithPhNumber
     **
     ** - for each phone number passed by argument, check it against the three coreFriends' phone numbers
     ** - if j counter ends up with a value of 3, there is no match if below 3, then there is a match
     ** */
    
    NSLog(@"inYourCoreUserWithPhNumber : phNumberOnWatch = %@", phNumberOnWatch);
    
    BOOL inYourCoreBool = NO;
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"CoreFriendsContactInfoDicKey"];
    NSInteger j = 0;
    
    for (NSString *coreCirclePh in [dic allValues]) {
        NSString *clnStr = [self stripStringOfUnwantedChars:coreCirclePh];
        NSString *str;
        if(clnStr.length > 10) { //if the number has more than 10 digits.
            //TODO: what about international numbers?
            str = [clnStr substringFromIndex:(clnStr.length - 10)];
        } else {
            str = clnStr;
        }
        if ( ![str isEqualToString:[self stripStringOfUnwantedChars:phNumberOnWatch]]){
            //;
            j++;
        }
        
    }
    if (j<3) {
        inYourCoreBool = YES;
    }
    
    return inYourCoreBool;
}

#pragma mark - Setup view widgets
-(void) setupRequestScrollView{
    _drawerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 29, 24)];
    [_drawerLabel setText:@"≡"];
    [_drawerLabel setTextAlignment:NSTextAlignmentCenter];
    [_drawerLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Thin" size:29]];
    [_drawerLabel setTextColor:[UIColor whiteColor]];
    CGRect defaultDrawerRect=CGRectMake(0, 0, self.view.bounds.size.width,_drawerLabel.frame.size.height*0.9);
    self.scrollView = [[UserResponseScrollView alloc] initWithFrame:defaultDrawerRect];
    self.scrollView.contentSize = self.scrollView.frame.size;
    CGRect fullScreenRect=[[UIScreen mainScreen] applicationFrame];
    self.scrollViewY = self.mapView.frame.size.height + self.scrollView.center.y;
    [self.scrollView setCenter:CGPointMake(fullScreenRect.size.width/2.0,
                                           self.scrollViewY)];
    
    [self.view addSubview:self.scrollView];
    //[self.scrollView setPendingRequests:@[@"one",@"two"]];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openCloseDrawer)];
    // prevents the scroll view from swallowing up the touch event of child buttons
    tapGesture.cancelsTouchesInView = NO;
    
    [self.scrollView addGestureRecognizer:tapGesture];
    [_drawerLabel setCenter:CGPointMake(self.scrollView.center.x, _drawerLabel.frame.size.height/2.0)];
    [self.scrollView addSubview:_drawerLabel];
    
    
    
                              
}
-(void) setupMapView {
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
    [self.mapView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.bounds.size.height * 0.5)];
    self.mapViewHeight = self.view.bounds.size.height * 0.5;
    self.mapView.region = MKCoordinateRegionMake(self.location.coordinate,MKCoordinateSpanMake(0.05f,0.05f));
    self.mapView.layer.borderWidth = 2.0f;
    self.mapView.layer.borderColor = [UIColor whiteColor].CGColor;//UIColorFromRGB(0x9B90C8).CGColor;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    // Adding a refresh mapview btn
    UIButton *refreshMavpViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshMavpViewBtn addTarget:self action:@selector(refreshMapViewAction:)
                 forControlEvents:UIControlEventTouchUpInside];
    [refreshMavpViewBtn setTitle:@"↺"/*@""*/ forState:UIControlStateNormal];
    [refreshMavpViewBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [refreshMavpViewBtn.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:32.0]];
    refreshMavpViewBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    refreshMavpViewBtn.layer.shadowOffset  = CGSizeMake(1.5f, 1.5f);
    refreshMavpViewBtn.layer.shadowOpacity = 1.0;
    refreshMavpViewBtn.layer.shadowRadius  = 4.0;
    [refreshMavpViewBtn sizeToFit];
    //    [self.fullScreenBtn setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:.5]];
    //    self.fullScreenBtn.layer.borderWidth = 0.5f;
    //    self.fullScreenBtn.layer.cornerRadius = self.fullScreenBtn.frame.size.height*.20;
    //    self.fullScreenBtn.layer.borderColor = [UIColor blackColor].CGColor;
    [refreshMavpViewBtn setCenter:CGPointMake(refreshMavpViewBtn.center.x *1.3,
                                              refreshMavpViewBtn.center.y *1.3) ];
    [self.mapView addSubview:refreshMavpViewBtn];
    
    // Adding fullscreen mode button to the mapview
    self.fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fullScreenBtn addTarget:self action:@selector(mapViewFSToggle:)
                 forControlEvents:UIControlEventTouchUpInside];
    [self.fullScreenBtn setTitle:@"⇲"/*@""*/ forState:UIControlStateNormal];
    [self.fullScreenBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.fullScreenBtn.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:24.0]];
    self.fullScreenBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.fullScreenBtn.layer.shadowOffset  = CGSizeMake(1.5f, 1.5f);
    self.fullScreenBtn.layer.shadowOpacity = 1.0;
    self.fullScreenBtn.layer.shadowRadius  = 4.0;
    [self.fullScreenBtn sizeToFit];
//    [self.fullScreenBtn setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:.5]];
//    self.fullScreenBtn.layer.borderWidth = 0.5f;
//    self.fullScreenBtn.layer.cornerRadius = self.fullScreenBtn.frame.size.height*.20;
//    self.fullScreenBtn.layer.borderColor = [UIColor blackColor].CGColor;
    [self.fullScreenBtn setCenter:CGPointMake(self.mapView.frame.size.width-_fullScreenBtn.center.x * 2.0,
                                         self.mapView.frame.size.height- _fullScreenBtn.center.y *1.2 ) ];
    [self.mapView addSubview:self.fullScreenBtn];
    
    
    
    // CONFIGUREOVERLAY->check for pending requests-> if user accepts requests, add overlay to mapview
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"adminID"] != NULL) {
        [self loginCurrentUserToCloudStore]; // login to cloud store
    }

}
- (void) initializeMapView {
    [self.locationManager startUpdatingLocation];
    [self setInitialLocation:self.locationManager.location];
    self.mapView.region = MKCoordinateRegionMake(self.location.coordinate, MKCoordinateSpanMake(0.05f, 0.05f));
    if([self.loadingView isAnimating])
        [self.loadingView stopAnimating];
}


/**
-(void) trackFriendsView
{
    self.trackingStatusView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [self.trackingStatusView setFrame:CGRectMake(0, self.view.bounds.size.height*0.25,
                                                 self.view.frame.size.width*1.5, self.view.frame.size.height * 0.25)];
    [self.trackingStatusView setShowsHorizontalScrollIndicator:YES];
    self.trackingStatusView.layer.borderWidth = 2.0f;
    self.trackingStatusView.layer.borderColor = [UIColor whiteColor].CGColor;
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame       = self.trackingStatusView.bounds;
    UIColor *startColour = [UIColor colorWithHue:.580555 saturation:0.31 brightness:0.90 alpha:1.0];
    UIColor *endColour   = [UIColor colorWithHue:.58333 saturation:0.50 brightness:0.62 alpha:1.0];
    gradient.colors = [NSArray arrayWithObjects:(id)[startColour CGColor],(id)[endColour CGColor], nil];
    [self.trackingStatusView.layer insertSublayer:gradient atIndex:0];
    [self.view addSubview:self.trackingStatusView];

}
*/
-(void) setupEventsTableView { /* this user's events */
    //CGRect appFrame = [[self.appFrameProperties objectAtIndex:0] CGRectValue];
    
    UIView *tableHelpView = [[UIView alloc] initWithFrame:CGRectMake(0, self.scrollView.frame.size.height +
                                                                     self.mapView.frame.size.height,
                                                                     self.view.frame.size.width, self.view.bounds.size.height * 0.4)];// help view
    [tableHelpView setBackgroundColor:UIColorFromRGB(0x006bb6)];
    [tableHelpView setAlpha:0.8f];
    tableHelpView.layer.borderWidth = 2.0f;
    tableHelpView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    UILabel *label = [[UILabel alloc] init];
    [label setTextColor:[UIColor whiteColor]];
    [label setText:@"Your Activity"];
    [label sizeToFit];
    [label setCenter:CGPointMake(self.view.center.x, label.frame.size.height*1.5f)];
    [tableHelpView addSubview:label];
    
    self.tableView = [[UITableView alloc] init];
    [self.tableView setFrame:CGRectMake(0, self.scrollView.frame.size.height + self.mapView.frame.size.height,
                                         self.view.frame.size.width, self.view.bounds.size.height * 0.4)];
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    self.tableView.layer.borderWidth = 2.0f;
    self.tableView.layer.borderColor = [UIColor whiteColor].CGColor;// UIColorFromRGB(0x9B90C8).CGColor;
    [self.view addSubview:self.tableView];
    [self.tableView setScrollEnabled:YES];
    [self.tableView setScrollsToTop:YES];
    
    self.normTableViewRect = self.tableView.frame;
    
    
    /* Create the fetch request first; set a predicate to filter priority level 3 items (sponsored events) */
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]
                                    initWithEntityName:@"FriensoEvent"];

    NSSortDescriptor *createdSort =
    [[NSSortDescriptor alloc] initWithKey:@"eventCreated"
                                ascending:NO];
    
    NSSortDescriptor *prioritySort = [[NSSortDescriptor alloc] initWithKey:@"eventPriority"
                                ascending:NO];
    
    fetchRequest.sortDescriptors = @[prioritySort,createdSort];
    
    self.frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                   managedObjectContext:[self managedObjectContext]
                                                     sectionNameKeyPath:nil
                                                              cacheName:nil];
    
    self.frc.delegate = self;
    NSError *fetchingError = nil;
    if ([self.frc performFetch:&fetchingError]){
        // local events fetched ok ->if (DBG) NSLog(@"Successfully fetched.");
    } else {
        if (DBG) NSLog(@"Failed to fetch.");
    }
    
    [self.tableView addSubview:tableHelpView];
    [self animateHelpView:tableHelpView];
    [UIView animateWithDuration:3.0
                     animations:^{tableHelpView.alpha = 0.0;}
                     completion:^(BOOL finished){ [tableHelpView removeFromSuperview]; }];
}

-(void) setupToolBarIcons{
    self.navigationController.toolbarHidden = NO;
    [self.navigationController.toolbar setBarTintColor:[UIColor colorWithHue:.580555 saturation:0.31 brightness:0.90 alpha:0.5]];
    
    // left button coreFriends bar button
    self.coreCircleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
    [self.coreCircleBtn setTitle:@"👥" forState:(UIControlStateNormal)];
    if (![self.coreCircleBtn isEnabled])
        [self.coreCircleBtn setEnabled:YES];
    [self.coreCircleBtn addTarget:self action:@selector(viewCoreCircle:)
            forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barLeftButton=[[UIBarButtonItem alloc] init];
    [barLeftButton setCustomView:self.coreCircleBtn];
    [self.coreCircleBtn setCenter:CGPointMake(44.0f,22)];
    
    // Right tool bar btn
    FriensoOptionsButton *button = [[FriensoOptionsButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
//    button.layer.cornerRadius = 4.0;
//    button.layer.borderWidth =  1.0;
//    button.layer.borderColor = [UIColor blackColor].CGColor;
    [button addTarget:self action:@selector(viewMenuOptions:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setCenter:CGPointMake(self.navigationController.toolbar.frame.size.width - button.center.x*2.0, 22)];
        //self.navigationItem.rightBarButtonItem=barButton;
    
    
    // center toolbar btn
//    self.helpMeNowBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
//    [self.helpMeNowBtn addTarget:self action:@selector(actionPanicEvent:)
//          forControlEvents:UIControlEventTouchUpInside];
//    [self.helpMeNowBtn setTitle:@"\u26A0" forState:(UIControlStateNormal)];
////    self.helpMeNowBtn.layer.cornerRadius = 4.0f;
////    self.helpMeNowBtn.layer.borderWidth  = 1.0f;
////    self.helpMeNowBtn.layer.borderColor  = UIColorFromRGB(0x006bb6).CGColor;;
//    self.helpMeNowBtn.titleLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:107.0/255.0 blue:182.0/255.0 alpha:1.0];
//    [self.helpMeNowBtn setCenter:CGPointMake(self.navigationController.toolbar.center.x, 22)];
    [self setupHelpMeNowSwitch];
    
    [self.navigationController.toolbar addSubview:self.coreCircleBtn]; // left
    [self.navigationController.toolbar addSubview:button]; // right
}
-(void) setupNavigationBarImage{
    // Colors
    //  0x3498db peter river
    //  0xecf0f1 clouds
    //[self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0x3498db)];//[UIColor colorWithHue:.580555 saturation:0.31 brightness:0.90 alpha:0.5]

    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHue:.580555 saturation:0.31 brightness:0.90 alpha:0.5]];
    
//    NSShadow *shadow = [[NSShadow alloc] init];
//    shadow.shadowColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
//    shadow.shadowOffset = CGSizeMake(0, 1);
//    [self.navigationController.navigationBar setTranslucent:YES];
//    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
//                                                                      [UIColor whiteColor], NSForegroundColorAttributeName,
//                                                                      shadow, NSShadowAttributeName,
//                                                                      [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:21.0], NSFontAttributeName, nil]];
//    self.navigationItem.title = @"FRIENSO";


    
    // Right Options Button
    trackMeOnOff = [[UISwitch alloc] init];
    
    [trackMeOnOff addTarget:self action:@selector(trackMeSwitchEnabled:)
           forControlEvents:UIControlEventValueChanged];
    [trackMeOnOff setCenter:CGPointMake(self.navigationController.toolbar.bounds.size.width*0.85, 22)];
    trackMeOnOff.layer.cornerRadius = trackMeOnOff.frame.size.height/2.0;
    trackMeOnOff.layer.borderWidth =  1.0;
    trackMeOnOff.layer.borderColor = [UIColor whiteColor].CGColor;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    [label setText:@"\u2316"];
    [label setTextColor:[UIColor colorWithHue:.580555 saturation:0.31 brightness:0.90 alpha:0.5]];
    [label setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Thin" size:24.0]];
    [label sizeToFit];
    [label setTag:100];
    [label setCenter:CGPointMake(label.center.x+4.0f, label.center.y)];
    [trackMeOnOff addSubview:label];
    
    
    // Local store check for active event
    if( [[[CloudUsrEvnts alloc] init] activeAlertCheck]) {
        if (DBG) NSLog(@"Yes, an alert is active!");
        [trackMeOnOff setOn:YES animated:YES];
    } else
        [trackMeOnOff setOn:NO animated:YES];
    UIBarButtonItem *barButton=[[UIBarButtonItem alloc] init];
    [barButton setCustomView:trackMeOnOff];

    /********************* Left CoreCircle button
    UIButton *ugcTopLeftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
    [ugcTopLeftBtn setImage:[UIImage imageNamed:@"ugc-ic-29x2.png"] forState:UIControlStateNormal];
    [ugcTopLeftBtn setTintColor:UIColorFromRGB(0x007aff)];
    [ugcTopLeftBtn addTarget:self action:@selector(viewCoreCircle:)
            forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barLeftButton=[[UIBarButtonItem alloc] init];
    [barLeftButton setCustomView:ugcTopLeftBtn];
    
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    **********************/
    self.navigationItem.leftBarButtonItem=nil;
    
    
    
    
    
//    // Right to left Create Event button
//    FriensoPersonalEvent *createEventBtn = [[FriensoPersonalEvent alloc]
//                                          initWithFrame:CGRectMake(0, 0, 27, 27)];
//    createEventBtn.layer.cornerRadius = 4.0;
//    createEventBtn.layer.borderWidth  =  1.0;
//    createEventBtn.layer.borderColor  = [UIColor blackColor].CGColor;
//    [createEventBtn addTarget:self action:@selector(makeFriensoEvent:)
//            forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *barRightOfLeftButton = [[UIBarButtonItem alloc] init];
//    [barRightOfLeftButton setCustomView:createEventBtn];
    self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:barButton, nil];
}


#pragma mark - FriensoViewController
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
    
    NSLog(@"-*- Home View: FriensoVC -*-\n");
    
    // Initialize arrays
    self.friendsLocationArray = [[NSMutableArray alloc] init]; // friends location cache
    self.pendingRqstsArray    = [[NSMutableArray alloc] init]; // Init pending requests holding array
    self.watchingCoFrArray    = [[NSMutableArray alloc] init];

    
    [self setupNavigationBar];
    [self setupUI];
    [self initializeMapView];
        
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"getStartedFlag"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"getStartedFlag"])
    {
        if (!DBG) NSLog(@"_1_ Presenting Welcome View}");
        [self performSelector:@selector(segueToWelcomeVC) withObject:self afterDelay:1];
        }
    /* 
     else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"getStartedFlag"] &&
     [[NSUserDefaults standardUserDefaults] objectForKey:@"adminID"] != NULL)
     {
     [self runNormalModeUI];
     [self configureOverlay];
     }
     */
    else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"getStartedFlag"] &&
               [[NSUserDefaults standardUserDefaults] objectForKey:@"adminID"] != NULL){
        if (!DBG) iLog(@"{ viewDidLoad } getstarted flag ok, adminID not null");
        [self runNormalModeUI];
        
        FRCoreDataParse* cdParseHandler = [[FRCoreDataParse alloc] init];
        [cdParseHandler updateCoreFriendsLocation];
        
        
        /*REVERSE GEOCODE LATITUDE AND LONGITUDE IN THIS VIEW TO GET AN ACTUAL ADDRESS TO BE SENT WITH PNS AND TEXT MESSAGES */
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        PFGeoPoint *myLocation = [[PFUser currentUser] objectForKey:@"currentLocation"];
        
        CLLocation *newLocation = [[CLLocation alloc]initWithLatitude:myLocation.latitude
                                                            longitude:myLocation.longitude];
        
        [geocoder reverseGeocodeLocation:newLocation
                       completionHandler:^(NSArray *placemarks, NSError *error) {
                           
                           if (error) {
                               NSLog(@"Geocode failed with error: %@", error);
                               return;
                           }
                           
                           if (placemarks && placemarks.count > 0)
                           {
                               CLPlacemark *placemark = placemarks[0];
                               
                               NSDictionary *addressDictionary =
                               placemark.addressDictionary;
                               
                               //NSLog(@"%@ ", addressDictionary);
                               NSString *address = [addressDictionary
                                                    objectForKey:(NSString *)kABPersonAddressStreetKey];
                               NSString *city = [addressDictionary
                                                 objectForKey:(NSString *)kABPersonAddressCityKey];
                               NSString *state = [addressDictionary
                                                  objectForKey:(NSString *)kABPersonAddressStateKey];
                               NSString *zip = [addressDictionary
                                                objectForKey:(NSString *)kABPersonAddressZIPKey];
                               
                               watchLocation = [NSString stringWithFormat:@"%@ %@ %@ %@", address,city, state, zip];
                               
                           }
                           
                       }];
        
        /**************************END REVERSE GEOCODING**************************************************/
        
        
        
   
    }
    
    
    
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!DBG) NSLog(@"  -*- viewDidAppear ... ");
    
    // Restore touch interaction on the following widgets
    [navGestures setEnabled:YES];
    [self.coreCircleBtn setEnabled:YES];
    
    // Hide the Options Menu when navigating to Options, otherwise show
    for (id subview in [self.navigationController.toolbar subviews]){
        if ( [subview isKindOfClass:[FriensoOptionsButton class]] )
        {
            if ([subview isHidden])
                [subview setHidden:NO];
        }
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"helpNowCancelled"] == 1) {
        if (DBG) NSLog(@"%d",[[NSUserDefaults standardUserDefaults] boolForKey:@"helpNowCancelled"]);
        [helpMeNowSwitch setOn:NO animated:YES];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"helpNowCancelled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    NSString *helpObjId = [[NSUserDefaults standardUserDefaults] objectForKey:@"helpObjId"];
    if (helpObjId != nil )
    {   /* if a parse objectId exist locally and helpMeNowSwitch was NOT setup *
         * otherwise, leave the switch along */
        [helpMeNowSwitch setOn:YES];
        if (!DBG) NSLog(@"    We have an active helpMeNow event");
    }
    
    NSNumber *installStepNum = [[NSUserDefaults standardUserDefaults] valueForKey:@"installationStep"];
    if (installStepNum == NULL &&
        [[NSUserDefaults standardUserDefaults] boolForKey:@"getStartedFlag"])
    {
        if (!DBG) NSLog(@"_2_ LoginView");
        // Presenting loginView
        [self performSelector:@selector(segueToLoginVC) withObject:self afterDelay:1];
        /*
        
        */
        
    }
    else if ([installStepNum isEqualToNumber:[NSNumber numberWithInteger:0]] &&
               [[NSUserDefaults standardUserDefaults] objectForKey:@"adminID"] != NULL )
    {
    
        if (!DBG) NSLog(@"  After login/register -*- First install}");
        
        // Login to Parse
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if ( [userDefaults objectForKey:@"adminID"] != NULL ) {
            [PFUser logInWithUsernameInBackground:[userDefaults objectForKey:@"adminID"]
                                         password:[userDefaults objectForKey:@"adminPass"]
                                            block:^(PFUser *user, NSError *error) {
                                                if (!user) {
                                                    iLog(@"  Parse login failed w/this error: %@",error);
                                                } else {
                                                    NSLog(@"  Login to Parse: SUCCESS");
                                                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:1] forKey:@"installationStep"];
                                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                                    
                                                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"newUserFlag"])
                                                    {
                                                        if (!DBG) NSLog(@"_3_ Presenting newCoreCircle ");
                                                        [self performSegueWithIdentifier:@"newCoreCircle"
                                                                                  sender:self];
                                                    }
                                                        
                                                    //[self runNormalModeUI];
                                                    
                                                }
                                            }];
            
            // If the following ACL settins are required: Set the proper ACLs
            /*        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
             [ACL setPublicReadAccess:YES];
             [PFACL setDefaultACL:ACL withAccessForCurrentUser:YES];
             */
            [self runNormalModeUI];
        }  else {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSLog(@"%@", [userDefaults objectForKey:@"adminID"]);
        }
        
        
        
        
    } else if ([installStepNum isEqualToNumber:[NSNumber numberWithInteger:1]])     {
        if (!DBG) NSLog(@"  -*- returned from new core circle -*- After First install");
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:2] forKey:@"installationStep"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        // After first install, cache univesity/college emergency contacts
        [[[CloudEntityContacts alloc] initWithCampusDomain:@"nd.edu"] fetchEmergencyContacts:@"inst,contact"];
        
        [self runNormalModeUI];
    }
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return  NO; //(interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [navGestures setEnabled:NO];
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
//    if([[segue identifier] isEqualToString:@"addToCartSegue"]){
//        
//    }
    
}
- (void) setupNavigationBar
{
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHue:.580555 saturation:0.31 brightness:0.90 alpha:0.5]];
    
    
    //[UIView animateWithDuration:0.5 animations:^{
    UIView *newTitleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.frame];
    navGestures = [[UIGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(navigationCtrlrSingleTap:)];
    [navGestures setDelegate:self];
    
    // The Avatar
    UIImage *image = nil;
    UIImageView __block *imgView = nil;
    if ( [[NSUserDefaults standardUserDefaults] URLForKey:@"profileImageUrl"] == NULL) {
        image = [UIImage imageNamed:@"avatar.png"];
        UIImage *scaledimage = [[[FRStringImage alloc] init] scaleImage:image toSize:CGSizeMake(38.0, 38.0)];
        imgView = [self newImageViewWithImage:scaledimage
                                               showInFrame:CGRectMake(0, 0, 38.0f, 38.0f)];
    } else {
        imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 38.0f, 38.0f)];

        NSURL *assetURL = [[NSUserDefaults standardUserDefaults] URLForKey:@"profileImageUrl"];
        ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
        [assetLibrary assetForURL:assetURL
                      resultBlock:^(ALAsset *asset) {
                          UIImage *thumbImg = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]
                                                                  scale:0.5
                                                            orientation:UIImageOrientationUp];
                          //                cell.backgroundView = [[UIImageView alloc] initWithImage:copyOfOriginalImage];
                          dispatch_async(dispatch_get_main_queue(), ^{
                              if (thumbImg != NULL)
                                  [imgView setImage:thumbImg];
                          });
                      } failureBlock:^(NSError *err) {
                          //profilePhoto =[[UIImageView alloc] initWithImage:[UIImage imageNamed::@"avatar.png"];
                          NSLog(@"Error: %@",[err localizedDescription]);
                      }];
    }
    
    imgView.contentMode  = UIViewContentModeScaleAspectFill;
    imgView.layer.cornerRadius = imgView.frame.size.height/2.0f;
    imgView.layer.borderWidth  = 1.0;
    imgView.layer.borderColor  = [UIColor whiteColor].CGColor;
    imgView.layer.masksToBounds = YES;
    [imgView setImage:image];
    [imgView setCenter:self.navigationItem.titleView.center];
    [newTitleView addSubview:imgView];
    //isolate tap to only the navigation bar
    [self.navigationController.navigationBar addGestureRecognizer:navGestures];
    self.navigationItem.titleView  = newTitleView;
    //}];
    
}

- (void) setupUI
{
    // Seting up the UI
    if (!DBG) NSLog(@"  Setup UI");
    [self setupMapView];
    [self setupRequestScrollView];
    [self setupEventsTableView];
    [self setupToolBarIcons];
    [self setupNavigationBarImage];
    
    // Show progress indicator to tell user to wait a bit
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.loadingView setColor:UIColorFromRGB(0xf47d44)];
    [self.view addSubview:self.loadingView];
    [self.loadingView setCenter:CGPointMake(self.view.center.x, self.view.bounds.size.height*0.2)];
    [self.loadingView startAnimating];

}
- (void) runNormalModeUI {
    if (!DBG) NSLog(@"  >Ready. Run Normal mode");
    
    //Initialize mapView
    [self initializeMapView];
    
    // Hide the Options Menu when navigating to Options, otherwise show
    for (id subview in [self.navigationController.toolbar subviews]){
        if ( [subview isKindOfClass:[FriensoOptionsButton class]] )
        {
            if ([subview isHidden])
                [subview setHidden:NO];
        }
    }
    
    //  cache resources from parse // The className to query on
    PFQuery *query = [PFQuery queryWithClassName:@"Resources"];
    [query orderByDescending:@"createdAt"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object) {
            if (DBG) NSLog(@"The getFirstObject request failed.");
        } else {
            // The find succeeded.
            //if (DBG) NSLog(@"Successfully retrieved the object.");
            //if (DBG) NSLog(@"%@", object.objectId);
            
            
            FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            
            NSManagedObjectContext *managedObjectContext =
            appDelegate.managedObjectContext;
            // First check to see if the objectId already exists
            NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"FriensoEvent"
                                                                 inManagedObjectContext:managedObjectContext];
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setPredicate:[NSPredicate predicateWithFormat:@"eventObjId like %@",object.objectId]];
            [request setEntity:entityDescription];
            BOOL unique = YES;
            NSError  *error;
            NSArray *items = [managedObjectContext executeFetchRequest:request error:&error];
            if(items.count > 0){
                unique = NO;
                
            }
            if (unique) {
                FriensoEvent *firstFriensoEvent = [NSEntityDescription insertNewObjectForEntityForName:@"FriensoEvent"
                                                                                inManagedObjectContext:managedObjectContext];
                
                if (firstFriensoEvent != nil)
                {
                    
                    firstFriensoEvent.eventTitle     = [object valueForKey:@"resource"];
                    firstFriensoEvent.eventSubtitle  = [object valueForKey:@"detail"];
                    firstFriensoEvent.eventLocation  = [object valueForKey:@"ResourceLink"];
                    firstFriensoEvent.eventCategory  = [object valueForKey:@"categoryType"];
                    firstFriensoEvent.eventCreated   = [NSDate date];
                    firstFriensoEvent.eventModified  = object.createdAt;
                    firstFriensoEvent.eventObjId     = object.objectId;
                    firstFriensoEvent.eventImage     = [object valueForKey:@"rImage"];
                    firstFriensoEvent.eventPriority  = [NSNumber numberWithInteger:2];
                    
                    NSError *savingError = nil;
                    if([managedObjectContext save:&savingError]) {
                        if (DBG) NSLog(@"Successfully cached the resource");
                    } else
                        if (DBG) NSLog(@"Failed to save the context. Error = %@", savingError);
                    // update the Parse record:
                    [object setObject:[NSNumber numberWithBool:YES]
                               forKey:@"wasCached"];
                    [object saveInBackground];
                    
                } else {
                    if (DBG) NSLog(@"Failed to create a new event.");
                }
            } //else if (DBG) NSLog(@"! Parse event is not unique");
        }
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)navigationCtrlrSingleTap:(id) sender {
    
    [self initializeMapView];
    
    //NSLog(@"Tapped: %.2f", self.navigationController.navigationBar.frame.size.height);
    self.profileView = [[ProfileSneakPeekView alloc] initWithFrame:self.navigationController.navigationBar.frame];
    [self.profileView setUserEmailString:[[NSUserDefaults standardUserDefaults] objectForKey:@"adminID"]
                         withPhoneNumber:[[NSUserDefaults standardUserDefaults] objectForKey:@"userPhone"]
     ];
    [self.profileView.settingsGearBtn addTarget:self
                                         action:@selector(presentProfileSettingsView:)
                               forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.profileView];
    
}

#pragma mark - Gesture Methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    NSLog(@"TOUCH self.tapCounter: %ld", (long)self.profileView.tapCounter);
    // Disallow recognition of tap gestures when a navigation Item is tapped
    if (touch.view == self.navigationController.navigationBar)
    {//your back button/left button/whatever buttons you have
        if (!self.profileView.tapCounter)
        {
            
            [self navigationCtrlrSingleTap:touch];
            NSLog(@"TITLEVIEW BACK TO NORMAL");
            self.profileView.tapCounter = YES;
        }
        
        return YES;
        
    }
    return NO;
}
- (void) loginCurrentUserToCloudStore {
    // Check if self is currentUser (Parse)
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        iLog(@"  Successful login to Parse:%@",currentUser.email);
        [self configureOverlay];

    } else {
        //if (DBG) NSLog(@"no current user");
        NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"adminID"];
        NSString *userPass = [[NSUserDefaults standardUserDefaults] objectForKey:@"adminPass"];
        [PFUser logInWithUsernameInBackground:userName password:userPass
                                        block:^(PFUser *user, NSError *error) {
                                            if (user) {
                                                iLog(@"[ Parse successful login ]");
                                                [self configureOverlay];

                                            } else
                                                iLog(@"- Cloud login failed -");
                                        }];
    }
}

#pragma mark - Segues
- (void) segueToWelcomeVC {
    [self performSegueWithIdentifier:@"welcomeView" sender:self];
}
- (void) segueToLoginVC {
    [self performSegueWithIdentifier:@"loginView" sender:self];
}
#pragma mark - CoreData helper methods
-(void) trackUserEventLocally:(PFObject *)userEventObject
{
    if (!DBG) NSLog(@"track userEvent locally");
    FriensoEvent *frEvent = [NSEntityDescription insertNewObjectForEntityForName:@"FriensoEvent"
                                                                    inManagedObjectContext:[self managedObjectContext]];
    
    if (frEvent != nil){
        PFUser *friensoUser = [userEventObject objectForKey:@"friensoUser"];
        frEvent.eventTitle     = [NSString stringWithFormat:@"Watching over: %@",friensoUser.username ];
        frEvent.eventSubtitle  = [userEventObject objectForKey:@"eventType"];
        frEvent.eventPriority  = [NSNumber numberWithInteger:3];
        frEvent.eventObjId     = userEventObject.objectId;
        
        NSError *savingError = nil;
        if(![[self managedObjectContext] save:&savingError])
            if (!DBG) NSLog(@"Failed to save the context. Error = %@", savingError);
        
    } else
        if (!DBG) NSLog(@"Failed to create a new event.");

}
-(void) updateCoreFriendEntity:(NSString *)friendEmail
                  withLocation:(PFGeoPoint *)friendCurrentLoc
{
    // NOT WORKING!!
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity  = [NSEntityDescription entityForName:@"CoreFriends"
                                               inManagedObjectContext:[self managedObjectContext]];
    
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"coreEmail like %@",@"nd.edu"];
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest
                                                                         error:&error];
    if (fetchedObjects == nil) {
        // Handle the error.
        if (DBG) NSLog(@"Handle the error: %@", error);
    } else {
        for (NSManagedObject *object in fetchedObjects) {
            
            if (DBG) NSLog(@"%@", object);
            
        }
    }
}
-(BOOL) amiWatchingUserEvent:(NSString *)userEventObjId
{
    //if (DBG) NSLog(@"%@", userEventObjId);
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init]; // Create the fetch request
    NSEntityDescription *entity  = [NSEntityDescription entityForName:@"FriensoEvent"
                                               inManagedObjectContext:[self managedObjectContext]];
    
    [fetchRequest setEntity:entity];
    //NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"nameID == %d",-1];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"eventObjId like %@",userEventObjId]];
    
    NSSortDescriptor *dateSort =  [[NSSortDescriptor alloc] initWithKey:@"eventModified" ascending:NO];
    fetchRequest.sortDescriptors = @[dateSort];
    [fetchRequest setFetchLimit:1];
    
    NSError *error;
    BOOL retBool = NO;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error.
        retBool = NO;
    }  else {
        if( [fetchedObjects count] > 0)
            retBool = YES;
        else
            retBool = NO;
        
    }
    return retBool;
}
-(BOOL) queryCDFriensoEvents4ActiveWatchEvent:(PFUser *)friensoUser
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init]; // Create the fetch request
    NSEntityDescription *entity  = [NSEntityDescription entityForName:@"FriensoEvent"
                                              inManagedObjectContext:[self managedObjectContext]];
    
    [fetchRequest setEntity:entity];
    //NSPredicate *predicateID = [NSPredicate predicateWithFormat:@"nameID == %d",-1];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"eventObjId like %@",friensoUser.objectId]];
    
    NSSortDescriptor *dateSort =  [[NSSortDescriptor alloc] initWithKey:@"eventModified" ascending:NO];
    fetchRequest.sortDescriptors = @[dateSort];
    [fetchRequest setFetchLimit:1];
    
    NSError *error;
    BOOL retBool;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error.
        retBool = NO;
    }  else {
       for (NSManagedObject *mObject in fetchedObjects) {
           if (DBG) NSLog(@"     %@,%@",[mObject valueForKey:@"eventTitle"],[mObject valueForKey:@"eventSubtitle"]);
           if ([[mObject valueForKey:@"eventContact"] rangeOfString:friensoUser.username].location == NSNotFound)
               retBool = NO;
           else
               retBool = YES;
       }
    }
    return retBool;
}
-(void) setWatchingUserInCD:(PFUser *)friensoUser
{
    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    FriensoEvent *localEvent = [NSEntityDescription insertNewObjectForEntityForName:@"FriensoEvent"
                                                                    inManagedObjectContext:managedObjectContext];
    
    if (localEvent != nil){
        localEvent.eventSubtitle  = @"watch";
        NSString *eventStr = @"You are watching: ";
        localEvent.eventTitle     = [eventStr stringByAppendingString:friensoUser.username];
        localEvent.eventPriority  = [NSNumber numberWithInteger:2];
        localEvent.eventCreated   = [NSDate date];
        localEvent.eventModified  = [NSDate date];
        
        NSError *savingError = nil;
        if([managedObjectContext save:&savingError]) {
            if (DBG) NSLog(@"Successfully saved the context");
        } else { if (DBG) NSLog(@"Failed to save the context. Error = %@", savingError); }
    } else {
        if (DBG) NSLog(@"Failed to create a new event.");
    }
}

- (void) actionAddFriensoUserLocation:(PFGeoPoint *)geoPoint forUser:(NSString *)friend {
    /* Method:      actionAddFriensoUserLocation
       Objective:   Display the user's current location in the Frienso Activity list-view
     
     **/
    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    FriensoEvent *userLocationEvent = [NSEntityDescription insertNewObjectForEntityForName:@"FriensoEvent"
                                                                    inManagedObjectContext:managedObjectContext];
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
    NSDictionary *userLocDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"userLocation"];
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:(CLLocationDegrees)[[userLocDic objectForKey:@"lat"] doubleValue]
                                                  longitude:(CLLocationDegrees)[[userLocDic objectForKey:@"long"] doubleValue]];
    
    CLLocationDistance distance = [locA distanceFromLocation:locB];
    if (userLocationEvent != nil){
        NSString *eventStr = @"";
        userLocationEvent.eventTitle     = [eventStr stringByAppendingString:[friend componentsSeparatedByString:@"@"][0]];
        userLocationEvent.eventSubtitle  = [NSString stringWithFormat:@"%.2f %@ away",distance,@"meters" ];
        userLocationEvent.eventPriority  = [NSNumber numberWithInteger:3];
        userLocationEvent.eventCreated   = [NSDate date];
        userLocationEvent.eventModified  = [NSDate date];
        
        NSError *savingError = nil;
        if([managedObjectContext save:&savingError]) {
            if (DBG) NSLog(@"Successfully saved the context");
        } else { if (DBG) NSLog(@"Failed to save the context. Error = %@", savingError); }
    } else {
        if (DBG) NSLog(@"Failed to create a new event.");
    }
}

- (void) actionAddFriensoEvent:(NSString *) message {
    if (DBG) NSLog(@"[ actionAddFriensoEvent ]");
    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *managedObjectContext =
    appDelegate.managedObjectContext;
    
    FriensoEvent *firstFriensoEvent = [NSEntityDescription insertNewObjectForEntityForName:@"FriensoEvent"
                                                                    inManagedObjectContext:managedObjectContext];
    
    if (firstFriensoEvent != nil){
        NSString *loginFriensoEvent = @"";
        firstFriensoEvent.eventTitle     = [loginFriensoEvent stringByAppendingString:message];
        firstFriensoEvent.eventSubtitle  = @"Review these data";
        firstFriensoEvent.eventLocation  = @"Right here";
        firstFriensoEvent.eventContact   = @"me";
        firstFriensoEvent.eventCreated   = [NSDate date];
        firstFriensoEvent.eventModified  = [NSDate date];
        
        NSError *savingError = nil;
        if([managedObjectContext save:&savingError]) {
            if (DBG) NSLog(@"Successfully saved the context");
        } else { if (DBG) NSLog(@"Failed to save the context. Error = %@", savingError); }
    } else {
        if (DBG) NSLog(@"Failed to create a new event.");
    }
    
}
-(void) syncCoreFriendsLocation {
    if (DBG) NSLog(@"--- syncCoreFriendsLocation  [ Sync friends' location to CoreData ]");
    FRCoreDataParse *frCDPObject = [[FRCoreDataParse alloc] init];
    [frCDPObject updateThisUserLocation];
    //[frCDPObject updateCoreFriendsLocation];
    [frCDPObject showCoreFriendsEntityData];
}

#pragma mark - core graphics

//- (UIImage *) createBackgroundImageWithColor:(UIColor *)color andSize:(CGSize)size {
//    
//    UIGraphicsBeginImageContext(size); // create a new context to draw in
//    
//    CGContextRef context = UIGraphicsGetCurrentContext(); // get a reference to the context
//    
//    CGContextSetStrokeColorWithColor(context, [color CGColor]); // set the fill color of the context
//    // make circle rect 5 px from border
//    CGRect circleRect = CGRectMake(0, 0,
//                                   size.width,
//                                   size.height);
//    circleRect = CGRectInset(circleRect, 5, 5);
//    CGContextStrokeEllipseInRect(context, circleRect); // draw a rect to fill the context
//
//    /**
//     CGContextSaveGState(context);
//    
//    // Magic blend mode
//    CGContextSetBlendMode(context, kCGBlendModeDestinationOut);
//    
//    // This seemingly random value adjusts the text
//    // vertically so that it is centered in the circle.
//    NSString *text = @"SA";
//    CGFloat Y_OFFSET = -2 * (float)[text length] + 5;
//    
//    // Context translation for label
//    CGFloat LABEL_SIDE = CGRectGetWidth(circleRect);
//    CGContextTranslateCTM(context, 0, CGRectGetHeight(circleRect)/2-LABEL_SIDE/2+Y_OFFSET);
//    
//    // Label to center and adjust font automatically
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, LABEL_SIDE, LABEL_SIDE)];
//    label.font = [UIFont boldSystemFontOfSize:120];
//    label.adjustsFontSizeToFitWidth = YES;
//    label.text = text;
//    label.textAlignment = NSTextAlignmentCenter;
//    label.backgroundColor = [UIColor darkGrayColor];
//    [label.layer drawInContext:context];
//    
//    // Restore the state of other drawing operations
//    CGContextRestoreGState(context);
//    */
//    //CGContextStrokePath(c);
//    UIFont*       font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:16];
//    UIColor* textColor = [UIColor blueColor];
//    NSDictionary* stringAttrs = @{ NSFontAttributeName: font, NSForegroundColorAttributeName: textColor};
//    NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:@"SA"
//                                                                  attributes:stringAttrs];
//    if (DBG) NSLog(@"size-width: %f", attrStr.size.width);
//    [attrStr drawAtPoint:CGPointMake(size.width*0.22,size.width*0.22)];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext(); // and create an image from the context
//    
//    CGContextRelease(context); // don't forget to release the context reference!
//    
//    return image; // return an autoreleased UIImage
//}
- (UIImage*)imageWithBorderFromImage:(UIImage*)source
{
    const CGFloat margin = 6.0f;
    CGSize size = CGSizeMake([source size].width + 2*margin, [source size].height + 2*margin);
    UIGraphicsBeginImageContext(size);
    
    [[UIColor whiteColor] setFill];
    [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)] fill];
    
    CGRect rect = CGRectMake(margin, margin, size.width-2*margin, size.height-2*margin);
    [source drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];
    /**
    CGContextRef context = UIGraphicsGetCurrentContext();

    //CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 1.0);
    
    
    
    CGContextMoveToPoint(context, 0,5.4); //start at this point
    CGContextAddLineToPoint(context, rect.size.width, 5.4 ); //draw to this point
    
    // and now draw the Path!
    CGContextStrokePath(context);
    
    // setting the date
    NSDate *now = [NSDate date];
    NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
    [weekday setDateFormat:@"dd"];
    //[weekday setLocale:NSLocale];
    NSString * dateString = [weekday stringFromDate:now];
    
    UIFont*       font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:16];
    UIColor* textColor = [UIColor redColor];
    NSDictionary* stringAttrs = @{ NSFontAttributeName: font, NSForegroundColorAttributeName: textColor };
    NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:dateString attributes:stringAttrs];
    
    [attrStr drawAtPoint:CGPointMake(4.f, 7.0f)];
    **/
    UIImage *testImg =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return testImg;
}

#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (DBG) NSLog(@"viewFoAnnotation");
    static NSString *GeoPointAnnotationIdentifier = @"RedPinAnnotation";
    static NSString *GeoQueryAnnotationIdentifier = @"PurplePinAnnotation";
    
    if ([annotation isKindOfClass:[GeoCDPointAnnotation class]]) {
        MKPinAnnotationView *annotationView =
        (MKPinAnnotationView *)[mapView
                                dequeueReusableAnnotationViewWithIdentifier:GeoPointAnnotationIdentifier];
        
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc]
                              initWithAnnotation:annotation
                              reuseIdentifier:GeoQueryAnnotationIdentifier];
            annotationView.tag = PinAnnotationTypeTagGeoQuery;
            annotationView.canShowCallout = YES;
            annotationView.pinColor = MKPinAnnotationColorPurple;
            annotationView.animatesDrop = YES;
            annotationView.draggable = NO;
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        
        return annotationView;
    } else if ([annotation isKindOfClass:[GeoPointAnnotation class]]) {
        MKPinAnnotationView *annotationView =
        (MKPinAnnotationView *)[mapView
                                dequeueReusableAnnotationViewWithIdentifier:GeoPointAnnotationIdentifier];
        
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc]
                              initWithAnnotation:annotation
                              reuseIdentifier:GeoPointAnnotationIdentifier];
            annotationView.tag = PinAnnotationTypeTagGeoPoint;
            annotationView.canShowCallout = YES;
            annotationView.pinColor = MKPinAnnotationColorRed;
            annotationView.animatesDrop = YES;
            annotationView.draggable = NO;
        }
        
        return annotationView;
    }
    
    return nil;
}
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control
{
    //if (DBG) NSLog(@"accessory button tapped for annotation %@", view.annotation);
    //if (DBG) NSLog(@"%@", [view.annotation description]);
//    if (DBG) NSLog(@"%@", [view.annotation title]);
//    if (DBG) NSLog(@"%@", [view.annotation subtitle]);
    UIAlertView *contactFriendAV = [[UIAlertView alloc] initWithTitle:[view.annotation subtitle]
                                                              message:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:@"📞 Call",@"💬 SMS", nil];
    [contactFriendAV setTag:100];
    [contactFriendAV show];
    
}
//- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
//    static NSString *CircleOverlayIdentifier = @"Circle";
//    
//    if ([overlay isKindOfClass:[CircleOverlay class]]) {
//        CircleOverlay *circleOverlay = (CircleOverlay *)overlay;
//        
//        MKCircleView *annotationView =
//        (MKCircleView *)[mapView dequeueReusableAnnotationViewWithIdentifier:CircleOverlayIdentifier];
//        
//        if (!annotationView) {
//            MKCircle *circle = [MKCircle
//                                circleWithCenterCoordinate:circleOverlay.coordinate
//                                radius:circleOverlay.radius];
//            annotationView = [[MKCircleView alloc] initWithCircle:circle];
//        }
//        
//        if (overlay == self.targetOverlay) {
//            annotationView.fillColor = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.3f];
//            annotationView.strokeColor = [UIColor redColor];
//            annotationView.lineWidth = 1.0f;
//        } else {
//            annotationView.fillColor = [UIColor colorWithWhite:0.3f alpha:0.3f];
//            annotationView.strokeColor = [UIColor purpleColor];
//            annotationView.lineWidth = 2.0f;
//        }
//        
//        return annotationView;
//    }
//    
//    return nil;
//}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    if (![view isKindOfClass:[MKPinAnnotationView class]] || view.tag != PinAnnotationTypeTagGeoQuery) {
        return;
    }
    
    if (MKAnnotationViewDragStateStarting == newState) {
        [self.mapView removeOverlays:self.mapView.overlays];
    } else if (MKAnnotationViewDragStateNone == newState && MKAnnotationViewDragStateEnding == oldState) {
        MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView *)view;
        GeoQueryAnnotation *geoQueryAnnotation = (GeoQueryAnnotation *)pinAnnotationView.annotation;
        self.location = [[CLLocation alloc] initWithLatitude:geoQueryAnnotation.coordinate.latitude longitude:geoQueryAnnotation.coordinate.longitude];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"adminID"] != NULL)
            [self configureOverlay];
    }
}

- (CLLocationManager *)locationManager {
	
    if (_locationManager != nil) {
		return _locationManager;
	}
	_locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    _locationManager.delegate = self;
    //_locationManager.purpose = @"Your current location is used to demonstrate PFGeoPoint and Geo Queries.";
	
	return _locationManager;
}
- (void)setInitialLocation:(CLLocation *)aLocation {
/* setInitialLocation
 *   Here I update my User object (in parse) with my current Location when HomeView is on the foreground
 *   PFUser currentUser should be me, but needs double checked
 */
    
    self.location = aLocation;
    self.radius = 1000;
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            
            NSNumber *lat = [NSNumber numberWithDouble:geoPoint.latitude];
            NSNumber *lon = [NSNumber numberWithDouble:geoPoint.longitude];
            NSDictionary *userLocation=@{@"lat":lat,@"long":lon};
            
            [[NSUserDefaults standardUserDefaults] setObject:userLocation forKey:@"userLocation"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
            [[PFUser currentUser] saveInBackground];
            
            iLog(@"Your Current Location: %.4f, %.4f",geoPoint.latitude,geoPoint.longitude);
        }
    }];
    
}

- (void) configureOverlay {
/* configureOverlay
 * - check if I have an active Event
 * - check if others have active events
 *
 ** */
    if (self.location) {
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView removeOverlays:self.mapView.overlays];
        
        GeoQueryAnnotation *annotation = [[GeoQueryAnnotation alloc] initWithCoordinate:self.location.coordinate radius:self.radius];
        [self.mapView addAnnotation:annotation];
        
        
    }
    
    if (!DBG) NSLog(@"configureOverlay method");
    
    // Check for friends with active alerts
    PFQuery *query = [PFQuery queryWithClassName:@"UserEvent"];
    [query whereKey:@"eventActive" equalTo:[NSNumber numberWithBool:YES]];
    [query includeKey:@"friensoUser"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!DBG) NSLog(@"------ Checking for Events ... objects: %d", (int)objects.count);
        if (!error) {
            for (PFObject *object in objects)
            {
                if(DBG) NSLog(@">> %@", [object objectForKey:@"eventType"]);
                PFUser *friensoUser = [object objectForKey:@"friensoUser"];
                if ([friensoUser.username isEqualToString:[PFUser currentUser].username] &&
                    [[object objectForKey:@"eventType"] isEqualToString:@"watchMe"])
                {
                    if (DBG) NSLog(@"usern: %@",friensoUser.username);
                    if (DBG) NSLog(@"event: %@",[object valueForKey:@"eventType"]);
                    if (DBG) NSLog(@"ObjId: %@", object.objectId);
                    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"watchObjId"] == nil ){
                        [object setObject:[NSNumber numberWithBool:NO] forKey:@"eventActive"];
                        [object saveInBackground];
                    } else
                        [trackMeOnOff setOn:YES animated:YES]; // check if self has an active Event going
                } else if ([friensoUser.username isEqualToString:[PFUser currentUser].username] &&
                           [[object objectForKey:@"eventType"] isEqualToString:@"helpNow"])
                {
                    if (DBG) NSLog(@"ObjId: %@", object.objectId);
                    if (DBG) NSLog(@"event: %@",[object valueForKey:@"eventType"]);

                    // In certain cases, the NSUserDefaults is the ground truth
                    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"helpObjId"] == nil ){
                        [object setObject:[NSNumber numberWithBool:NO] forKey:@"eventActive"];
                        [object saveInBackground];
                    } else
                        [self updateLocations]; // puts core circle on mapview
                    
                } else if ([self inYourCoreUserWithPhNumber:[friensoUser valueForKey:@"phoneNumber"]] )
                {
                    // Check if this user is in your core or watchCircle
                    // friensoUser is in my network, am I tracking him/her?
                    if (!DBG) NSLog(@"%@ > %@, %@, %@",friensoUser.username,
                                   [object valueForKey:@"eventType"],object.objectId, [object objectForKey:@"eventActive"]);
                    
                    //if (DBG) NSLog(@"am I watching him/her?: %d", [self ])
                    //[[[CloudUsrEvnts alloc] init] isUserInMy2WatchList:friensoUser];
                    
                    if ([self amiWatchingUserEvent:object.objectId])
                    {
                        //if (DBG) NSLog(@"!!! YES");
                        [self.watchingCoFrArray addObject:friensoUser];
                    } else {
                       if (!DBG) NSLog(@"!!! Not watching this friend yet");
                        /*NSDictionary *dic =[[NSDictionary alloc] initWithObjects:@[friensoUser, forKeys:]*/
                        [self.pendingRqstsArray addObject:object];
                    }
                }
                
                
            

            }// ends for loop
            [self addPendingRequest:self.pendingRqstsArray];
            [self updateMapViewWithUserBubbles:self.watchingCoFrArray];
            
            
        } else
            if (DBG) NSLog(@"parse error: %@", error.localizedDescription);

    }];
    
    //check for awaiting core friend requests
    //Added here so that access to pendingRqstsArray is sequential and we dont need synchronization
    // drawback: Slow. We can do this in parallel with synchronization
    PFQuery * pfquery = [PFQuery queryWithClassName:@"CoreFriendRequest"];
    [pfquery whereKey:@"recipient" equalTo:[PFUser currentUser]];
    [pfquery includeKey:@"sender"];
    [pfquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!DBG) NSLog(@"------ Checking CoreFriendRequest ...");
        if(!error) {
            NSInteger i = [self.pendingRqstsArray count]; // get the next insert position
            //if (DBG) NSLog(@"CoreFriend Request: recipient, req ObjId, status, awaitingResponseFrom");
            for (PFObject *object in objects) {
                //PFUser * sender = [object objectForKey:@"sender"];
                //if (DBG) NSLog(@"%@ : %@ : %@ : %@",sender.objectId, object.objectId, [object objectForKey:@"status"], sender.email);
                
                if ( [[object objectForKey:@"status"] isEqualToString:@"send"] ){
                /*[self addPendingRequest:sender withTag:i reqtype:coreFriendRequest]; // temp add to drawwer+slider
                  NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                         sender,   @"pfUser",
                                         coreFriendRequest, @"reqType",
                                         [NSNumber numberWithInteger:i],@"btnTag", nil];
                */
                    //[self.pendingRqstsArray insertObject:object atIndex:i]; // simulation
                    [self.pendingRqstsArray addObject:object];
                }
                i = i + 1;
            }

            [self addPendingRequest:self.pendingRqstsArray];
        } else {
            // Did not find any UserStats for the current user
            if (DBG) NSLog(@"Error: %@", error);
        }
    }];

}
-(void) coreFriendOnMapInteraction:(TrackingFriendButton*)sender
{
    if ( ![sender isSelected] )
    {
        [sender setSelected:YES];
        
        // Animate selected bubble
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5f];
        
        sender.center = CGPointMake(sender.center.x + 10.0f, sender.center.y );
        sender.center = CGPointMake(sender.center.x - 10.0f, sender.center.y);
        
        [UIView commitAnimations];
        
        NSString *distance = [sender.titleLabel.text componentsSeparatedByString:@"\n"][1];
        UILabel *label = [[UILabel alloc] init];
        [label setText:[NSString stringWithFormat:@"%@\nmiles from you", distance]];
        [label setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:14]];
        [label setNumberOfLines:2];
        [label setTag:sender.tag];
        [self.mapView addSubview:label];
        [label setFrame:CGRectMake(0, sender.frame.origin.y, 120, sender.frame.size.height)];
        [label setCenter:CGPointMake(0, sender.center.y)];
        [UIView animateWithDuration:0.5 animations:^{
            //[label setCenter:CGPointMake(-label.frame.size.width,sender.center.y)];
            [label setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.5f]];
            [label setCenter:CGPointMake(sender.frame.size.width + 10 + label.frame.size.width/2, sender.center.y)];
            }];
    } else {
        [sender setSelected:NO];
        for (id subview in [self.mapView subviews]){
            if ( [subview isKindOfClass:[UILabel class]] && [subview tag] == sender.tag) {
                [subview removeFromSuperview];
                break;
            }
        }
    }
    
    
}
-(void) friendLocInteraction:(UIButton *)sender
{
    /* friendLocInteraction:
    ** Is the action triggered when user touches the button overlay on the mapview.
    ** */
    //if (DBG) NSLog(@"...friendLocInteraction");
//    if (DBG) NSLog(@"[tag:%ld], %@", [sender tag],self.friendsLocationArray);// objectAtIndex:sender.tag]);
//    if (DBG) NSLog(@"watchingCoFrArray:%ld", [self.watchingCoFrArray count]);
//    if (DBG) NSLog(@"%@", self.watchingCoFrArray);
    
    //NSString *coordinateStr =[self.friendsLocationArray objectAtIndex:sender.tag];
    PFGeoPoint *coordinatesPoint = [self.friendsLocationArray objectAtIndex:sender.tag];
    
    //CGFloat geoLatitude = [[coordinateStr componentsSeparatedByString:@","][0] doubleValue];
    //CGFloat geoLongitude = [[coordinateStr componentsSeparatedByString:@","][1] doubleValue];

    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake([coordinatesPoint latitude], [coordinatesPoint longitude]),
                                                   MKCoordinateSpanMake(0.01, 0.01) )];
//    NSArray *array = @[sender.titleLabel.text,                               // Initials
//                       [coordinateStr componentsSeparatedByString:@","][0],  // latitude
//                       [coordinateStr componentsSeparatedByString:@","][1]]; // longitude
    
    // The attributes for the pin annotation
    /*NSArray *array = @[sender.titleLabel.text,                               // Initials
                        [NSString stringWithFormat:@"%f",[coordinatesPoint latitude]],  // latitude
                        [NSString stringWithFormat:@"%f",[coordinatesPoint longitude]]]; // longitude
     */
    PFUser *coreFriend = [self.watchingCoFrArray objectAtIndex:[sender tag]];
    NSArray *array = @[sender.titleLabel.text,
                       [NSString stringWithFormat:@"%f",[coordinatesPoint latitude]],  // latitude
                       [NSString stringWithFormat:@"%f",[coordinatesPoint longitude]], // longitude
                       [coreFriend objectForKey:@"email"]];
                       
    GeoCDPointAnnotation *geoCDPointAnn = [[GeoCDPointAnnotation alloc] initWithObject:array];
    [self.mapView addAnnotation:geoCDPointAnn];
    
#warning Insert an annotation using stored loc info fromCoreData, then update if network availability
    
    /** location for sender.tag **/

    
    if(self.selectedBubbleBtn != NULL) // hold sender and enable last selected bubble
    {
        //sender.center = CGPointMake(sender.center.x, sender.center.y + 10.0f);
        [self.selectedBubbleBtn setEnabled:YES];
        [sender setEnabled:NO];
        
#warning Need to remove last pin
        
    } else {
        [sender setEnabled:NO];
    }
    // Animate selected bubble
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5f];
    sender.center = CGPointMake(sender.center.x, sender.center.y - 10.0f);
    self.selectedBubbleBtn.center = CGPointMake(self.selectedBubbleBtn.center.x, self.selectedBubbleBtn.center.y + 10.0f);

    [UIView commitAnimations];
    self.selectedBubbleBtn = sender;
}
- (void) addCoreFriendBubblesToMap:(MKMapView *)mapView {
    
    
    
    UIButton *mLocBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    UIImage *img =[[FRStringImage alloc] imageWithString:@"👤"
                                                    font:[UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:32.0]
                                                    size:mLocBtn.frame.size];
    [mLocBtn setBackgroundImage:img forState:UIControlStateNormal];
    [mLocBtn setTitle:@"SA" forState:UIControlStateNormal];
    [mLocBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [mLocBtn setTitleColor:UIColorFromRGB(0x8e44ad) forState:UIControlStateHighlighted];
    [mLocBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    [mLocBtn setAlpha:0.8];
    [mLocBtn addTarget:self action:@selector(friendLocInteraction:)
      forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:mLocBtn];
    [mLocBtn setCenter:CGPointMake(mLocBtn.frame.size.width + mLocBtn.center.x,
                                   self.mapView.frame.size.height - mLocBtn.center.y)];
}

- (void)updateLocations {
    if (DBG) NSLog(@"****** UPDATELOCATIONS");
    
    
    
    /** this adds bubbles to the map for all Persons in your CoreFriends list (local core data store) **/
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init]; // Create the fetch request
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CoreFriends"
                                              inManagedObjectContext:[self managedObjectContext]];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"coreType like 'iCore Friends'"]];
//    NSSortDescriptor *phoneSort =  [[NSSortDescriptor alloc] initWithKey:@"corePhone"
//                                                                  ascending:YES];
//        
//    fetchRequest.sortDescriptors = @[phoneSort];
    
    NSError *error;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error.
    } else /*if ( [[self.mapView subviews] count] < [fetchedObjects count])*/{
        NSInteger j = 0;
        for (NSManagedObject *mObject in fetchedObjects) {
            if (DBG) NSLog(@"    %@ | %@ | %@", [mObject valueForKey:@"coreFirstName"], [mObject valueForKey:@"corePhone"], [mObject valueForKey:@"coreLocation"]);
            PFQuery *userQuery = [PFUser query];
            NSString *longPhoneNumber = [self stripStringOfUnwantedChars:[mObject valueForKey:@"corePhone"]];
            NSString *basePhoneNumber = [longPhoneNumber substringFromIndex:(longPhoneNumber.length-10)];
            
            [userQuery whereKey:@"phoneNumber" equalTo:basePhoneNumber];
            [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    PFUser * pfuser = [objects firstObject];
                    if(pfuser != nil) {
                        if (DBG) NSLog(@"users on parse: %@", [pfuser username]); //
                        /*if (DBG) NSLog(@"user %@", [pfuser username]);// these
                        
                        if (DBG) NSLog(@"phone %@", [pfuser objectForKey:@"phoneNumber"]);
                        if (DBG) NSLog(@"location %@", [pfuser objectForKey:@"currentLocation"]);
                        */
                        //if (DBG) NSLog(@"%d: %@",j, basePhoneNumber);
                        [self addCoreFriendLocationToMap:pfuser withIndex:j];
                    }
                } else {
                    if (DBG) NSLog(@"%@", error);
                }
            }];
            j++;
            //if (DBG) NSLog(@"%@",[self stripStringOfUnwantedChars:[mObject valueForKey:@"corePhone"]]);
            
        }
        
    }
    
    // Async update locations from cloud
}
-(void) fetchCurrentLocationForUser:(NSString *) coreFriendObjectId {
    /** Method: fetchCurrentLocationForUser
     coreFriendObjectId: objectId in Parse User class
     the connection has to be done via the phone nbr.
     **/

    PFQuery *query = [PFUser query];
    [query getObjectInBackgroundWithId:coreFriendObjectId
                                 block:^(PFObject *object, NSError *error)
     {
         if (!error) {
             //if (DBG) NSLog(@"%@, %@", (NSString *)[object valueForKey:@"email"], (PFGeoPoint *)[object valueForKey:@"currentLocation"]);
             [self updateCoreFriendEntity:(NSString *)[object valueForKey:@"email"]
                             withLocation:(PFGeoPoint *)[object valueForKey:@"currentLocation"]];
             // Center the map view around this geopoint:
             PFGeoPoint *geoPoint = [object valueForKey:@"currentLocation"];
             [self.mapView setRegion:MKCoordinateRegionMake(
                                                            CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude),
                                                            MKCoordinateSpanMake(0.01, 0.01)
                                                            )];
             /*** if we need to remove the last annotation:
              if([self.mapView.annotations count] > 0)
                 [self.mapView removeAnnotations:[self.mapView annotations]];
             ***/
             GeoPointAnnotation *geoPointAnnotation = [[GeoPointAnnotation alloc] initWithObject:object];
             [self.mapView addAnnotation:geoPointAnnotation];
             // Add friend location event
             [self actionAddFriensoUserLocation:geoPoint forUser:(NSString *)[object valueForKey:@"username"]];
            
         } else
             if (DBG) NSLog(@"!Error: %@ %@", error, [error userInfo]); // Log details of the failure
     }];
}
-(void) lastKnownLocationForFriend:(NSString *)phoneNumber
{
    PFQuery *query = [PFQuery queryWithClassName:@"UserConnection"];
    //NSString *pNumber = [coFrDic objectForKey:keys[1]];
    NSRange substrRange = NSMakeRange(phoneNumber.length-10, 10);
    [query whereKey:@"userNumber" containsString:[phoneNumber substringWithRange:substrRange]];
    //if (DBG) NSLog(@"%@",[phoneNumber substringWithRange:substrRange]);
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error) { // The find succeeded.
             //if (DBG) NSLog(@"%@", objects);
             for (PFObject *object in objects) { // Do something w/ found objects
                 //if (DBG) NSLog(@"%@", object);
                 //if (DBG) NSLog(@"%@", [[object valueForKey:@"user"] objectId]);
                 [self fetchCurrentLocationForUser:[[object valueForKey:@"user"] objectId]];
             }
         } else {
             // Log details of the failure
             if (DBG) NSLog(@"!!Error: %@ %@", error, [error userInfo]);
         }
     }];
}

#pragma mark - MFMessageComposeViewController Delegate method
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result) {
        case MessageComposeResultSent: if (DBG) NSLog(@"SENT"); [self dismissViewControllerAnimated:YES completion:nil]; break;
        case MessageComposeResultFailed: if (DBG) NSLog(@"FAILED"); [self dismissViewControllerAnimated:YES completion:nil]; break;
        case MessageComposeResultCancelled: if (DBG) NSLog(@"CANCELLED"); [self dismissViewControllerAnimated:YES completion:nil]; break;
    }
}
#pragma mark - AlertView Delegate
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    return YES;
}
-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    //if (DBG) NSLog(@"[ will dismiss ]");
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    //if (DBG) NSLog(@"[ did dismiss ]");
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Read the title of the alert dialog box to learn the type of alert view
    NSString *title = alertView.title;
    NSInteger tag_no = alertView.tag;
    
    if ( [title isEqualToString:@"WatchMe"]) {
        switch (buttonIndex) {
            case 0: // dismiss, cancel, or okay
                [trackMeOnOff setOn:NO animated:YES]; // Nothing happens -- no action
                break;
            case 1: // accept
                //if (DBG) NSLog(@"Accept: 1:%ld", buttonIndex);
                [self logAndNotifyCoreFriendsToWatchMe];
                break;
            default:
                break;
        }
    } else if (tag_no >= 100) {
        if (DBG) NSLog(@"CONTACT FRIEND");
        switch (buttonIndex) {
            case 0: // dismiss, cancel, or okay
                if (DBG) NSLog(@"cancel");
                break;
            case 1: // accept
                if (DBG) NSLog(@"Dial");
                [self contactByDialingFriendWithEmail:title];
                break;
            case 2: // SMS
                if (DBG) NSLog(@"SMS");
                [self contactBySMSingFriendWithEmail:title];
            default:
                break;
        }

    } else {
        //read the index in the title to get the position in the array **** not a good design!!! ****
        //NSString *tagNbr= [title substringFromIndex:(title.length -2)];
        //int btnTagNbr   = (int)[tagNbr integerValue];
        PFObject *userEventObject =[self.pendingRqstsArray objectAtIndex:tag_no];

// 23Jun14/SA
//        NSString *requestType = [userEventObject objectForKey:@"eventType"];
//        PFUser *friensoUser = [userEventObject objectForKey:@"friensoUser"];                   // 10Jun14:SA
        NSString *requestType     = ([userEventObject valueForKey:@"eventType"]==NULL) ? coreFriendRequest : [userEventObject valueForKey:@"eventType"];
        PFUser   *friensoUser = ([userEventObject objectForKey:@"friensoUser"] == NULL) ? [userEventObject objectForKey:@"sender"] : [userEventObject objectForKey:@"friensoUser"];
        
        if (DBG) NSLog(@"%@, %@, %@",friensoUser.username, requestType, userEventObject.objectId);
        
        if([requestType isEqualToString:coreFriendRequest])
        {
            
            NSString * response;
            
            if (buttonIndex == 1) // accept
            {
                response = @"accept";
                if (DBG) NSLog(@" corefriend request accepted");
            } else if (buttonIndex == 2) { //reject
                response = @"reject";
                if (DBG) NSLog(@" corefriend request rejected");
            } else { //dismiss
                if (DBG) NSLog(@"dismissed alertview");
                return;
            }
            
            //update the db with the choices made by the user
            PFQuery *pfquery = [PFQuery queryWithClassName:@"CoreFriendRequest"];
            //[pfquery whereKey:@"sender" equalTo:friensoUser];
            [pfquery whereKey:@"objectId" equalTo:userEventObject.objectId];
//            [pfquery whereKey:@"recipient" equalTo:[PFUser currentUser]];
//            [pfquery whereKey:@"awaitingResponseFrom" equalTo:@"recipient"];
//            [pfquery whereKey:@"status" equalTo:@"send"];
//            [pfquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [pfquery getFirstObjectInBackgroundWithBlock:^(PFObject *pfobject, NSError *error) {
//                if(!error && ![objects isEqual:[NSNull null]]) {
//                    //TODO: check if first element is not null
//                    PFObject * pfobject =[objects firstObject];
                    if(pfobject != nil) {
                        pfobject[@"awaitingResponseFrom"] = @"sender";
                        pfobject[@"status"] = response;
                        [pfobject saveInBackground];
                        
                        //remove the button from the view
                        for (id subview in [self.scrollView subviews]){
                            if ( [subview isKindOfClass:[PendingRequestButton class]] ) {
                                if (tag_no ==  [(PendingRequestButton *)subview tag])
                                {
                                    [subview removeFromSuperview];
                                    // Now update requests count
                                    [self.pendingRqstsArray removeObjectAtIndex:tag_no];
                                    [self.scrollView updatePendingRequests:self.pendingRqstsArray];
                                }
                            }
                        }//
                    } //ends if
                
            }];
        } else { // request is external of either watchMe or helpNow

            if (buttonIndex == 1) // accept
            {
                //[self addUserBubbleToMap:friensoUser  withTag:tag_no]; // accepted to watch this user
                if (!DBG) NSLog(@"number of subviews: %ld", (long)[self.scrollView subviews].count);
                // Remove pending request bubble from pendingDrawer
                for (id subview in [self.scrollView subviews]){
                    
                    if ( [subview isKindOfClass:[PendingRequestButton class]] ) {
                        if (!DBG) NSLog(@"self.pendingRqstsArray: %ld",(long)self.pendingRqstsArray.count);
                        if (tag_no ==  [(PendingRequestButton *)subview tag] &&
                            (self.pendingRqstsArray.count > 0))
                        {
                            //if (DBG) NSLog(@"[0]:tag=%ld, tag_no: %d", (long)[(UIButton *)subview tag], (int) tag_no );
                            [subview removeFromSuperview];
                            
                            // UserEvent maintain request status (tracking)
                            CloudUsrEvnts *userEvent = [[CloudUsrEvnts alloc] init];
                            [userEvent trackingUserEvent:userEventObject withStatus:@"accepted"
                                               trackedBy:[PFUser currentUser] ];
                            
                            // Now update requests count
                            [self.pendingRqstsArray removeObjectAtIndex:tag_no];
                            [self.scrollView updatePendingRequests:self.pendingRqstsArray];
                            [self.watchingCoFrArray addObject:friensoUser];
                            
                            // set FriensoEvent, make the watching your friend X sticky
                            //[[[WatchingCoreFriend alloc] init] trackUserEventLocally:friensoUser];
                            /****** migrate this code to its own class ******/
                            [self trackUserEventLocally:userEventObject];
                        }
                        
                    }   // ends if
                }       // ends for
                NSLog(@"pending requests: %ld",(long)self.pendingRqstsArray.count);
                [self updateMapViewWithUserBubbles: self.watchingCoFrArray];
                for (id subview in [self.scrollView subviews]){
                    if ( [subview isKindOfClass:[PendingRequestButton class]] ) {
                        NSLog(@"A PENDING REQUEST FOUND IN SCROLLVIEW");
                        [self refreshMapViewAction:nil];
                    }
                    
                }
                
            } else if (buttonIndex == 2) // reject
            {
                if (DBG) NSLog(@"'request' rejected ");
                // log the reject to the cloud
                // remove the request and update
                
                for (id subview in [self.scrollView subviews]){
                    if ( [subview isKindOfClass:[PendingRequestButton class]] ) {
                        if (tag_no ==  [(PendingRequestButton *)subview tag])
                        {
                            [subview removeFromSuperview];
                            // Cloud track request
                            [[[CloudUsrEvnts alloc] init] trackingUserEvent:userEventObject
                                                                  withStatus:@"rejected"
                                                                  trackedBy:[PFUser currentUser]
                             ];
                            // Now update requests count
                            [self.pendingRqstsArray removeObjectAtIndex:tag_no];
                            [self.scrollView        updatePendingRequests:self.pendingRqstsArray];
                            // update Cloud-Store
                        }
                    }
                    
                }
            }else // dismiss
            {
                if (DBG) NSLog(@"dismissed alertview");
            }
        } // ends the if/else for the requestType
    }
}
-(void) isUserInMy2WatchList:(PFUser*)friensoUser{
    
}

#pragma mark - Helper Methods
-(UIImageView *) newImageViewWithImage:(UIImage *)image showInFrame:(CGRect)paramFrame{
    UIImageView *result = [[UIImageView alloc] initWithFrame:paramFrame];
    result.contentMode  = UIViewContentModeScaleAspectFit;
    result.image        = image;
    return result;
}
- (NSString *) stripStringOfUnwantedChars:(NSString *)phoneNumber {
    NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    return cleanedString;
}
/*  REFERENCED WORK
 *  http://borkware.com/quickies/one?topic=Graphics
 *  http://stackoverflow.com/questions/10895035/coregraphics-draw-an-image-on-a-white-canvas
 *  http://iwork3.us/2013/09/13/pantone-ny-fashion-week-2014-spring-colors/
 *  http://stackoverflow.com/questions/14924151/create-a-round-gradient-progress-bar-in-ios-with-coregraphics
 *
 **/

@end

