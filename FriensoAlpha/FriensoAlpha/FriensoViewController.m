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
//#import "FriensoPersonalEvent.h"
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

#define MAPVIEW_DEFAULT_BOUNDS  CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height * 0.5)
#define ARC4RANDOM_MAX  0x100000000
#define UIColorFromRGB(rgbValue)  [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define CELL_CONTENT_MARGIN  10.0f

static NSString *eventCell          = @"eventCell";
static NSString *trackRequest       = @"trackRequest";
static NSString *coreFriendRequest  = @"coreFriendRequest";

enum PinAnnotationTypeTag {
    PinAnnotationTypeTagGeoPoint = 0,
    PinAnnotationTypeTagGeoQuery = 1
};


@interface FriensoViewController ()
{
    NSMutableArray *coreFriendsArray;
    UISwitch       *trackMeOnOff;

}

@property (nonatomic,strong) NSFetchedResultsController *frc;
@property (nonatomic,strong) UIActivityIndicatorView    *loadingView;
@property (nonatomic,strong) UserResponseScrollView     *scrollView;
@property (nonatomic,retain) NSArray        *appFrameProperties;
@property (nonatomic,retain) NSMutableArray *friendsLocationArray;
@property (nonatomic,retain) NSMutableArray *pendingRqstsArray; // pending requests array
@property (nonatomic,retain) NSMutableArray *watchingCoFrArray; // watching coreFriends array
@property (nonatomic,strong) CLLocation     *location;
@property (nonatomic,strong) UITableView    *tableView;
@property (nonatomic,strong) UIButton       *selectedBubbleBtn;
@property (nonatomic,strong) UIButton       *fullScreenBtn;

@property (nonatomic,strong) UISwitch       *trackMeOnOff;
@property (nonatomic,strong) UILabel        *drawerLabel;
@property (nonatomic)        CGFloat scrollViewY;
@property (nonatomic)        CGRect normTableViewRect;
@property (nonatomic) const CGFloat mapViewHeight;

-(void)actionPanicEvent:(UIButton *)theButton;
-(void)viewMenuOptions: (UIButton *)theButton;
-(void)viewCoreCircle:  (UIButton *)theButton;
-(void)makeFriensoEvent:(UIButton *)theButton;


@end

@implementation FriensoViewController
@synthesize locationManager  = _locationManager;
@synthesize trackMeOnOff     = _trackMeOnOff;
//@synthesize helpMeNowSwitch  = _helpMeNowSwitch;

/** useful calls:
 ** CGRect fullScreenRect=[[UIScreen mainScreen] applicationFrame];
 ** **/


-(void)actionPanicEvent:(UIButton *)theButton {
    [self animateThisButton:theButton];
    [theButton setHidden:YES];
    [theButton.layer setBorderColor:[UIColor redColor].CGColor];
    [self performSegueWithIdentifier:@"panicEvent" sender:self];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:self.navigationItem.backBarButtonItem.style
                                                                            target:nil
                                                                            action:nil];
    [self setupHelpMeNowSwitch];
}
-(void) setupHelpMeNowSwitch
{
    helpMeNowSwitch = [[UISwitch alloc] init];
    [helpMeNowSwitch addTarget:self action:@selector(helpMeNowSwitchAction:)
           forControlEvents:UIControlEventValueChanged];
    [helpMeNowSwitch setCenter:CGPointMake(self.navigationController.toolbar.bounds.size.width*0.85, 22)];
    helpMeNowSwitch.layer.cornerRadius = helpMeNowSwitch.frame.size.height/2.0;
    helpMeNowSwitch.layer.borderWidth =  1.0;
    helpMeNowSwitch.layer.borderColor = [UIColor blackColor].CGColor;
    [self.navigationController.toolbar addSubview:helpMeNowSwitch];
    [helpMeNowSwitch setCenter:self.helpMeNowBtn.center];
    [helpMeNowSwitch setOn:YES animated:YES];
    [helpMeNowSwitch setOnTintColor:[UIColor redColor]];
    
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
    NSLog(@"%ld", (long)[tableView cellForRowAtIndexPath:indexPath].tag);
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
    NSLog(@"table view origin %f", self.tableView.frame.origin.y);
    
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
            [tvHeaderView setTitle:@"▽ Dismiss" forState:UIControlStateNormal];
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
//    //NSLog(@"! Locate Core Friends");
//    NSString *helpObjId = [[NSUserDefaults standardUserDefaults] objectForKey:@"helpObjId"];
//    if (helpObjId != nil ) {
//        NSLog(@"    We have an active helpMeNow event");
//    } else
//        NSLog(@"    NO active helpMeNow event");
//    
//    //    // round up your core Friends and show them on the map and have access to their location
////    // First check to see if the objectId already exists
////    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"FriensoEvent"
////                                                         inManagedObjectContext:[self managedObjectContext]];
////    NSFetchRequest *request = [[NSFetchRequest alloc] init];
////    [request setPredicate:[NSPredicate predicateWithFormat:@"eventCategory like 'helpNow'"]];
////    [request setEntity:entityDescription];
////    // Create the sort descriptors array.
////    NSSortDescriptor *authorDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eventCreated" ascending:NO];
////    NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eventModified" ascending:NO];
////    NSArray *sortDescriptors = @[authorDescriptor, titleDescriptor];
////    [request setSortDescriptors:sortDescriptors];
////
////    //BOOL unique = YES;
////    NSError  *error;
////    NSArray *items = [[self managedObjectContext] executeFetchRequest:request error:&error];
////    NSLog(@"items: %u", items.count);
////    if (items != nil) {
////        for (NSManagedObject *mObject in items) {
////            NSLog(@"  %@,%@,%@,%@",[mObject valueForKey:@"eventTitle"],[mObject valueForKey:@"eventObjId"],
////                  [mObject valueForKey:@"eventCategory"],[mObject valueForKey:@"eventModified"]);
////        }
////    }
//#warning Add a status to the FriensoEvent entity to maintain the status of the event
//#warning Disable when the user turns off the button; remove coreFriends from mapView
//    
//}
-(void) helpMeNowSwitchAction:(UISwitch*)sender
{
    
    // log event on the cloud
    CloudUsrEvnts *watchMeEvent = [[CloudUsrEvnts alloc] initWithAlertType:@"helpNow"];
    [watchMeEvent disableEvent];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"helpObjId"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // Remove switch from UI
    [helpMeNowSwitch removeFromSuperview];
    // Remove buttons and labels corresponding to coreFriends
    for (id subview in [self.mapView subviews])
    {
        UILabel *label = subview;
        if (label.tag > 99)
            [label removeFromSuperview];
    }
    
    // Add back the std icon/btn
    [self.helpMeNowBtn setHidden:NO];
}
-(void) contactByDialingFriendWithEmail:(NSString *)friendEmail
{
    PFQuery *query= [PFUser query];
    [query whereKey:@"username" equalTo:friendEmail];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error)
        {
            //NSLog(@"%@", [object objectForKey:@"phoneNumber"]);
            NSString *phoneNumber = [NSString stringWithFormat:@"tel://%@",[object objectForKey:@"phoneNumber"]];
            @try {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
            }
            @catch (NSException *exception){
                NSLog(@"%@", exception.reason);
            }
            @finally {
                NSLog(@"Calling: %@",friendEmail);
            }
            
        }
        
    }];
    
}
-(void) contactBySMSingFriendWithEmail:(NSString *)friendEmail
{
    /*  the query is not working
        might want to consider querying coreData */
    //NSLog(@"friend email: %@", friendEmail);
    PFQuery *query= [PFUser query];
    [query whereKey:@"username" equalTo:friendEmail];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error)
        {
            //NSLog(@"%@", [object objectForKey:@"phoneNumber"]);
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
                NSLog(@"Device not configured to send SMS.");
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
    //NSLog(@"Friends I currently track:");
    
    
    NSInteger btnNbr = 0;
    for (PFUser *parseUser  in trackingFriendsArray)
    {
        NSLog(@"\t %@", parseUser.username);
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
        //[mLocBtn setCenter:CGPointMake(btnCenterX, self.mapView.frame.size.height - mLocBtn.center.y)];
        [mLocBtn setCenter:CGPointMake(btnCenterX, self.mapView.frame.size.height - mLocBtn.center.y*2)];
        
        
        // Allows access to location info to userBubble
        PFGeoPoint *geoNDIN = [PFGeoPoint geoPointWithLatitude:41.700278
                                                     longitude:-86.238611];// notre dame, in
        [self.friendsLocationArray insertObject:([parseUser valueForKey:@"currentLocation"] == NULL)  ? geoNDIN : [parseUser valueForKey:@"currentLocation"]  atIndex:btnNbr];
        btnNbr++;
    }
    
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
    CLLocationDistance distance = [locA distanceFromLocation:locB] * 0.621371 /* convert to miles */;
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
//    PFGeoPoint *geoNDIN = [PFGeoPoint geoPointWithLatitude:41.700278
//                                                 longitude:-86.238611];// notre dame, in
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
    
    //    NSLog(@"add User Bubble To Map: %ld",tagNbr);
    //    NSLog(@"subviews: %ld", [self.mapView subviews].count);
    //
    for (id subview in [self.mapView subviews]){
        if ( [subview isKindOfClass:[UIButton class]] )
        {
            //NSLog(@"subview tag: %ld", [subview tag]);
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
    PFGeoPoint *geoNDIN = [PFGeoPoint geoPointWithLatitude:41.700278
                                                 longitude:-86.238611];// notre dame, in
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
    
    NSDictionary *frUserDic = [self.pendingRqstsArray objectAtIndex:btn.tag]; // 10Jun14:SA
    PFUser *friensoUser = [frUserDic objectForKey:@"pfUser"];  // 10Jun14:SA
    NSString * type = [frUserDic objectForKey:@"reqType"];
    
    if([type isEqualToString:coreFriendRequest]) { //if core friend request
        //TODO: we do not need to add the btn.tag here.
        //may be we can extend UIAlertView and add a variable for the index.
        //NSLog(@"btn tag = %d",btn.tag);
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

    NSLog(@"-- addPendingRequest:(NSArray*)userRequestArray --");
    [self.scrollView setPendingRequests:self.pendingRqstsArray];
    NSInteger arrayIndex = 0;
    for (PFObject *eventObject in userRequestArray)
    {
        NSString *reqType     = ([eventObject valueForKey:@"eventType"]==NULL) ? coreFriendRequest : [eventObject valueForKey:@"eventType"];
        PFUser   *friensoUser = ([eventObject objectForKey:@"friensoUser"] == NULL) ? [eventObject objectForKey:@"sender"] : [eventObject objectForKey:@"friensoUser"];
        NSLog(@"{%@} is requesting a <%@> request.", friensoUser.username, reqType);
        [self addPendingRequest:friensoUser
                        withTag:arrayIndex
                        reqtype:reqType];
        arrayIndex++;
        
    }
}
-(void) addPendingRequest:(PFUser *)parseFriend withTag:(NSInteger)tagNbr reqtype:(NSString *) type{
    if ([type isEqualToString:coreFriendRequest]) {
        [self addPndngRqstButton:[UIColor redColor] withFriensoUser:parseFriend withTag:tagNbr];
    } else {
        [self addPndngRqstButton:[UIColor whiteColor] withFriensoUser:parseFriend withTag:tagNbr];
        
        PFGeoPoint *geoNDIN = [PFGeoPoint geoPointWithLatitude:41.700278
                                                      longitude:-86.238611];// notre dame, in
        [self.friendsLocationArray insertObject:([parseFriend valueForKey:@"currentLocation"] == NULL)  ? geoNDIN  : [parseFriend valueForKey:@"currentLocation"]  atIndex:tagNbr];
    }
}

- (void) addPndngRqstButton: (UIColor *) fontColor  withFriensoUser:(PFUser *)parseFriend withTag:(NSInteger)tagNbr{
    // addPendingRequest  adds a pending request to drawer+slider that user can interact w/ Pfuser
    PendingRequestButton *pndngRqstBtn = [[PendingRequestButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    UIImage *img =[[FRStringImage alloc] imageTextBubbleOfSize:pndngRqstBtn.frame.size];
    [pndngRqstBtn setBackgroundImage:img forState:UIControlStateNormal];
    NSString *bubbleLabel = [[parseFriend.username substringToIndex:2] uppercaseString];
    [pndngRqstBtn setTitle:bubbleLabel forState:UIControlStateNormal];
    [pndngRqstBtn setTitleColor:fontColor forState:UIControlStateNormal];
    [pndngRqstBtn setTitleColor:UIColorFromRGB(0x8e44ad) forState:UIControlStateHighlighted];
    [pndngRqstBtn setTag:tagNbr];
    [pndngRqstBtn addTarget:self action:@selector(pendingRqstAction:)
           forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:pndngRqstBtn];
    
    CGFloat btnCenterX = pndngRqstBtn.center.x*2 + pndngRqstBtn.center.x*2*tagNbr;
    //NSLog(@"%f",self.scrollView.frame.size.height*1.6);
    [pndngRqstBtn setCenter:CGPointMake(btnCenterX, pndngRqstBtn.center.y*1.3)];
}



-(void) trackMeSwitchEnabled:(UISwitch *)sender {
    NSLog(@"********* trackMeswitchEnabled ****");
    
    if ([sender isOn]){
        // Alert the user
        [[[UIAlertView alloc] initWithTitle:@"WatchMe"
                                    message:@"CoreCircle of friends will be notified and your location shared."
                                   delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Okay", nil] show];
        
        UILabel *trackMeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [trackMeLabel setText:@"Watch Me"];
        [trackMeLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Thin" size:14.0]];
        [trackMeLabel sizeToFit];
        [self.navigationController.navigationBar addSubview:trackMeLabel];
        [trackMeLabel setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
        [trackMeLabel setCenter:sender.center];

        // animate help
        [self animateHelpView:trackMeLabel];
        [UIView animateWithDuration:3.0
                         animations:^{trackMeLabel.alpha = 0.0;}
                         completion:^(BOOL finished){ [trackMeLabel removeFromSuperview]; }];
        
        
    } else {
        NSLog(@"Stop the watchMe event");
        [[[UIAlertView alloc] initWithTitle:@"WatchMe"
                                    message:@"Your location sharing will stop"
                                   delegate:self
                          cancelButtonTitle:@"Okay"
                          otherButtonTitles:nil] show];
        CloudUsrEvnts *watchMeEvent = [[CloudUsrEvnts alloc] initWithAlertType:@"watchMe"];
        [watchMeEvent disableEvent];
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

#define BYPASSFRIENDREQUESTS 1
-(void) logAndNotifyCoreFriendsToWatchMe {
    NSLog(@"logAndNotifyCoreFriendsToWatchMe");
    
    /**************PUSH NOTIFICATIONS: WATCH ME NOW!!!! *****************/
    if (BYPASSFRIENDREQUESTS) {
        CloudUsrEvnts *watchMePushNots = [[CloudUsrEvnts alloc] initWithAlertType:@"watchMe"];
        [watchMePushNots sendNotificationsToCoreCircle];
        
    } else {
    //Query Parse to know who your "accepted" core friends are and send them each a notification
    
    PFQuery *query = [PFQuery queryWithClassName:@"CoreFriendRequest"];
    [query whereKey:@"status" equalTo:@"accept"];
    [query whereKey:@"sender" equalTo:[PFUser currentUser]];
    [query includeKey:@"recipient"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %ld scores.", (unsigned long)objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                NSString *myString = @"Ph";
                NSString *personalizedChannelNumber = [myString stringByAppendingString:object[@"recipient"][@"phoneNumber"]];
                NSLog(@"Phone Number for this friend is: %@", personalizedChannelNumber);
                
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
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    /**************END OF PUSH NOTIFICATIONS: WATCH ME!!!! *****************/
    }
    
    // Watch Me event tracking
    CloudUsrEvnts *watchMeEvent = [[CloudUsrEvnts alloc] initWithAlertType:@"watchMe"
                                                        eventStartDateTime:[NSDate date] ];
    [watchMeEvent setPersonalEvent];
    [watchMeEvent sendToCloud];
}

#pragma mark - Interaction with NSUserDefaults
-(BOOL) inYourCoreUserWithPhNumber:(NSString *)phNumberOnWatch  {
    /** inYourCoreUserWithPhNumber
     **
     ** - for each phone number passed by argument, check it against the three coreFriends' phone numbers
     ** - if j counter ends up with a value of 3, there is no match if below 3, then there is a match
     ** */
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
        if ( ![str isEqualToString:phNumberOnWatch]){
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
    [refreshMavpViewBtn setCenter:CGPointMake(refreshMavpViewBtn.center.x * 2.0,
                                              refreshMavpViewBtn.center.y *1.2 ) ];
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
    
    // Initialize mapView 
    [self.locationManager startUpdatingLocation];
    [self setInitialLocation:self.locationManager.location];
    self.mapView.region = MKCoordinateRegionMake(self.location.coordinate, MKCoordinateSpanMake(0.05f, 0.05f));
    if([self.loadingView isAnimating])
        [self.loadingView stopAnimating];
    
    // CONFIGUREOVERLAY->check for pending requests-> if user accepts requests, add overlay to mapview
    [self configureOverlay];
    

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
        // local events fetched ok ->NSLog(@"Successfully fetched.");
    } else {
        NSLog(@"Failed to fetch.");
    }
    
    [self.tableView addSubview:tableHelpView];
    [self animateHelpView:tableHelpView];
    [UIView animateWithDuration:3.0
                     animations:^{tableHelpView.alpha = 0.0;}
                     completion:^(BOOL finished){ [tableHelpView removeFromSuperview]; }];
}

-(void) setupToolBarIcons{
    self.navigationController.toolbarHidden = NO;

    //UIColor *violetTulip = [UIColor colorWithRed:155.0/255.0 green:144.0/255.0 blue:182.0/255.0 alpha:1.0];
    // Left CoreCircle button
//    FriensoCircleButton *coreCircleBtn = [[FriensoCircleButton alloc]
//                                          initWithFrame:CGRectMake(0, 0, 27, 27)];
    UIButton *coreCircleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
    [coreCircleBtn setTitle:@"👥" forState:(UIControlStateNormal)];
    if (![coreCircleBtn isEnabled])
        [coreCircleBtn setEnabled:YES];
    [coreCircleBtn addTarget:self action:@selector(viewCoreCircle:)
            forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barLeftButton=[[UIBarButtonItem alloc] init];
    [barLeftButton setCustomView:coreCircleBtn];
    [coreCircleBtn setCenter:CGPointMake(44.0f,22)];
    
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
    self.helpMeNowBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
    [self.helpMeNowBtn addTarget:self action:@selector(actionPanicEvent:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.helpMeNowBtn setTitle:@"\u26A0" forState:(UIControlStateNormal)];
//    self.helpMeNowBtn.layer.cornerRadius = 4.0f;
//    self.helpMeNowBtn.layer.borderWidth  = 1.0f;
//    self.helpMeNowBtn.layer.borderColor  = UIColorFromRGB(0x006bb6).CGColor;;
    self.helpMeNowBtn.titleLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:107.0/255.0 blue:182.0/255.0 alpha:1.0];
    [self.helpMeNowBtn setCenter:CGPointMake(self.navigationController.toolbar.center.x, 22)];
    
    [self.navigationController.toolbar addSubview:coreCircleBtn]; // left
    [self.navigationController.toolbar addSubview:button]; // right
    [self.navigationController.toolbar addSubview:self.helpMeNowBtn]; // center

}
-(void) setupNavigationBarImage{
    // #3498db peter river
    // #ecf0f1 clouds
    
    //[self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0x3498db)];//[UIColor colorWithHue:.580555 saturation:0.31 brightness:0.90 alpha:0.5]
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHue:.580555 saturation:0.31 brightness:0.90 alpha:0.5]];
    //[self.navigationController.toolbar setBarTintColor:UIColorFromRGB(0xecf0f1)];
    //[self.navigationController.toolbar setBarTintColor:[UIColor colorWithWhite:0.9 alpha:0.5]];
    
    //[self.view setBackgroundColor:UIColorFromRGB(0xecf0f1)];
    //[self.view setBackgroundColor:[UIColor colorWithHue:.580555 saturation:0.31 brightness:0.90 alpha:0.5]];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                      shadow, NSShadowAttributeName,
                                                                      [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:21.0], NSFontAttributeName, nil]];
    self.navigationItem.title = @"FRIENSO";
    
    //[self.navigationController.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:16.0], NSFontAttributeName,nil]];
    
    
    // Right Options Button
    trackMeOnOff = [[UISwitch alloc] init];
    
    [trackMeOnOff addTarget:self action:@selector(trackMeSwitchEnabled:)
           forControlEvents:UIControlEventValueChanged];
    [trackMeOnOff setCenter:CGPointMake(self.navigationController.toolbar.bounds.size.width*0.85, 22)];
    trackMeOnOff.layer.cornerRadius = trackMeOnOff.frame.size.height/2.0;
    trackMeOnOff.layer.borderWidth =  1.0;
    trackMeOnOff.layer.borderColor = [UIColor whiteColor].CGColor;
    
    // Local store check for active event
    if( [[[CloudUsrEvnts alloc] init] activeAlertCheck]) {
        NSLog(@"Yes, an alert is active!");
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
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    printf("[ Home View: FriensoVC ]\n");
    
    // Determine App Frame
    self.appFrameProperties = [[NSArray alloc] initWithObjects:
                               [NSValue valueWithCGRect:[[UIScreen mainScreen] applicationFrame]],
                               [NSValue valueWithCGRect:self.navigationController.navigationBar.frame],
                               [NSValue valueWithCGRect:self.navigationController.toolbar.frame], nil];
    
    self.friendsLocationArray = [[NSMutableArray alloc] init]; // friends location cache
    self.pendingRqstsArray    = [[NSMutableArray alloc] init]; // Init pending requests holding array
    self.watchingCoFrArray    = [[NSMutableArray alloc] init];
    
    
    
    // Show progress indicator to tell user to wait a bit
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.loadingView setColor:UIColorFromRGB(0xf47d44)];
    [self.view addSubview:self.loadingView];
    [self.loadingView setCenter:CGPointMake(self.view.center.x, self.view.bounds.size.height*0.2)];
    [self.loadingView startAnimating];
    
    //NSLog(@"%ld",(long)[[NSUserDefaults standardUserDefaults] boolForKey:@"getStartedFlag"] );
    //NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"adminID"]  );
    // Present WelcomeView if these properties have not been set
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"getStartedFlag"])
    {
        [self performSelector:@selector(segueToWelcomeVC) withObject:self afterDelay:1];
        NSLog(@"{ Presenting Welcome View}");
    } else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"getStartedFlag"] &&
               [[NSUserDefaults standardUserDefaults] objectForKey:@"adminID"] != NULL){
        NSLog(@"- viewDidLoad, getstarted flag ok, adminID not null");
        
        [self loginCurrentUserToCloudStore]; // login to cloud store
        
        
        
        //[self setupUI];
   
    }
    
    
    
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"!viewDidAppear");

    // Hide the Options Menu when navigating to Options, otherwise show
    for (id subview in [self.navigationController.toolbar subviews]){
        if ( [subview isKindOfClass:[FriensoOptionsButton class]] )
        {
            if ([subview isHidden])
                [subview setHidden:NO];
        }
    }
    
//    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"helpObjId"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//
//    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"helpObjId"]);
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"helpObjId"] != nil )
        [self updateLocations];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"helpNowCancelled"] == 1) {
        //NSLog(@"%d",[[NSUserDefaults standardUserDefaults] boolForKey:@"helpNowCancelled"]);
        [helpMeNowSwitch removeFromSuperview];
        [self.helpMeNowBtn setHidden:NO];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"helpNowCancelled"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }

    NSNumber *installStepNum = [[NSUserDefaults standardUserDefaults] valueForKey:@"installationStep"];
    if (installStepNum == NULL &&
        [[NSUserDefaults standardUserDefaults] boolForKey:@"getStartedFlag"])
    {
        // Presenting loginView
        [self performSelector:@selector(segueToLoginVC) withObject:self afterDelay:1];
        
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:@"installationStep"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    } else if ([installStepNum isEqualToNumber:[NSNumber numberWithInteger:0]] &&
               [[NSUserDefaults standardUserDefaults] objectForKey:@"adminID"] != NULL ) {
    
        NSLog(@"{First install}");
        
        // At first install, cache univesity/college emergency contacts
        [[[CloudEntityContacts alloc] initWithCampusDomain:@"nd.edu"] fetchEmergencyContacts:@"inst,contact"];
        
        // Login to Parse
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if ( [userDefaults objectForKey:@"adminID"] != NULL ) {
            [PFUser logInWithUsernameInBackground:[userDefaults objectForKey:@"adminID"]
                                         password:[userDefaults objectForKey:@"adminPass"]
                                            block:^(PFUser *user, NSError *error) {
                                                if (!user) {
                                                    NSLog(@"Login to Parse failed with this error: %@",error);
                                                } else {
                                                    
                                                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:1] forKey:@"installationStep"];
                                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                                    
                                                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"newUserFlag"]){
                                                        [self performSegueWithIdentifier:@"newCoreCircle" sender:self];
                                                        //NSLog(@"{Presenting newCoreCircle}");
                                                    } else
                                                        [self runNormalModeUI];
                                                }
                                            }];
            
            // If the following ACL settins are required: Set the proper ACLs
            /*        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
             [ACL setPublicReadAccess:YES];
             [PFACL setDefaultACL:ACL withAccessForCurrentUser:YES];
             */
        } // otherwise do nothing
        
        
        
        
    } else if ([installStepNum isEqualToNumber:[NSNumber numberWithInteger:1]])     {
        NSLog(@"  After First install");
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:2] forKey:@"installationStep"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self runNormalModeUI];
//        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"newUserFlag"]){
//            [self performSegueWithIdentifier:@"newCoreCircle" sender:self];
//            //NSLog(@"{Presenting newCoreCircle}");
//        } else
//            [self runNormalModeUI];
//        
//    } else if ([installStepNum isEqualToNumber:[NSNumber numberWithInteger:2]])     {
//        NSLog(@"+++++++++++   Returns from coreCircle vc");
//        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:3] forKey:@"installationStep"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        
//        // Login to Parse
//        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//        if ( [userDefaults objectForKey:@"adminID"] != NULL ) {
//            [PFUser logInWithUsernameInBackground:[userDefaults objectForKey:@"adminID"]
//                                         password:[userDefaults objectForKey:@"adminPass"]
//                                            block:^(PFUser *user, NSError *error) {
//                                                if (!user) {
//                                                    NSLog(@"Login to Parse failed with this error: %@",error);
//                                                }
//                                            }];
//            
//            // If the following ACL settins are required: Set the proper ACLs
//            /*        PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
//             [ACL setPublicReadAccess:YES];
//             [PFACL setDefaultACL:ACL withAccessForCurrentUser:YES];
//             */
//        } // otherwise do nothing
//        // Check if self is currentUser (Parse)
//        PFUser *currentUser = [PFUser currentUser];
//        if (currentUser) {
//            NSLog(@"Successful login to Parse:%@",currentUser.email);
//        } else
//            NSLog(@"no current user");
//        
//        // Determine App Frame
//        self.appFrameProperties = [[NSArray alloc] initWithObjects:
//                                   [NSValue valueWithCGRect:[[UIScreen mainScreen] applicationFrame]],
//                                   [NSValue valueWithCGRect:self.navigationController.navigationBar.frame],
//                                   [NSValue valueWithCGRect:self.navigationController.toolbar.frame], nil];
//        
//        self.friendsLocationArray = [[NSMutableArray alloc] init]; // friends location cache
//        self.pendingRqstsArray    = [[NSMutableArray alloc] init]; // Init pending requests holding array
//        
//        // Show progress indicator to tell user to wait a bit
//        self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        [self.loadingView setColor:UIColorFromRGB(0xf47d44)];
//        [self.view addSubview:self.loadingView];
//        [self.loadingView setCenter:CGPointMake(self.view.center.x, self.view.bounds.size.height*0.2)];
//        [self.loadingView startAnimating];
//        
//        // Seting up the UI
//        [self setupToolBarIcons];
//        [self setupNavigationBarImage];
//        [self setupMapView];
//        [self setupRequestScrollView];
//        [self setupEventsTableView];
//        
//        
//        
//        [self.locationManager startUpdatingLocation];
//        [self setInitialLocation:self.locationManager.location];
//        self.mapView.region = MKCoordinateRegionMake(self.location.coordinate, MKCoordinateSpanMake(0.05f, 0.05f));
//        if([self.loadingView isAnimating])
//            [self.loadingView stopAnimating];
//        
//        
//        //  Cache resources from parse // The className to query on
//        PFQuery *query = [PFQuery queryWithClassName:@"Resources"];
//        [query orderByDescending:@"createdAt"];
//        query.cachePolicy = kPFCachePolicyNetworkElseCache;
//        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//            if (!object) {
//                NSLog(@"The getFirstObject request failed.");
//            } else {
//                
//                FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//                
//                NSManagedObjectContext *managedObjectContext =
//                appDelegate.managedObjectContext;
//                
//                // First check to see if the objectId already exists
//                NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"FriensoEvent"
//                                                                     inManagedObjectContext:managedObjectContext];
//                NSFetchRequest *request = [[NSFetchRequest alloc] init];
//                [request setPredicate:[NSPredicate predicateWithFormat:@"eventObjId like %@",object.objectId]];
//                [request setEntity:entityDescription];
//                BOOL unique = YES;
//                NSError  *error;
//                NSArray *items = [managedObjectContext executeFetchRequest:request error:&error];
//                if(items.count > 0){
//                    unique = NO;
//                    
//                }
//                if (unique) {
//                    FriensoEvent *firstFriensoEvent =
//                    [NSEntityDescription insertNewObjectForEntityForName:@"FriensoEvent"
//                                                  inManagedObjectContext:managedObjectContext];\
//                    
//                    if (firstFriensoEvent != nil)
//                    {
//                        
//                        firstFriensoEvent.eventTitle     = [object valueForKey:@"resource"];
//                        firstFriensoEvent.eventSubtitle  = [object valueForKey:@"detail"];
//                        firstFriensoEvent.eventLocation  = [object valueForKey:@"ResourceLink"];
//                        firstFriensoEvent.eventCategory  = [object valueForKey:@"categoryType"];
//                        firstFriensoEvent.eventCreated   = [NSDate date];
//                        firstFriensoEvent.eventModified  = object.createdAt;
//                        firstFriensoEvent.eventObjId     = object.objectId;
//                        firstFriensoEvent.eventImage     = [object valueForKey:@"rImage"];
//                        firstFriensoEvent.eventPriority  = [NSNumber numberWithInteger:2];
//                        
//                        NSError *savingError = nil;
//                        if([managedObjectContext save:&savingError]) {
//                            NSLog(@"Successfully cached the resource");
//                        } else
//                            NSLog(@"Failed to save the context. Error = %@", savingError);
//                        // update the Parse record:
//                        [object setObject:[NSNumber numberWithBool:YES]
//                                   forKey:@"wasCached"];
//                        [object saveInBackground];
//                        
//                    } else {
//                        NSLog(@"Failed to create a new event.");
//                    }
//                } //else NSLog(@"! Parse event is not unique");
//            }
//        }];

    } else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"getStartedFlag"] &&
                       [[NSUserDefaults standardUserDefaults] objectForKey:@"adminID"] != NULL)
    {
        NSLog(@"- viewDidLoad, getstarted flag ok, adminID not null");
        [self runNormalModeUI];
    }
}
- (void) setupUI
{
    // Seting up the UI
    NSLog(@"Setup UI");
    [self setupMapView];
    [self setupRequestScrollView];
    [self setupEventsTableView];
    
    [self setupToolBarIcons];
    [self setupNavigationBarImage];
}
- (void) runNormalModeUI {
    NSLog(@"Normal mode");
    
    // Determine App Frame
    self.appFrameProperties = [[NSArray alloc] initWithObjects:
                               [NSValue valueWithCGRect:[[UIScreen mainScreen] applicationFrame]],
                               [NSValue valueWithCGRect:self.navigationController.navigationBar.frame],
                               [NSValue valueWithCGRect:self.navigationController.toolbar.frame], nil];
    
    self.friendsLocationArray = [[NSMutableArray alloc] init]; // friends location cache
    self.pendingRqstsArray    = [[NSMutableArray alloc] init]; // Init pending requests holding array
    
    // Show progress indicator to tell user to wait a bit
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.loadingView setColor:UIColorFromRGB(0xf47d44)];
    [self.view addSubview:self.loadingView];
    [self.loadingView setCenter:CGPointMake(self.view.center.x, self.view.bounds.size.height*0.2)];
    [self.loadingView startAnimating];
    
//    // Seting up the UI
//    [self setupToolBarIcons];
//    [self setupNavigationBarImage];
//    [self setupMapView];
//    [self setupRequestScrollView];
//    [self setupEventsTableView];
    [self setupUI];
    
    // Hide the Options Menu when navigating to Options, otherwise show
    for (id subview in [self.navigationController.toolbar subviews]){
        if ( [subview isKindOfClass:[FriensoOptionsButton class]] )
        {
            if ([subview isHidden])
                [subview setHidden:NO];
        }
    }
    
    [self.locationManager startUpdatingLocation];
    [self setInitialLocation:self.locationManager.location];
    self.mapView.region = MKCoordinateRegionMake(self.location.coordinate, MKCoordinateSpanMake(0.05f, 0.05f));
    if([self.loadingView isAnimating])
        [self.loadingView stopAnimating];
    
    /******** 16Jun14:SA  Show Settings Menu when navigating to Options, otherwise show
    for (id subview in [self.navigationController.toolbar subviews]){
        if ( [subview isKindOfClass:[FriensoOptionsButton class]] )
        {
            if ([subview isHidden])
                [subview setHidden:NO];
        }
    }
    
    [self.locationManager startUpdatingLocation];
    [self setInitialLocation:self.locationManager.location];
    self.mapView.region = MKCoordinateRegionMake(self.location.coordinate, MKCoordinateSpanMake(0.05f, 0.05f));
    if([self.loadingView isAnimating])
        [self.loadingView stopAnimating];
    *******/
    
    
    //  cache resources from parse // The className to query on
    PFQuery *query = [PFQuery queryWithClassName:@"Resources"];
    [query orderByDescending:@"createdAt"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!object) {
            NSLog(@"The getFirstObject request failed.");
        } else {
            // The find succeeded.
            //NSLog(@"Successfully retrieved the object.");
            //NSLog(@"%@", object.objectId);
            
            
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
                        NSLog(@"Successfully cached the resource");
                    } else
                        NSLog(@"Failed to save the context. Error = %@", savingError);
                    // update the Parse record:
                    [object setObject:[NSNumber numberWithBool:YES]
                               forKey:@"wasCached"];
                    [object saveInBackground];
                    
                } else {
                    NSLog(@"Failed to create a new event.");
                }
            } //else NSLog(@"! Parse event is not unique");
        }
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) loginCurrentUserToCloudStore {
    // Check if self is currentUser (Parse)
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        NSLog(@"Successful login to Parse:%@",currentUser.email);
        [self setupUI];
    } else {
        //NSLog(@"no current user");
        NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"adminID"];
        NSString *userPass = [[NSUserDefaults standardUserDefaults] objectForKey:@"adminPass"];
        [PFUser logInWithUsernameInBackground:userName password:userPass
                                        block:^(PFUser *user, NSError *error) {
                                            if (user) {
                                                NSLog(@"[ Parse successful login ]");
                                                [self setupUI];
                                            } else
                                                NSLog(@"- Cloud login failed -");
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
            NSLog(@"Failed to save the context. Error = %@", savingError);
        
    } else {
        NSLog(@"Failed to create a new event.");
    }

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
        NSLog(@"Handle the error: %@", error);
    } else {
        for (NSManagedObject *object in fetchedObjects) {
            
            NSLog(@"%@", object);
            
        }
    }
}
-(BOOL) amiWatchingUserEvent:(NSString *)userEventObjId
{
    //NSLog(@"%@", userEventObjId);
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
           NSLog(@"     %@,%@",[mObject valueForKey:@"eventTitle"],[mObject valueForKey:@"eventSubtitle"]);
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
            NSLog(@"Successfully saved the context");
        } else { NSLog(@"Failed to save the context. Error = %@", savingError); }
    } else {
        NSLog(@"Failed to create a new event.");
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
            NSLog(@"Successfully saved the context");
        } else { NSLog(@"Failed to save the context. Error = %@", savingError); }
    } else {
        NSLog(@"Failed to create a new event.");
    }
}

- (void) actionAddFriensoEvent:(NSString *) message {
    NSLog(@"[ actionAddFriensoEvent ]");
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
            NSLog(@"Successfully saved the context");
        } else { NSLog(@"Failed to save the context. Error = %@", savingError); }
    } else {
        NSLog(@"Failed to create a new event.");
    }
    
}
-(void) syncCoreFriendsLocation {
    NSLog(@"--- syncCoreFriendsLocation  [ Sync friends' location to CoreData ]");
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
//    NSLog(@"size-width: %f", attrStr.size.width);
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
    NSLog(@"viewFoAnnotation");
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
    //NSLog(@"accessory button tapped for annotation %@", view.annotation);
    //NSLog(@"%@", [view.annotation description]);
//    NSLog(@"%@", [view.annotation title]);
//    NSLog(@"%@", [view.annotation subtitle]);
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
        [self configureOverlay];                  // the method also checks for pending requests
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
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            
            NSNumber *lat = [NSNumber numberWithDouble:geoPoint.latitude];
            NSNumber *lon = [NSNumber numberWithDouble:geoPoint.longitude];
            NSDictionary *userLocation=@{@"lat":lat,@"long":lon};
            
            [[NSUserDefaults standardUserDefaults] setObject:userLocation forKey:@"userLocation"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
            [[PFUser currentUser] saveInBackground];
        }
    }];
}

- (void)configureOverlay {
/* configureOverlay
 * - check if I have an active Event
 * - check if others have active events
 *
 ** */
    
    NSLog(@"configureOverlay method");
    
    // Check for friends with active alerts
    PFQuery *query = [PFQuery queryWithClassName:@"UserEvent"];
    [query whereKey:@"eventActive" equalTo:[NSNumber numberWithBool:YES]];
    [query includeKey:@"friensoUser"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"------ Checking for Events ...");
        if (!error) {
            
            for (PFObject *userEvent in objects){
                PFUser *friensoUser    = [userEvent valueForKey:@"friensoUser"];
                if ([friensoUser.username isEqualToString:[PFUser currentUser].username] &&
                    [[userEvent objectForKey:@"eventType"] isEqualToString:@"watch"]) {
                    // check if self has an active Event going
                    [trackMeOnOff setOn:YES animated:YES];
                } else if ([friensoUser.username isEqualToString:[PFUser currentUser].username] &&
                           [[userEvent objectForKey:@"eventType"] isEqualToString:@"helpNow"]) {
                    [self setupHelpMeNowSwitch];
                    [self updateLocations]; // puts core circle on mapview
                    
                } else if ([self inYourCoreUserWithPhNumber:[friensoUser valueForKey:@"phoneNumber"]] )
                {
                    // Check if this user is in your core or watchCircle
                    // friensoUser is in my network, am I tracking him/her?
                    NSLog(@"Friend: %@ w/active event of type: %@, %@, %@",friensoUser.username,
                          [userEvent valueForKey:@"eventType"],userEvent.objectId, [userEvent objectForKey:@"eventActive"]);
                    
                    //NSLog(@"am I watching him/her?: %d", [self ])
                    //[[[CloudUsrEvnts alloc] init] isUserInMy2WatchList:friensoUser];
                     
                     if ([self amiWatchingUserEvent:userEvent.objectId])
                     {
                         //NSLog(@"!!! YES");
                         [self.watchingCoFrArray addObject:friensoUser];
                     }else
                     {
                         //NSLog(@"!!! NO");
                         /*NSDictionary *dic =[[NSDictionary alloc] initWithObjects:@[friensoUser, forKeys:<#(NSArray *)#>]*/
                         [self.pendingRqstsArray addObject:userEvent];
                     }
                }

                
            }

            [self addPendingRequest:self.pendingRqstsArray];
//            [self.scrollView setPendingRequests:self.pendingRqstsArray];
            //NSLog(@"pendingRqstsArray: %@", self.pendingRqstsArray);
            [self updateMapViewWithUserBubbles: self.watchingCoFrArray];
        } else
            NSLog(@"parse error: %@", error.localizedDescription);
    }];
    

    
    
    //check for awaiting core friend requests
    //Added here so that access to pendingRqstsArray is sequential and we dont need synchronization
    // drawback: Slow. We can do this in parallel with synchronization
    PFQuery * pfquery = [PFQuery queryWithClassName:@"CoreFriendRequest"];
    [pfquery whereKey:@"recipient" equalTo:[PFUser currentUser]];
    [pfquery includeKey:@"sender"];
    [pfquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"------ Checking CoreFriendRequest ...");
        if(!error) {
            NSInteger i = [self.pendingRqstsArray count]; // get the next insert position
            //NSLog(@"CoreFriend Request: recipient, req ObjId, status, awaitingResponseFrom");
            for (PFObject *object in objects) {
                //PFUser * sender = [object objectForKey:@"sender"];
                //NSLog(@"%@ : %@ : %@ : %@",sender.objectId, object.objectId, [object objectForKey:@"status"], sender.email);
                
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

//            [self.scrollView setPendingRequests:self.pendingRqstsArray];
            [self addPendingRequest:self.pendingRqstsArray];
        } else {
            // Did not find any UserStats for the current user
            NSLog(@"Error: %@", error);
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
    //NSLog(@"...friendLocInteraction");
//    NSLog(@"[tag:%ld], %@", [sender tag],self.friendsLocationArray);// objectAtIndex:sender.tag]);
//    NSLog(@"watchingCoFrArray:%ld", [self.watchingCoFrArray count]);
//    NSLog(@"%@", self.watchingCoFrArray);
    
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
    NSLog(@"****** UPDATELOCATIONS");
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
            //NSLog(@"    %@ | %@ | %@", [mObject valueForKey:@"coreFirstName"], [mObject valueForKey:@"corePhone"], [mObject valueForKey:@"coreLocation"]);
            PFQuery *userQuery = [PFUser query];
            NSString *longPhoneNumber = [self stripStringOfUnwantedChars:[mObject valueForKey:@"corePhone"]];
            NSString *basePhoneNumber = [longPhoneNumber substringFromIndex:(longPhoneNumber.length-10)];
            
            [userQuery whereKey:@"phoneNumber" equalTo:basePhoneNumber];
            [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    PFUser * pfuser = [objects firstObject];
                    if(pfuser != nil) {
                        /* NSLog(@"user %@", [pfuser username]);
                        NSLog(@"phone %@", [pfuser objectForKey:@"phoneNumber"]);
                        NSLog(@"location %@", [pfuser objectForKey:@"currentLocation"]);
                        */
                        //NSLog(@"%d: %@",j, basePhoneNumber);
                        [self addCoreFriendLocationToMap:pfuser withIndex:j];
                    }
                } else {
                    NSLog(@"%@", error);
                }
            }];
            j++;
            //NSLog(@"%@",[self stripStringOfUnwantedChars:[mObject valueForKey:@"corePhone"]]);
            
        }
        // Animate friends overlays
//        NSInteger k = 0;
        for (id subview in [self.mapView subviews]){
            if ( [subview isKindOfClass:[UILabel class]])
            {
//                [UIView animateWithDuration:0.5 animations:^{
//                    [(UILabel*)subview].frame.center = CGPointMake(self.view.x, <#CGFloat y#>)
                //NSLog(@"Label");
            }
            
        }
    }
    
//    NSLog(@"subviews: %ld", [[self.mapView subviews] count]);

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
             //NSLog(@"%@, %@", (NSString *)[object valueForKey:@"email"], (PFGeoPoint *)[object valueForKey:@"currentLocation"]);
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
             NSLog(@"!Error: %@ %@", error, [error userInfo]); // Log details of the failure
     }];
}
-(void) lastKnownLocationForFriend:(NSString *)phoneNumber
{
    PFQuery *query = [PFQuery queryWithClassName:@"UserConnection"];
    //NSString *pNumber = [coFrDic objectForKey:keys[1]];
    NSRange substrRange = NSMakeRange(phoneNumber.length-10, 10);
    [query whereKey:@"userNumber" containsString:[phoneNumber substringWithRange:substrRange]];
    //NSLog(@"%@",[phoneNumber substringWithRange:substrRange]);
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (!error) { // The find succeeded.
             //NSLog(@"%@", objects);
             for (PFObject *object in objects) { // Do something w/ found objects
                 //NSLog(@"%@", object);
                 //NSLog(@"%@", [[object valueForKey:@"user"] objectId]);
                 [self fetchCurrentLocationForUser:[[object valueForKey:@"user"] objectId]];
             }
         } else {
             // Log details of the failure
             NSLog(@"!!Error: %@ %@", error, [error userInfo]);
         }
     }];
}

#pragma mark - MFMessageComposeViewController Delegate method
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result) {
        case MessageComposeResultSent: NSLog(@"SENT"); [self dismissViewControllerAnimated:YES completion:nil]; break;
        case MessageComposeResultFailed: NSLog(@"FAILED"); [self dismissViewControllerAnimated:YES completion:nil]; break;
        case MessageComposeResultCancelled: NSLog(@"CANCELLED"); [self dismissViewControllerAnimated:YES completion:nil]; break;
    }
}
#pragma mark - AlertView Delegate
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    return YES;
}
-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    //NSLog(@"[ will dismiss ]");
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    //NSLog(@"[ did dismiss ]");
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
                //NSLog(@"Accept: 1:%ld", buttonIndex);
                [self logAndNotifyCoreFriendsToWatchMe];
                break;
            default:
                break;
        }
    } else if (tag_no >= 100) {
        NSLog(@"CONTACT FRIEND");
        switch (buttonIndex) {
            case 0: // dismiss, cancel, or okay
                NSLog(@"cancel");
                break;
            case 1: // accept
                NSLog(@"Dial");
                [self contactByDialingFriendWithEmail:title];
                break;
            case 2: // SMS
                NSLog(@"SMS");
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
        
        NSLog(@"%@, %@, %@",friensoUser.username, requestType, userEventObject.objectId);
        
        if([requestType isEqualToString:coreFriendRequest])
        {
            
            NSString * response;
            
            if (buttonIndex == 1) // accept
            {
                response = @"accept";
                NSLog(@" corefriend request accepted");
            } else if (buttonIndex == 2) { //reject
                response = @"reject";
                NSLog(@" corefriend request rejected");
            } else { //dismiss
                NSLog(@"dismissed alertview");
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
                //NSLog(@"number of subviews: %ld", (long)[self.scrollView subviews].count);
                // Remove pending request bubble from pendingDrawer
                for (id subview in [self.scrollView subviews]){
                    
                    if ( [subview isKindOfClass:[PendingRequestButton class]] ) {
                        NSLog(@"self.pendingRqstsArray: %ld",(long)self.pendingRqstsArray.count);
                        if (tag_no ==  [(PendingRequestButton *)subview tag] &&
                            (self.pendingRqstsArray.count > 0))
                        {
                            //NSLog(@"[0]:tag=%ld, tag_no: %d", (long)[(UIButton *)subview tag], (int) tag_no );
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
                [self updateMapViewWithUserBubbles: self.watchingCoFrArray];
            } else if (buttonIndex == 2) // reject
            {
                NSLog(@"'request' rejected ");
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
                NSLog(@"dismissed alertview");
            }
        } // ends the if/else for the requestType
    }
}
-(void) isUserInMy2WatchList:(PFUser*)friensoUser{
    
}

#pragma mark - Helper Methods
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

