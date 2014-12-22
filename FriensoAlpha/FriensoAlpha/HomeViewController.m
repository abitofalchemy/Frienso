//
//  HomeViewController.m
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 8/16/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "HomeViewController.h"
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

#define MAPVIEW_DEFAULT_BOUNDS  CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height * 0.5)
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


@interface HomeViewController ()
{
    NSMutableArray *coreFriendsArray;
    UISwitch       *watchMeSwitch;
    UIGestureRecognizer *navGestures;
    UISwitch       *helpMeNowSwitch;
    CGRect         tblViewFrame;
}
@property (nonatomic,strong) UIButton *selectedBubbleBtn;
@property (nonatomic,strong) UIButton *fullScreenBtn;
@property (nonatomic,strong) UIButton *optionsButton;
@property (nonatomic,strong) UIButton *coreCircleBtn;
@property (nonatomic,strong) UIButton *txtChattingBtn;
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

@property (nonatomic,strong) ProfileSneakPeekView *profileView;
@property (nonatomic,strong) UISwitch       *watchMeSwitch;
@property (nonatomic,strong) UISwitch       *helpMeNowSwitch;
@property (nonatomic,strong) UILabel        *drawerLabel;
@property (nonatomic)        CGFloat scrollViewY;
@property (nonatomic)        CGRect normTableViewRect;
@property (nonatomic) const CGFloat mapViewHeight;


-(void)actionPanicEvent:(UIButton *)theButton;
-(void)viewMenuOptions: (UIButton *)theButton;
-(void)viewCoreCircle:  (UIButton *)theButton;
-(void)makeFriensoEvent:(UIButton *)theButton;
-(void)viewFriensoChatWindow:(UISwitch *)sender;

-(void)navigationCtrlrSingleTap;

@end

@implementation HomeViewController
@synthesize locationManager  = _locationManager;
@synthesize watchMeSwitch    = _watchMeSwitch;
@synthesize helpMeNowSwitch  = _helpMeNowSwitch;


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
    
    // Setup UI
    [self setupMapView];
    [self setupTopTableView];
    [self setupMapViewControls];
    [self setupNavigationBar];
    //[self setupHelpMeSwitch];
    [self setupOptionsNavigation];
    //[self setupTxtFriensoChat];
    [self setupWatchMeSwitch];
    

}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.navigationController setNavigationBarHidden:YES];
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UI Setup
-(void) setupTopTableView {
    self.tableView = [[UITableView alloc] init];
    [self.tableView setFrame:CGRectMake(0,0,APP_SCREEN_FRAME.size.width * 0.9,
                                        APP_SCREEN_FRAME.size.height*0.150)];
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    [self.view addSubview:self.tableView];
    [self.tableView setScrollEnabled:YES];
    [self.tableView setScrollsToTop:YES];
    self.tableView.layer.shadowColor   = [UIColor blueColor].CGColor;
    self.tableView.layer.shadowOffset  = CGSizeMake(0, 1.5f);
    self.tableView.layer.shadowOpacity = 1.0;
    self.tableView.layer.shadowRadius  = 4.0;
    [self.tableView setCenter:CGPointMake(APP_SCREEN_FRAME.size.width/2.0,
                                          self.view.bounds.size.height - self.tableView.frame.size.height/2.0f)];
    
    tblViewFrame = self.tableView.frame;
    
    // data for the top table
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]
                                    initWithEntityName:@"FriensoEvent"];
    
    NSSortDescriptor *createdSort = [[NSSortDescriptor alloc] initWithKey:@"eventCreated"
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
}
- (NSManagedObjectContext *) managedObjectContext{
    
    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
    
}
-(void) setupMapView {
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
    if(STORYBOARD_CONF_II)
        [self.mapView setFrame:CGRectMake(0,APP_SCREEN_FRAME.origin.y,APP_SCREEN_FRAME.size.width,APP_SCREEN_FRAME.size.height)];
    else
        [self.mapView setFrame:CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height*.5)];
    
    self.mapViewHeight = self.view.frame.size.height * 0.5;
    self.mapView.region = MKCoordinateRegionMake(self.location.coordinate,MKCoordinateSpanMake(0.05f,0.05f));
    self.mapView.layer.borderWidth = 2.0f;
    self.mapView.layer.borderColor = [UIColor whiteColor].CGColor;//UIColorFromRGB(0x9B90C8).CGColor;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    
    
    
    // Adding a refresh mapview btn
//    UIButton *refreshMavpViewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [refreshMavpViewBtn addTarget:self action:@selector(refreshMapViewAction:)
//                 forControlEvents:UIControlEventTouchUpInside];
//    [refreshMavpViewBtn setTitle:@"↺"/*@""*/ forState:UIControlStateNormal];
//    [refreshMavpViewBtn setTitleColor:UIColorFromRGB(0x006bb6) forState:UIControlStateNormal];
//    [refreshMavpViewBtn.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:32.0]];
//    refreshMavpViewBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
//    refreshMavpViewBtn.layer.shadowOffset  = CGSizeMake(1.5f, 1.5f);
//    refreshMavpViewBtn.layer.shadowOpacity = 1.0;
//    refreshMavpViewBtn.layer.shadowRadius  = 4.0;
//    [refreshMavpViewBtn sizeToFit];
//    [refreshMavpViewBtn setCenter:CGPointMake(refreshMavpViewBtn.center.x *1.3,
//                                              refreshMavpViewBtn.center.y *1.3) ];
//    [self.mapView addSubview:refreshMavpViewBtn];
    
    // Adding fullscreen mode button to the mapview
//    self.fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.fullScreenBtn addTarget:self action:@selector(mapViewFSToggle:)
//                 forControlEvents:UIControlEventTouchUpInside];
//    [self.fullScreenBtn setTitle:@""/*⧈▣"*/ forState:UIControlStateNormal];
//    [self.fullScreenBtn setTitleColor:UIColorFromRGB(0x006bb6) forState:UIControlStateNormal];
//    [self.fullScreenBtn.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:24.0]];
//    self.fullScreenBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
//    self.fullScreenBtn.layer.shadowColor   = [UIColor whiteColor].CGColor;
//    self.fullScreenBtn.layer.shadowOffset  = CGSizeMake(1.5f, 1.5f);
//    self.fullScreenBtn.layer.shadowOpacity = 1.0;
//    self.fullScreenBtn.layer.shadowRadius  = 4.0;
//    [self.fullScreenBtn sizeToFit];
//    [self.fullScreenBtn setCenter:CGPointMake(self.mapView.frame.size.width-_fullScreenBtn.center.x * 1.5,
//                                              self.mapView.frame.size.height * 0.10)];
//    [self.mapView addSubview:self.fullScreenBtn];
//    
    
    
    /* CONFIGUREOVERLAY->check for pending requests-> if user accepts requests, add overlay to mapview
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"adminID"] != NULL) {
        [self loginCurrentUserToCloudStore]; // login to cloud store
    }
    */
}
-(void) setupMapViewControls{
    // Adding a compass needle to find me
    UIButton *compassNeedleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [compassNeedleBtn addTarget:self action:@selector(goToCurrentLocation:)
               forControlEvents:UIControlEventTouchUpInside];
    [compassNeedleBtn setTitle:@"➤"/*@""*/ forState:UIControlStateNormal];
    [compassNeedleBtn setTitleColor:UIColorFromRGB(0x006bb6) forState:UIControlStateNormal];
    [compassNeedleBtn.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:18.0]];
    compassNeedleBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    compassNeedleBtn.layer.shadowColor   = [UIColor whiteColor].CGColor;
    compassNeedleBtn.layer.shadowOffset  = CGSizeMake(1.5f, 1.5f);
    compassNeedleBtn.layer.shadowOpacity = 1.0;
    compassNeedleBtn.layer.shadowRadius  = 4.0;
    [compassNeedleBtn sizeToFit];
    CGPoint compassOrigin = CGPointMake(self.view.frame.size.width - compassNeedleBtn.frame.size.width/2.0 - 8.0, self.tableView.frame.origin.y - compassNeedleBtn.frame.size.height);
    [compassNeedleBtn setCenter:compassOrigin];
    [compassNeedleBtn setTransform:CGAffineTransformMakeRotation(-M_PI * 0.33)];
    [self.mapView addSubview:compassNeedleBtn];
}
-(void) setupWatchMeSwitch {
    watchMeSwitch = [[UISwitch alloc] init];
    [watchMeSwitch addTarget:self
                      action:@selector(watchMeSwitchEnabled:)
            forControlEvents:UIControlEventValueChanged];
    watchMeSwitch.layer.cornerRadius = watchMeSwitch.frame.size.height/2.0;
    watchMeSwitch.layer.borderWidth =  1.0;
    watchMeSwitch.layer.borderColor = [UIColor whiteColor].CGColor;
    [watchMeSwitch sizeToFit];
    [watchMeSwitch setCenter:CGPointMake(self.optionsButton.frame.origin.x - watchMeSwitch.frame.size.width, self.optionsButton.center.y)];
    [watchMeSwitch setCenter:CGPointMake(10+watchMeSwitch.frame.size.width/2.0f,
                                        APP_SCREEN_FRAME.origin.y + 6.0)];
    [self.mapView addSubview:watchMeSwitch];
    
    
//    UIView* switchView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
//                                                                   watchMeSwitch.frame.size.width *1.5,
//                                                                   watchMeSwitch.frame.size.height*1.7)];
//    [switchView1 setBackgroundColor:[UIColor colorWithHue:.580555 saturation:0.31 brightness:0.90 alpha:0.5]];
//    switchView1.layer.cornerRadius = watchMeSwitch.frame.size.height/4.0;
//    switchView1.layer.masksToBounds = YES;
//    [switchView1 addSubview:watchMeSwitch];
//    [switchView1 setCenter:CGPointMake(/*self.view.frame.size.width  -*/ (switchView1.center.x * 1.2),
//                                       APP_SCREEN_FRAME.size.height*.55)];
//    
//    [watchMeSwitch setCenter:CGPointMake(switchView1.frame.size.width/2.0,
//                                         watchMeSwitch.center.y)];
//    [self.mapView addSubview:switchView1];

//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
//    [label setTextColor:[UIColor blueColor]];  //]colorWithHue:.580555 saturation:0.31 brightness:0.90 alpha:0.5]];
//    [label setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:10.0]];
//    [label setText:@"WatchMe"];//
//    [label sizeToFit];
//    [label setCenter:CGPointMake(watchMeSwitch.center.x,watchMeSwitch.frame.size.height+label.center.y*1.75f)];
//    [switchView1 addSubview:label];
    
}
//-(void) setupHelpMeSwitch
//{
//    helpMeNowSwitch = [[UISwitch alloc] init];
//    [helpMeNowSwitch addTarget:self
//                        action:@selector(helpMeNowSwitchAction:)
//              forControlEvents:UIControlEventValueChanged];
//    helpMeNowSwitch.layer.cornerRadius = helpMeNowSwitch.frame.size.height/2.0;
//    helpMeNowSwitch.layer.borderWidth =  1.0;
//    helpMeNowSwitch.layer.borderColor = [UIColor whiteColor].CGColor;
//    [helpMeNowSwitch setOn:NO animated:YES];
//    [helpMeNowSwitch setOnTintColor:[UIColor redColor]];
//    [helpMeNowSwitch setBackgroundColor:[UIColor clearColor]];
//    [self.navigationController.toolbar addSubview:helpMeNowSwitch];
//
//    UIView* switchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
//                                                                   watchMeSwitch.frame.size.width *1.5,
//                                                                   watchMeSwitch.frame.size.height*1.7)];
//    [switchView setBackgroundColor:[UIColor colorWithHue:.580555 saturation:0.31 brightness:0.90 alpha:0.5]];
//    switchView.layer.cornerRadius = watchMeSwitch.frame.size.height/4.0;
//    switchView.layer.masksToBounds = YES;
//    [switchView addSubview:helpMeNowSwitch];
//    [switchView setCenter:CGPointMake(/*self.view.frame.size.width  - */(switchView.center.x * 1.2),
//                                      /*self.view.frame.size.height - switchView.frame.size.height/2.0*/
//                                      self.tableView.frame.origin.y - switchView.frame.size.height)];
//    
//    [helpMeNowSwitch setCenter:CGPointMake(switchView.frame.size.width/2.0,
//                                         watchMeSwitch.center.y)];
//    [self.mapView addSubview:switchView];
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
//    [label setTextColor:[UIColor blueColor]];
//    [label setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:10.0]];
//    [label setText:@"HelpMe"];//
//    [label sizeToFit];
//    [label setCenter:CGPointMake(watchMeSwitch.center.x,watchMeSwitch.frame.size.height+label.center.y*1.75f)];
//    [switchView addSubview:label];
//    
//}
-(void) setupOptionsNavigation
{
    self.optionsButton= [[UIButton alloc] initWithFrame:CGRectZero];
    [self.optionsButton setTitle:@"☰" forState:(UIControlStateNormal)];
    [self.optionsButton.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:22]];
    
    if (![self.optionsButton isEnabled])
        [self.optionsButton setEnabled:YES];
    [self.optionsButton sizeToFit];
    [self.optionsButton addTarget:self
                           action:@selector(viewMenuOptions:)
                 forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.optionsButton];
    [self.optionsButton setCenter:CGPointMake(APP_SCREEN_FRAME.size.width - self.optionsButton.frame.size.width/2.0 - 6, APP_SCREEN_FRAME.origin.y + self.optionsButton.frame.size.height/2.0 + 6)];
    
}
-(void) setupTxtFriensoChat
{
    self.txtChattingBtn= [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 18)];
    [self.txtChattingBtn setBackgroundImage:[UIImage imageNamed:@"chaticon44px.png"]
                                   forState:UIControlStateNormal];
    if (![self.txtChattingBtn isEnabled])
        [self.txtChattingBtn setEnabled:YES];
    [self.txtChattingBtn addTarget:self
                           action:@selector(viewFriensoChatWindow:)
                 forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.txtChattingBtn];
    [self.txtChattingBtn setCenter:CGPointMake(self.optionsButton.frame.origin.x - self.txtChattingBtn.frame.size.width, self.optionsButton.center.y)];
    
}
- (void) setupNavigationBar
{
    if (STORYBOARD_CONF_II)
    {
        /******** LEFT HAND SIDE TITLE
         **************************************/
        /* [self.navigationController.navigationBar setBarTintColor:UIColorFromRGB(0xbdc3c7)];
         [self.view setBackgroundColor:UIColorFromRGB(0xecf0f1)];
         */
        
//        UILabel* friensoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        [friensoLabel setText:@"Frienso"];
//        friensoLabel.layer.shadowColor  = UIColorFromRGB(0x8e44ad).CGColor;
//        friensoLabel.layer.shadowOffset = CGSizeMake(0,0.5);
//        friensoLabel.layer.shadowOpacity = 1.0;
//        friensoLabel.layer.shadowRadius  = 2.0f;
//        friensoLabel.layer.masksToBounds = NO;
//        [friensoLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Regular" size:21.0]];
//        [friensoLabel setTextColor:[UIColor whiteColor]];
//        [friensoLabel sizeToFit];
//        [self.view addSubview:friensoLabel];
        
        UIView *newTitleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.frame];
        navGestures = [[UIGestureRecognizer alloc] initWithTarget:self
                                                           action:@selector(navigationCtrlrSingleTap:)];
        [navGestures setDelegate:self];
        
        // The Avatar
        UIImage *image = nil;
        UIImageView __block *imgView = nil;
        if ( [[NSUserDefaults standardUserDefaults] URLForKey:@"profileImageUrl"] == NULL) {
            //NSLog(@"  avatar.png...");
            image = [UIImage imageNamed:@"avatar.png"];
            UIImage *scaledimage = [[[FRStringImage alloc] init] scaleImage:image toSize:CGSizeMake(38.0, 38.0)];
            imgView = [self newImageViewWithImage:scaledimage
                                      showInFrame:CGRectMake(0, 0, 38.0f, 38.0f)];
        } else {
            NSLog(@"  profileImageUrl...");
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
        imgView.layer.borderWidth  = 2.0;
        imgView.layer.borderColor  = [UIColor whiteColor].CGColor;
        imgView.layer.masksToBounds = YES;
        [imgView setImage:image];
        [imgView setCenter:self.navigationItem.titleView.center];
        [newTitleView addSubview:imgView];
        
        // Isolate tap to only the navigation bar
        [newTitleView addGestureRecognizer:navGestures];
        [self.view addSubview:newTitleView];
        [newTitleView setCenter:CGPointMake(self.view.center.x,APP_SCREEN_FRAME.origin.y + imgView.frame.size.height/2.0 + 6.0)];
//        [friensoLabel setCenter:CGPointMake(10+friensoLabel.frame.size.width/2.0f,
//                                            APP_SCREEN_FRAME.origin.y + imgView.frame.size.height/2.0 + 6.0)];

    } else {
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHue:0.580555
                                                                        saturation:0.31
                                                                        brightness:0.90
                                                                             alpha:0.5]];
    
    
    //[UIView animateWithDuration:0.5 animations:^{
    UIView *newTitleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.frame];
    navGestures = [[UIGestureRecognizer alloc] initWithTarget:self
                                                       action:@selector(navigationCtrlrSingleTap:)];
    [navGestures setDelegate:self];
    
    // The Avatar
    UIImage *image = nil;
    UIImageView __block *imgView = nil;
    if ( [[NSUserDefaults standardUserDefaults] URLForKey:@"profileImageUrl"] == NULL) {
        //NSLog(@"  avatar.png...");
        image = [UIImage imageNamed:@"avatar.png"];
        UIImage *scaledimage = [[[FRStringImage alloc] init] scaleImage:image toSize:CGSizeMake(38.0, 38.0)];
        imgView = [self newImageViewWithImage:scaledimage
                                  showInFrame:CGRectMake(0, 0, 38.0f, 38.0f)];
    } else {
        NSLog(@"  profileImageUrl...");
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
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - HomeView Methods
-(void)navigationCtrlrSingleTap:(id) sender {

    self.profileView = [[ProfileSneakPeekView alloc] initWithFrame:self.navigationController.navigationBar.frame];
    [self.profileView setUserEmailString:[[NSUserDefaults standardUserDefaults] objectForKey:@"adminID"]
                         withPhoneNumber:[[NSUserDefaults standardUserDefaults] objectForKey:@"userPhone"]
     ];
    [self.profileView.settingsGearBtn addTarget:self
                                         action:@selector(presentProfileSettingsView:)
                               forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.profileView];
    
}
//-(void)navigationCtrlrSingleTap {
//    NSLog(@"Tapped: %.2f", self.navigationController.navigationBar.frame.size.height);
//    self.profileView = [[ProfileSneakPeekView alloc] initWithFrame:self.navigationController.navigationBar.frame];
//    [self.profileView setUserEmailString:@"saguinag" withPhoneNumber:@"5743394087"];
//    [self.view addSubview:self.profileView];
//    
//}
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

-(void)viewFriensoChatWindow:(UISwitch *)sender
{
    /** *****************
     ** showFriensoChat segue should go to the chatviewcontroller where stuff is organized in 
     ** by most recent individual or group chat
     ** *****************/
    [self performSegueWithIdentifier:@"showFriensoChat" sender:self];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:self.navigationItem.backBarButtonItem.style
                                                                            target:nil
                                                                            action:nil];
}
-(void)viewMenuOptions:(UIButton *)theButton {
    [self animateThisButton:theButton];
    [self performSegueWithIdentifier:@"showMenuOptions" sender:self];
    [theButton.layer setBorderColor:[UIColor grayColor].CGColor];
    self.navigationController.navigationBarHidden = NO;
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

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.frc sections] count];
}
// handling the sections for these data
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    //id <NSFetchedResultsSectionInfo> sectionInfo = [[self.frc sections] objectAtIndex:section];
    return @"Activity, News, and Events";//[sectionInfo name];
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
    
    if (scrollView.contentOffset.y == 0 &&(self.tableView.frame.origin.y > fullScreenRect.size.height/2.0))
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
            [tvHeaderView setFrame:CGRectMake(0,fullScreenRect.origin.y,self.view.bounds.size.width,self.tableView.frame.origin.y)];
            [tvHeaderView setBackgroundColor:[UIColor blackColor]];
            tvHeaderView.alpha = 0.8;
            [tvHeaderView.titleLabel setTextAlignment:NSTextAlignmentRight];
            [tvHeaderView setTitle:@"× Dismiss" forState:UIControlStateNormal];
            [tvHeaderView addTarget:self action:@selector(closeFullscreenTableViewAction:)
                   forControlEvents:UIControlEventTouchUpInside];//tvFSCloseAction) withSender:self];
            [self.view addSubview:tvHeaderView];
        }];
    }
    
}

#pragma mark - Location methods
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

- (void) goToCurrentLocation:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton* myButton = (UIButton*)sender;
        [self animateThisButton:myButton];
        [UIView animateWithDuration:0.75 animations:^{
            [myButton setTransform:CGAffineTransformMakeRotation(-M_PI)];
            [myButton setTransform:CGAffineTransformMakeRotation(-M_PI * 0)];
            [myButton setTransform:CGAffineTransformMakeRotation(-M_PI * 0.33)];
            [self.locationManager startUpdatingLocation];
            [self setInitialLocation:self.locationManager.location];
            self.mapView.region = MKCoordinateRegionMake(self.location.coordinate, MKCoordinateSpanMake(0.05f, 0.05f));
        }];
    }
}

#pragma mark - Local Actions
-(void) watchMeSwitchEnabled:(UISwitch*)sender
{
    if (DBG) NSLog(@"********* trackMeswitchEnabled ****");
    
    if ([sender isOn]){
        /*for (id subview in [sender subviews])
        {
            UILabel *label = subview;
            if (label.tag > 99)
                [label removeFromSuperview];
        }*/
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
-(void) closeFullscreenTableViewAction:(UIButton*)sender {
    [UIView animateWithDuration:0.3 animations:^{
        [self.tableView setFrame:tblViewFrame];
        [sender removeFromSuperview];
    }];
    
}
#pragma mark - Helper Methods
- (UIImage*)imageWithBorderFromImage:(UIImage*)source
{
    const CGFloat margin = 6.0f;
    CGSize size = CGSizeMake([source size].width + 2*margin, [source size].height + 2*margin);
    UIGraphicsBeginImageContext(size);
    
    [[UIColor whiteColor] setFill];
    [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)] fill];
    
    CGRect rect = CGRectMake(margin, margin, size.width-2*margin, size.height-2*margin);
    [source drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];
    
    UIImage *testImg =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return testImg;
}
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
                [watchMeSwitch setOn:NO animated:YES]; // Nothing happens -- no action
                break;
            case 1: // accept
                //if (DBG) NSLog(@"Accept: 1:%ld", buttonIndex);
                [self logAndNotifyCoreFriendsToWatchMe];
                break;
            default:
                break;
        }
    }
    else if (tag_no >= 100) {
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
//                [self updateMapViewWithUserBubbles: self.watchingCoFrArray];
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



#pragma mark - More Local functions

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
@end
