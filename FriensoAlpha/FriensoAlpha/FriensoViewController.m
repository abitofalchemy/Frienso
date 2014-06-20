//
//  FriensoViewController.m
//  FriensoAlpha
//
//  Created by Sal Aguinaga on 2/26/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "FriensoViewController.h"
#import "FriensoOptionsButton.h"
#import "FriensoCircleButton.h"
#import "FriensoPersonalEvent.h"
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

#define MAPVIEW_DEFAULT_BOUNDS  CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height * 0.5)
#define ARC4RANDOM_MAX          0x100000000
#define UIColorFromRGB(rgbValue)    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define CELL_CONTENT_MARGIN     10.0f

static NSString *eventCell = @"eventCell";
static NSString *trackRequest = @"trackRequest";
static NSString *coreFriendRequest = @"coreFriendRequest";

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
@property (nonatomic,strong) CLLocation     *location;
@property (nonatomic,strong) UITableView    *tableView;
@property (nonatomic,strong) UIButton       *selectedBubbleBtn;
@property (nonatomic,strong) UIButton       *fullScreenBtn;
@property (nonatomic,strong) UISwitch       *trackMeOnOff;
@property (nonatomic,strong) UILabel        *drawerLabel;
@property (nonatomic)        CGFloat scrollViewY;
@property (nonatomic)        CGRect normTableViewRect;

-(void)actionPanicEvent:(UIButton *)theButton;
-(void)viewMenuOptions: (UIButton *)theButton;
-(void)viewCoreCircle:  (UIButton *)theButton;
-(void)makeFriensoEvent:(UIButton *)theButton;

@end

@implementation FriensoViewController
@synthesize locationManager  = _locationManager;
@synthesize trackMeOnOff     = _trackMeOnOff;

/** useful calls:
 ** CGRect fullScreenRect=[[UIScreen mainScreen] applicationFrame];
 ** **/


-(void)actionPanicEvent:(UIButton *)theButton {
    [self animateThisButton:theButton];
    [theButton.layer setBorderColor:[UIColor redColor].CGColor];
    [self performSegueWithIdentifier:@"panicEvent" sender:self];
}
-(void)makeFriensoEvent:(UIButton *)theButton {
    [self animateThisButton:theButton];
    [self performSegueWithIdentifier:@"createEvent" sender:self];
}

-(void)viewMenuOptions:(UIButton *)theButton {
    [self animateThisButton:theButton];
    [self performSegueWithIdentifier:@"showMenuOptions" sender:self];
    [theButton.layer setBorderColor:[UIColor grayColor].CGColor];

}

-(void)viewCoreCircle:(UIButton *)theButton {
    [self animateThisButton:theButton];
    [self performSegueWithIdentifier:@"showMyCircle" sender:self];
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
    if([event.eventCategory isEqualToString:@"general"])
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
    } else if ([event.eventCategory isEqualToString:@"general"]) {
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
    
    if (scrollView.contentOffset.y == 0 && (self.tableView.frame.size.height != fullScreenRect.size.height))
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
            [tvHeaderView setFrame:CGRectMake(0, 0, self.view.bounds.size.width,self.tableView.frame.origin.y)];
            [tvHeaderView setBackgroundColor:[UIColor blackColor]];
            [tvHeaderView.titleLabel setTextAlignment:NSTextAlignmentRight];
            [tvHeaderView setTitle:@"▽ Dismiss" forState:UIControlStateNormal];
            [tvHeaderView addTarget:self action:@selector(closeFullscreenTableViewAction:)
                   forControlEvents:UIControlEventTouchUpInside];//tvFSCloseAction) withSender:self];
            [self.view addSubview:tvHeaderView];
            }];
        
        
        
    }
//    {
//        
//        CGFloat yOffset = self.view.frame.size.height*0.15;
//        CGFloat y_tableViewOffset = yOffset - _drawerLabel.frame.size.height*0.9;
//        
//        if (self.scrollView.frame.size.height> self.drawerLabel.frame.size.height*1.5)
//        {
//            [UIView animateWithDuration:0.5 animations:^{
//                CGRect closeDrawerRect = CGRectMake(0, self.scrollView.frame.origin.y, self.view.bounds.size.width,_drawerLabel.frame.size.height*0.9);
//                [self.scrollView setFrame:closeDrawerRect];
//                self.scrollView.contentSize = self.scrollView.frame.size;
//                
//                [_drawerLabel setTextColor:[UIColor whiteColor]];
//                [self.tableView setCenter:CGPointMake(self.tableView.center.x, self.tableView.center.y - y_tableViewOffset)];// remove tableview yOffset
//            }];
//        } else { // Open Drawer
//            [UIView animateWithDuration:0.5 animations:^{
//                CGRect openDrawerRect = CGRectMake(0, self.scrollView.frame.origin.y, self.view.frame.size.width,
//                                                   yOffset);
//                [self.tableView setCenter:CGPointMake(self.tableView.center.x, self.tableView.center.y + y_tableViewOffset)];
//                [self.scrollView setFrame:openDrawerRect];
//                self.scrollView.contentSize = self.scrollView.frame.size;
//                [_drawerLabel setTextColor:[UIColor darkGrayColor]];
//            }];
//        }
//    }
}

#pragma mark - NSFetchResultsController delegate methods
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

#pragma mark - Local Actions
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
    //PFUser *friend =  [self.pendingRqstsArray objectAtIndex:btn.tag];

    if([type isEqualToString:coreFriendRequest]) { //if core friend request
        //TODO: we do not need to add the btn.tag here.
        //may be we can extend UIAlertView and add a variable for the index.
        //NSLog(@"btn tag = %d",btn.tag);
        [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Core Friend Request:%2ld",(long)btn.tag]
                                    message:[NSString stringWithFormat:@"from %@",friensoUser.username]
                                   delegate:self
                          cancelButtonTitle:@"Dismiss"
                          otherButtonTitles:@"Accept",@"Reject", nil] show];
    } else { // for watch or anything else.
        [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Pending Request:%2ld",(long)btn.tag]
                                    message:[NSString stringWithFormat:@"from %@",friensoUser.username]
                                   delegate:self
                          cancelButtonTitle:@"Dismiss"
                          otherButtonTitles:@"Accept",@"Reject", nil] show];
    }
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
    //NSLog(@"Toggle FS Mode");
    if (self.mapView.frame.size.height < self.view.bounds.size.height){
        [self.mapView setFrame:self.view.bounds];
        [self.fullScreenBtn setTitle:@"┓"/*@""*/ forState:UIControlStateNormal];
        [self.fullScreenBtn sizeToFit];
        [self.fullScreenBtn.titleLabel setTextColor:[UIColor blackColor]];
        [self.fullScreenBtn setCenter:CGPointMake(self.fullScreenBtn.center.x,40.0)];
        [self.tableView setHidden:YES];
        [self openCloseDrawer];
        [self.scrollView setCenter:CGPointMake(self.view.center.x, self.navigationController.toolbar.frame.origin.y - self.scrollView.frame.size.height*1.5)];
    } else {
        [self.mapView setFrame:MAPVIEW_DEFAULT_BOUNDS];
        [self.fullScreenBtn setTitle:@"┛"/*@""*/ forState:UIControlStateNormal];
        [self.fullScreenBtn sizeToFit];
        [self.fullScreenBtn setCenter:CGPointMake(_fullScreenBtn.center.x,
                                                  self.mapView.frame.size.height -_fullScreenBtn.frame.size.height/2 * 1.2) ];
        [self.fullScreenBtn.titleLabel setTextColor:[UIColor blackColor]];
        [self.tableView setHidden:NO];
        [self openCloseDrawer];
        CGRect fullScreenRect=[[UIScreen mainScreen] applicationFrame];
        [self.scrollView setCenter:CGPointMake(fullScreenRect.size.width/2.0,
                                               self.scrollViewY)];
    }
}

-(void) addPendingRequest:(PFUser *)parseFriend withTag:(NSInteger)tagNbr reqtype:(NSString *) type{

    if ([type isEqualToString:coreFriendRequest]) {
        [self addPndngRqstButton:[UIColor redColor] withFriensoUser:parseFriend withTag:tagNbr];
        //NSLog(@"Tag number %d ",tagNbr);
    } else {
        [self addPndngRqstButton:[UIColor whiteColor] withFriensoUser:parseFriend withTag:tagNbr];
        
        PFGeoPoint *geoNDIN = [PFGeoPoint geoPointWithLatitude:41.700278
                                                      longitude:-86.238611];// notre dame, in
        [self.friendsLocationArray insertObject:([parseFriend valueForKey:@"currentLocation"] == NULL)  ? geoNDIN  : [parseFriend valueForKey:@"currentLocation"]  atIndex:tagNbr];
    }
}

- (void) addPndngRqstButton: (UIColor *) fontColor  withFriensoUser:(PFUser *)parseFriend withTag:(NSInteger)tagNbr{
    // addPendingRequest  adds a pending request to drawer+slider that user can interact w/ Pfuser
    UIButton *pndngRqstBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
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
    [pndngRqstBtn setCenter:CGPointMake(btnCenterX,self.scrollView.frame.size.height*1.6)];
}


-(void) addUserBubbleToMap:(PFUser *)parseUser withTag:(NSInteger)tagNbr {
    
//    NSLog(@"addUserBubbleToMap: %ld",tagNbr);
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
    
    // Allows access to location info to userBubble
    PFGeoPoint *geoNDIN = [PFGeoPoint geoPointWithLatitude:41.700278
                                                  longitude:-86.238611];// notre dame, in
    [self.friendsLocationArray insertObject:([parseUser valueForKey:@"currentLocation"] == NULL)  ? geoNDIN : [parseUser valueForKey:@"currentLocation"]  atIndex:tagNbr];
    
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
        
        
        /**************PUSH NOTIFICATIONS: WATCH ME NOW!!!! *****************/
        
        //Query Parse to know who your "accepted" core friends are and send them each a notification
       
        PFQuery *query = [PFQuery queryWithClassName:@"CoreFriendRequest"];
        [query whereKey:@"status" equalTo:@"accept"];
        [query whereKey:@"sender" equalTo:[PFUser currentUser]];
        [query includeKey:@"recipient"];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %d scores.", objects.count);
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
        
        // Watch Me event tracking
        CloudUsrEvnts *watchMeEvent = [[CloudUsrEvnts alloc] initWithAlertType:@"watchMe"
                                                                          eventStartDateTime:[NSDate date] ];
        [watchMeEvent setPersonalEvent];
        [watchMeEvent sendToCloud];
    } else {
        NSLog(@"Stop the watchMe event");
        [[[UIAlertView alloc] initWithTitle:@"WatchMe"
                                    message:@"Your location sharing will stop"
                                   delegate:self
                          cancelButtonTitle:@"Okay"
                          otherButtonTitles:nil] show];
        CloudUsrEvnts *watchMeEvent = [[CloudUsrEvnts alloc] initWithAlertType:@"watchMe"
                                                                          eventStartDateTime:[NSDate date] ];
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
            NSLog(@"Successfully retrieved %ld scores.", objects.count);
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

    self.mapView.region = MKCoordinateRegionMake(self.location.coordinate,MKCoordinateSpanMake(0.05f,0.05f));
    self.mapView.layer.borderWidth = 2.0f;
    self.mapView.layer.borderColor = [UIColor whiteColor].CGColor;//UIColorFromRGB(0x9B90C8).CGColor;
    [self.view addSubview:self.mapView];
    

    
    // Adding fullscreen mode button to the mapview
    self.fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fullScreenBtn addTarget:self action:@selector(mapViewFSToggle:)
                 forControlEvents:UIControlEventTouchUpInside];
    [self.fullScreenBtn setTitle:@"┛"/*@""*/ forState:UIControlStateNormal];
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
    [self.fullScreenBtn setCenter:CGPointMake(self.mapView.frame.size.width - _fullScreenBtn.center.x * 2.0,
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
    FriensoCircleButton *coreCircleBtn = [[FriensoCircleButton alloc]
                                          initWithFrame:CGRectMake(0, 0, 27, 27)];
    coreCircleBtn.layer.cornerRadius = 4.0;
    coreCircleBtn.layer.borderWidth  =  1.0;
    coreCircleBtn.layer.borderColor  = UIColorFromRGB(0x006bb6).CGColor;
    
    if (![coreCircleBtn isEnabled])
        [coreCircleBtn setEnabled:YES];
    [coreCircleBtn addTarget:self action:@selector(viewCoreCircle:)
            forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barLeftButton=[[UIBarButtonItem alloc] init];
    [barLeftButton setCustomView:coreCircleBtn];
    [coreCircleBtn setCenter:CGPointMake(44.0f,22)];
    
    // Right tool bar btn
    FriensoOptionsButton *button = [[FriensoOptionsButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
    button.layer.cornerRadius = 4.0;
    button.layer.borderWidth =  1.0;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    [button addTarget:self action:@selector(viewMenuOptions:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setCenter:CGPointMake(self.navigationController.toolbar.frame.size.width - button.center.x*2.0, 22)];
        //self.navigationItem.rightBarButtonItem=barButton;
    
    /**
    FriensoPersonalEvent *calEventBtn = [[FriensoPersonalEvent alloc]
                                            initWithFrame:CGRectMake(0, 0, 27, 27)];
    calEventBtn.layer.cornerRadius = 4.0f;
    calEventBtn.layer.borderWidth = 1.0f;
    calEventBtn.layer.borderColor = UIColorFromRGB(0x006bb6).CGColor;
    [calEventBtn addTarget:self action:@selector(makeFriensoEvent:)
          forControlEvents:UIControlEventTouchUpInside];
    [calEventBtn setCenter:CGPointMake(self.navigationController.toolbar.bounds.size.width - 44.0f,22)];
    [calEventBtn setTitleShadowColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    **/
    
    
    
    
    // center toolbar btn
    UIButton *panicButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
    [panicButton addTarget:self action:@selector(actionPanicEvent:)
          forControlEvents:UIControlEventTouchUpInside];
    [panicButton setTitle:@"\u26A0" forState:(UIControlStateNormal)];
    panicButton.layer.cornerRadius = 4.0f;
    panicButton.layer.borderWidth  = 1.0f;
    panicButton.layer.borderColor  = UIColorFromRGB(0x006bb6).CGColor;;
    panicButton.titleLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:107.0/255.0 blue:182.0/255.0 alpha:1.0];
    [panicButton setCenter:CGPointMake(self.navigationController.toolbar.center.x, 22)];
    
    [self.navigationController.toolbar addSubview:coreCircleBtn]; // left
    [self.navigationController.toolbar addSubview:button]; // right
    [self.navigationController.toolbar addSubview:panicButton]; // center

}
-(void) setupNavigationBarImage{
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:16.0], NSFontAttributeName,nil]];
    self.navigationItem.title = @"FRIENSO";
    
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
    
    // Present Login these properties have not been set
    NSString       *adminKey    = [[NSUserDefaults standardUserDefaults] objectForKey:@"adminID"];
    if ([adminKey isEqualToString:@""] || adminKey == NULL || adminKey == nil){
        //[self performSegueWithIdentifier:@"loginView" sender:self];
        [self performSelector:@selector(segueToLoginVC) withObject:self afterDelay:1];
        NSLog(@"{Presenting loginView}");
    } else {
        
        // Check if self is currentUser (Parse)
        PFUser *currentUser = [PFUser currentUser];
        if (currentUser) {
            NSLog(@"Successful login to Parse:%@",currentUser.email);
        } else
            NSLog(@"no current user");
        
        BOOL newUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"newUserFlag"];
        if (newUser == YES){
            [self performSegueWithIdentifier:@"newCoreCircle" sender:self];
            NSLog(@"{Presenting newCoreCircle}");
        } else {
        
            // Determine App Frame
            self.appFrameProperties = [[NSArray alloc] initWithObjects:
                                       [NSValue valueWithCGRect:[[UIScreen mainScreen] applicationFrame]],
                                       [NSValue valueWithCGRect:self.navigationController.navigationBar.frame],
                                       [NSValue valueWithCGRect:self.navigationController.toolbar.frame], nil];
            
            self.friendsLocationArray = [[NSMutableArray alloc] init]; // friends location cache
            self.pendingRqstsArray    = [[NSMutableArray alloc] init]; // Initialize pending requests holding array
            
            // Show progress indicator to tell user to wait a bit
            self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [self.loadingView setColor:UIColorFromRGB(0xf47d44)];
            [self.view addSubview:self.loadingView];
            [self.loadingView setCenter:CGPointMake(self.view.center.x, self.view.bounds.size.height*0.2)];
            [self.loadingView startAnimating];
            
            // Seting up the UI
            //[self setupToolBarIcons];
            //[self setupNavigationBarImage];
            [self setupMapView];
            [self setupRequestScrollView];
            [self setupEventsTableView];
        }
    }
    
    [self setupToolBarIcons];
    [self setupNavigationBarImage];
    
    
}
// viewDidUnload is deprecated

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    //NSLog(@"viewWillAppear");
    
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    NSNumber *installationCount = [[NSUserDefaults standardUserDefaults] valueForKey:@"afterFirstInstall"];
    
    if ([installationCount isEqualToNumber:[NSNumber numberWithInteger:0]] || installationCount == NULL){
        NSLog(@"First install");
        
        // At first install, cache univesity/college emergency contacts
        [[[CloudEntityContacts alloc] initWithCampusDomain:@"nd.edu"] fetchEmergencyContacts:@"inst,contact"];
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:1] forKey:@"afterFirstInstall"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if ([installationCount isEqualToNumber:[NSNumber numberWithInteger:1]])
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:2] forKey:@"afterFirstInstall"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        BOOL newUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"newUserFlag"];
        if (newUser == YES){
            [self performSegueWithIdentifier:@"newCoreCircle" sender:self];
            NSLog(@"{Presenting newCoreCircle}");
        }
        
        //**********
        // Check if self is currentUser (Parse)
        PFUser *currentUser = [PFUser currentUser];
        if (currentUser) {
            NSLog(@"Successful login to Parse:%@",currentUser.email);
        } else
            NSLog(@"no current user");
        
        // Cache your extended circle of Friends
        //[[[FRSyncFriendConnections alloc] init] syncUWatchToCoreFriends]; // Sync those uWatch
        
        
        // Determine App Frame
        self.appFrameProperties = [[NSArray alloc] initWithObjects:
                                   [NSValue valueWithCGRect:[[UIScreen mainScreen] applicationFrame]],
                                   [NSValue valueWithCGRect:self.navigationController.navigationBar.frame],
                                   [NSValue valueWithCGRect:self.navigationController.toolbar.frame], nil];
        
        self.friendsLocationArray = [[NSMutableArray alloc] init]; // friends location cache
        self.pendingRqstsArray    = [[NSMutableArray alloc] init]; // Initialize pending requests holding array
        
        // Show progress indicator to tell user to wait a bit
        self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.loadingView setColor:UIColorFromRGB(0xf47d44)];
        [self.view addSubview:self.loadingView];
        [self.loadingView setCenter:CGPointMake(self.view.center.x, self.view.bounds.size.height*0.2)];
        [self.loadingView startAnimating];
        
        // Seting up the UI
        [self setupToolBarIcons];
        [self setupNavigationBarImage];
        [self setupMapView];
        [self setupRequestScrollView];
        [self setupEventsTableView];
        //**********
        
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

    } else { // else we do nothing in this method; 16Jun14:SA
        // 16Jun14:SA  Show Settings Menu when navigating to Options, otherwise show
        for (id subview in [self.navigationController.toolbar subviews]){
            if ( [subview isKindOfClass:[FriensoOptionsButton class]] )
            {
                if ([subview isHidden])
                    [subview setHidden:NO];
            }
        }

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) segueToLoginVC {
    [self performSegueWithIdentifier:@"loginView" sender:self];
}
#pragma mark - CoreData helper methods
-(void) trackUserEventLocally:(PFUser *)friensoUser
{
    FriensoEvent *frEvent = [NSEntityDescription insertNewObjectForEntityForName:@"FriensoEvent"
                                                                    inManagedObjectContext:[self managedObjectContext]];
    
    if (frEvent != nil){
        frEvent.eventTitle     = [NSString stringWithFormat:@"You are watching: %@", friensoUser.username];
        frEvent.eventSubtitle  = @"watchMe";
        frEvent.eventLocation  = @"Location:";
        frEvent.eventContact   = friensoUser.username;
        frEvent.eventCreated   = [NSDate date];
        frEvent.eventModified  = [NSDate date];
        frEvent.eventPriority  = [NSNumber numberWithInteger:3];
        frEvent.eventObjId     = friensoUser.objectId;
        
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

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString *GeoPointAnnotationIdentifier = @"RedPinAnnotation";
    static NSString *GeoQueryAnnotationIdentifier = @"PurplePinAnnotation";
    
    if ([annotation isKindOfClass:[GeoQueryAnnotation class]]) {
        MKPinAnnotationView *annotationView =
        (MKPinAnnotationView *)[mapView
                                dequeueReusableAnnotationViewWithIdentifier:GeoQueryAnnotationIdentifier];
        
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc]
                              initWithAnnotation:annotation
                              reuseIdentifier:GeoQueryAnnotationIdentifier];
            annotationView.tag = PinAnnotationTypeTagGeoQuery;
            annotationView.canShowCallout = YES;
            annotationView.pinColor = MKPinAnnotationColorPurple;
            annotationView.animatesDrop = NO;
            annotationView.draggable = YES;
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
    NSLog(@"configureOverlay method");
    /** configureOverlay
     ** - check if I have an active Event
     ** - check if others have active events
     ** */
    
    // Check for friends with active alerts
    PFQuery *query = [PFQuery queryWithClassName:@"UserEvent"];
    [query whereKey:@"eventActive" equalTo:[NSNumber numberWithBool:YES]];
    [query includeKey:@"friensoUser"];
    query.limit = 10;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSInteger i = 0;  // counter for bubbles on the pending req drawer
            NSInteger k = 0;  // counter for bubbles on the mapview
            for (PFObject *eventUser in objects){
                PFUser *friensoUser    = [eventUser valueForKey:@"friensoUser"];
                
                if ([friensoUser.username isEqualToString:[PFUser currentUser].username])
                    [trackMeOnOff setOn:YES animated:YES]; // check if self has an active Event going
                else if ([self inYourCoreUserWithPhNumber:[friensoUser valueForKey:@"phoneNumber"]] )
                {   // Check if this user is in your core or watchCircle
                    // friensoUser is in my network, am I tracking him/her?
                    NSLog(@"Friend: %@ w/active event of type: %@",friensoUser.username,
                          [eventUser valueForKey:@"eventType"]);
                     /*
                    NSLog(@"am I watching him/her?: %d", [self ])
                    [[[CloudUsrEvnts alloc] init] isUserInMy2WatchList:friensoUser];
                    
                    if ([self queryCDFriensoEvents4ActiveWatchEvent:friensoUser])
                        NSLog(@"!!! YES");
                    else
                        NSLog(@"!!! NO");
                    */
                    if ([self queryCDFriensoEvents4ActiveWatchEvent:friensoUser]) {
                        NSLog(@"Watching: %@",friensoUser.username);    // Users I watch w/active event!!
                        [self addUserBubbleToMap:friensoUser            // Accepted to watch this user,
                                         withTag:k];                    // so load it on the mapview
                        k++;
                    } else {
                    
                        [self addPendingRequest:friensoUser withTag:i reqtype:trackRequest]; // Add user to drawer+slider
                        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                             friensoUser,                               @"pfUser",
                                             [eventUser valueForKey:@"eventType"], @"reqType",
                                             [NSNumber numberWithInteger:i],            @"btnTag", nil];
                        [self.pendingRqstsArray insertObject:dic atIndex:i]; // simulation
                        
                        //[self addUserBubbleToMap:friensoUser withTag:i];
                        i++;
                    }
                }
            }

            //NSLog(@"%d", [self.pendingRqstsArray count]);
            [self.scrollView setPendingRequests:self.pendingRqstsArray];

            //check for awaiting core friend requests
            //Added here so that access to pendingRqstsArray is sequential and we dont need synchronization
            // drawback: Slow. We can do this in parallel with synchronization

            PFQuery * pfquery = [PFQuery queryWithClassName:@"CoreFriendRequest"];
            [pfquery whereKey:@"recipient" equalTo:[PFUser currentUser]];
            [pfquery whereKey:@"awaitingResponseFrom" equalTo:@"recipient"];
            [pfquery whereKey:@"status" equalTo:@"send"];
            [pfquery includeKey:@"sender"];
            [pfquery findObjectsInBackgroundWithBlock:^(NSArray *objects,
                                                        NSError *error) {
                if(!error) {
                    NSInteger i = [self.pendingRqstsArray count]; // get the next insert position
                    for (PFObject *  object in objects) {
                        PFUser * sender = [object objectForKey:@"sender"];
                        NSLog(@"Corefriend request sender's email %@",sender.email);
                        [self addPendingRequest:sender withTag:i reqtype:coreFriendRequest]; // temp add to drawwer+slider
                        NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                 sender,   @"pfUser",
                                                 coreFriendRequest, @"reqType",
                                                 [NSNumber numberWithInteger:i],@"btnTag", nil];
                            [self.pendingRqstsArray insertObject:dic atIndex:i]; // simulation
                            i = i + 1;
                    }

                    [self.scrollView setPendingRequests:self.pendingRqstsArray];

                } else {
                    // Did not find any UserStats for the current user
                    NSLog(@"Error: %@", error);
                }
            }];
        } else {
            // Did not find any UserStats for the current user
            NSLog(@"Error: %@", error);
        }
    }];
    
   
    
}
-(void)friendLocInteraction:(UIButton *)sender
{
    /* friendLocInteraction:
    ** Is the action triggered when user touches the button overlay on the mapview.
    ** */
    NSLog(@"...friendLocInteraction");
    NSLog(@"[tag:%ld], %@", [sender tag],self.friendsLocationArray);// objectAtIndex:sender.tag]);
    //NSString *coordinateStr =[self.friendsLocationArray objectAtIndex:sender.tag];
    PFGeoPoint *coordinatesPoint = [self.friendsLocationArray objectAtIndex:sender.tag];
    
    //CGFloat geoLatitude = [[coordinateStr componentsSeparatedByString:@","][0] doubleValue];
    //CGFloat geoLongitude = [[coordinateStr componentsSeparatedByString:@","][1] doubleValue];

    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake([coordinatesPoint latitude], [coordinatesPoint longitude]),
                                                   MKCoordinateSpanMake(0.01, 0.01) )];
//    NSArray *array = @[sender.titleLabel.text,                               // Initials
//                       [coordinateStr componentsSeparatedByString:@","][0],  // latitude
//                       [coordinateStr componentsSeparatedByString:@","][1]]; // longitude
    NSArray *array = @[sender.titleLabel.text,                               // Initials
                        [NSString stringWithFormat:@"%f",[coordinatesPoint latitude]],  // latitude
                        [NSString stringWithFormat:@"%f",[coordinatesPoint longitude]]]; // longitude

    GeoCDPointAnnotation *geoCDPointAnn = [[GeoCDPointAnnotation alloc] initWithObject:array];
    [self.mapView addAnnotation:geoCDPointAnn];
    
#warning Insert an annotation using stored loc info fromCoreData, then update if network availability
    
    /** location for sender.tag
        **/

    //[self lastKnownLocationForFriend:[coFrDic objectForKey:keys[0]]];
    /*** NSDictionary *coFrDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"CoreFriendsContactInfoDicKey"];
    NSArray *keys = [coFrDic allKeys];
    
    
    switch (sender.tag) {
        case 0:
        {
            [self lastKnownLocationForFriend:[coFrDic objectForKey:keys[0]]];
            break;
        }
        case 1:
        {
            [self lastKnownLocationForFriend:[coFrDic objectForKey:keys[1]]];
            break;
        }
        case 2:
            [self lastKnownLocationForFriend:[coFrDic objectForKey:keys[2]]];
            break;
        default:
            break;
    }
    ** */
    
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
    /** this adds bubbles to the map for all Persons in your CoreFriends list (local core data store) **/
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init]; // Create the fetch request
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CoreFriends"
                                              inManagedObjectContext:[self managedObjectContext]];
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"coreType like 'Person' || coreType like 'OnWatch'"]];
    NSSortDescriptor *phoneSort =  [[NSSortDescriptor alloc] initWithKey:@"corePhone"
                                                                  ascending:YES];
        
    fetchRequest.sortDescriptors = @[phoneSort];
    
    NSError *error;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error.
    } else if ( [[self.mapView subviews] count] < [fetchedObjects count]){
        NSInteger i = 0;
        for (NSManagedObject *mObject in fetchedObjects) {
            
            
            UIButton *mLocBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
            UIImage *img =[[FRStringImage alloc] imageTextBubbleOfSize:mLocBtn.frame.size];
            [mLocBtn setBackgroundImage:img forState:UIControlStateNormal];
            NSString *bubbleLabel = ([mObject valueForKey:@"coreNickName"] == NULL) ? [mObject valueForKey:@"coreFirstName"] :  [mObject valueForKey:@"coreNickName"];
//            NSLog(@"coreLocation: %@, name: %@, objId:%@",[mObject valueForKey:@"coreLocation"], [[bubbleLabel substringToIndex:2] uppercaseString],
//                  [mObject valueForKey:@"coreObjId"]);
            if (bubbleLabel.length >1 )
            [mLocBtn setTitle:[[bubbleLabel substringToIndex:2] uppercaseString] forState:UIControlStateNormal];
            else
                [mLocBtn setTitle:[bubbleLabel uppercaseString] forState:UIControlStateNormal];
            [mLocBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [mLocBtn setTitleColor:UIColorFromRGB(0x8e44ad) forState:UIControlStateHighlighted];
            [mLocBtn setAlpha:0.8];
            [mLocBtn setTag:i];
            [mLocBtn addTarget:self action:@selector(friendLocInteraction:)
              forControlEvents:UIControlEventTouchUpInside];
            [self.mapView addSubview:mLocBtn];
            [mLocBtn setCenter:CGPointMake(mLocBtn.frame.size.width + mLocBtn.center.x + i*(mLocBtn.frame.size.width), self.mapView.frame.size.height - mLocBtn.center.y)];
            
                
            [self.friendsLocationArray insertObject:([mObject valueForKey:@"coreLocation"] == NULL)  ? @"0,0" : [mObject valueForKey:@"coreLocation"]  atIndex:i];
            i++;
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

#pragma mark
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
    if ( [title isEqualToString:@"WatchMe"]) {
        switch (buttonIndex) {
            case 0: // dismiss, cancel, or okay
                //NSLog(@"0:%ld", buttonIndex);
                [trackMeOnOff setOn:NO animated:YES]; // Nothing happens -- no action
                break;
            case 1: // accept
                //NSLog(@"Accept: 1:%ld", buttonIndex);
                [self logAndNotifyCoreFriendsToWatchMe];
                break;
            default:
                break;
        }
    } else {
        //read the index in the title to get the position in the array **** not a good design!!! ****
        NSString *tagNbr= [title substringFromIndex:(title.length -2)];
        int btnTagNbr   = (int)[tagNbr integerValue];
        NSDictionary *frUserDic = [self.pendingRqstsArray objectAtIndex:btnTagNbr]; // 10Jun14:SA
        NSString *requestType = [frUserDic objectForKey:@"reqType"];
        PFUser *friensoUser = [frUserDic objectForKey:@"pfUser"];                   // 10Jun14:SA
        
        
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
            [pfquery whereKey:@"sender" equalTo:friensoUser];
            [pfquery whereKey:@"recipient" equalTo:[PFUser currentUser]];
            [pfquery whereKey:@"awaitingResponseFrom" equalTo:@"recipient"];
            [pfquery whereKey:@"status" equalTo:@"send"];
            [pfquery findObjectsInBackgroundWithBlock:^(NSArray *objects,
                                                        NSError *error) {
                if(!error && ![objects isEqual:[NSNull null]]) {
                    //TODO: check if first element is not null
                    PFObject * pfobject =[objects firstObject];
                    if(pfobject != nil) {
                        pfobject[@"awaitingResponseFrom"] = @"sender";
                        pfobject[@"status"] = response;
                        [pfobject saveInBackground];
                        
                        //remove the button from the view
                        for (id subview in [self.scrollView subviews]){
                            if ( [subview isKindOfClass:[UIButton class]] ) {
                                if (btnTagNbr ==  [(UIButton *)subview tag])
                                {
                                    [subview removeFromSuperview];
                                    // Now update requests count
                                    [self.pendingRqstsArray removeObjectAtIndex:btnTagNbr];
                                    [self.scrollView updatePendingRequests:self.pendingRqstsArray];
                                }
                            }
                        }
                    }
                }
            }];
        } else { // request is of type either
            
            if (buttonIndex == 1) // accept
            {
                [self addUserBubbleToMap:friensoUser             /* accepted to watch this user */
                                 withTag:[tagNbr integerValue]];
                //[self setWatchingUserInCD:friensoUser]; // Watching Friend set
                for (id subview in [self.scrollView subviews]){
                    if ( [subview isKindOfClass:[UIButton class]] ) {
                        //NSLog(@"[0]:tag=%ld", (long)[(UIButton *)subview tag] );
                        if (btnTagNbr ==  [(UIButton *)subview tag])
                        {
                            [subview removeFromSuperview];
                            
                            // UserEvent maintain request status
                            //NSLog(@":%@",[frUserDic objectForKey:@"reqType"]);
                            CloudUsrEvnts *userEvent = [[CloudUsrEvnts alloc] init];
                            [userEvent trackRequestOfType:[frUserDic objectForKey:@"reqType"]
                                                  forUser:friensoUser
                                               withStatus:@"accepted"];
                            // Now update requests count
                            [self.pendingRqstsArray removeObjectAtIndex:[tagNbr integerValue]];
                            [self.scrollView updatePendingRequests:self.pendingRqstsArray];
                            // set FriensoEvent, make the watching your friend X sticky
                            //[[[WatchingCoreFriend alloc] init] trackUserEventLocally:friensoUser];
                            /****** migrate this code to its own class ******/
                            [self trackUserEventLocally:friensoUser];
                        }
                        
                    }   // ends for
                }       // ends if
            } else if (buttonIndex == 2) // reject
            {
                NSLog(@"'request' rejected ");
                // log the reject to the cloud
                // remove the request and update
                
                for (id subview in [self.scrollView subviews]){
                    if ( [subview isKindOfClass:[UIButton class]] ) {
                        if (btnTagNbr ==  [(UIButton *)subview tag])
                        {
                            [subview removeFromSuperview];
                            
                            // Cloud track request
                            [[[CloudUsrEvnts alloc] init] trackRequestOfType:[frUserDic objectForKey:@"reqType"]
                                                                     forUser:friensoUser  //[_pendingRqstsArray objectAtIndex:btnTagNbr]
                                                                  withStatus:@"rejected"];
                            // Now update requests count
                            [self.pendingRqstsArray removeObjectAtIndex:[tagNbr integerValue]];
                            [self.scrollView updatePendingRequests:self.pendingRqstsArray];
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
 **/
@end
