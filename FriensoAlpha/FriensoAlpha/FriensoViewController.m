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
#import "WatchMeEventTracking.h"
#import "FRSyncFriendConnections.h"



#define ARC4RANDOM_MAX      0x100000000
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define CELL_CONTENT_MARGIN 10.0f

static NSString *eventCell = @"eventCell";
enum PinAnnotationTypeTag {
    PinAnnotationTypeTagGeoPoint = 0,
    PinAnnotationTypeTagGeoQuery = 1
};



@interface FriensoViewController ()
{
    NSMutableArray *coreFriendsArray;
}
@property (nonatomic,retain) NSMutableArray *friendsLocationArray;
@property (nonatomic,strong) NSFetchedResultsController *frc;
@property (nonatomic,strong) CLLocation *location;
@property (nonatomic,strong) UITableView *tableView;
//@property (nonatomic,strong) UITableView *rsrcTableView; //frienso resources tableview
@property (nonatomic,strong) UIButton *selectedBubbleBtn;
@property (nonatomic,strong) UIActivityIndicatorView *loadingView;
@property (nonatomic,strong) UIScrollView *trackingStatusView;

-(void)actionPanicEvent:(UIButton *)theButton;
-(void)viewMenuOptions: (UIButton *)theButton;
-(void)viewCoreCircle:  (UIButton *)theButton;
-(void)makeFriensoEvent:(UIButton *)theButton;

@end

@implementation FriensoViewController
@synthesize locationManager  = _locationManager;


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
    //return 1;
    return [[self.frc sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.frc.sections[section];
    //NSLog(@"%lu",sectionInfo.numberOfObjects);
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


#pragma mark - NSFetchResultsController delegate methods
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    //printf("refreshing frc\n");
    [self.tableView reloadData];
}

#pragma mark - Local Actions
-(void) trackMeSwitchEnabled:(UISwitch *)sender {
    if ([sender isOn]){
    UILabel *trackMeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [trackMeLabel setText:@"Watch Me"];
    [trackMeLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Thin" size:14.0]];
    [trackMeLabel sizeToFit];
    [self.navigationController.toolbar addSubview:trackMeLabel];
    [trackMeLabel setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
    [trackMeLabel setCenter:sender.center];

    // animate help
    [self animateHelpView:trackMeLabel];
    [UIView animateWithDuration:3.0
                     animations:^{trackMeLabel.alpha = 0.0;}
                     completion:^(BOOL finished){ [trackMeLabel removeFromSuperview]; }];
    
    // Watch Me event tracking
    WatchMeEventTracking *watchMeEvent = [[WatchMeEventTracking alloc] initWithAlertType:@"watchMe"
                                                                      eventStartDateTime:[NSDate date] ];
    [watchMeEvent setPersonalEvent];
    [watchMeEvent sendToCloud];
    } else {
        NSLog(@"Stop the watch");
        WatchMeEventTracking *watchMeEvent = [[WatchMeEventTracking alloc] initWithAlertType:@"watchMe"
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

#pragma mark - Setup view widgets
-(void) setupHalfMapView {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userLocation"] != NULL) {
        [self.locationManager startUpdatingLocation];
        [self setInitialLocation:self.locationManager.location];
    }
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
    [self.mapView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height * 0.25)];

    self.mapView.region = MKCoordinateRegionMake(self.location.coordinate,MKCoordinateSpanMake(0.05f,0.05f));
    self.mapView.layer.borderWidth = 2.0f;
    self.mapView.layer.borderColor = [UIColor whiteColor].CGColor;//UIColorFromRGB(0x9B90C8).CGColor;
    [self.view addSubview:self.mapView];
    
    [self configureOverlay];
    
    if([self.loadingView isAnimating])
        [self.loadingView stopAnimating];

}
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

-(void) setupEventsTableView {
    UIView *tableHelpView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height * 0.5,
                                                                     self.view.frame.size.width, self.view.frame.size.height * 0.5)];// help view
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
    [self.tableView setFrame:CGRectMake(0, self.view.frame.size.height * 0.5,
                                         self.view.frame.size.width, self.view.frame.size.height * 0.5)];
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    self.tableView.layer.borderWidth = 2.0f;
    self.tableView.layer.borderColor = [UIColor whiteColor].CGColor;// UIColorFromRGB(0x9B90C8).CGColor;
    [self.view addSubview:self.tableView];
    
    /*** Tile label
    UILabel *tileLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [tileLabel setText:@"ACTIVITY"];
    [tileLabel sizeToFit];
    [tileLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:16.0]];
    [tileLabel setTextColor:UIColorFromRGB(0x006bb6)];
    [tileLabel setTextAlignment:NSTextAlignmentRight];
    [tileLabel setCenter:CGPointMake(self.view.bounds.size.width -tileLabel.frame.size.width/1.5,
                                     self.tableView.frame.origin.y+tileLabel.frame.size.height*1.3/2.0)];
    [self.view addSubview:tileLabel];
    ***/
    
    
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
    
    UISwitch *trackMeOnOff = [[UISwitch alloc] init];
    
    [trackMeOnOff addTarget:self action:@selector(trackMeSwitchEnabled:)
           forControlEvents:UIControlEventValueChanged];
    [trackMeOnOff setCenter:CGPointMake(self.navigationController.toolbar.bounds.size.width*0.85, 22)];
    
    // Local store check for active event
    if( [[[WatchMeEventTracking alloc] init] activeAlertCheck]) {
        NSLog(@"Yes, an alert is active!");
        [trackMeOnOff setOn:YES animated:YES];
    } else
        [trackMeOnOff setOn:NO animated:YES];
    
    
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
    [self.navigationController.toolbar addSubview:trackMeOnOff]; // right
    [self.navigationController.toolbar addSubview:panicButton]; // center

}
-(void) setupNavigationBarImage{
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:16.0], NSFontAttributeName,nil]];
    self.navigationItem.title = @"FRIENSO";
    
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
    
    // Right Options Button
    FriensoOptionsButton *button = [[FriensoOptionsButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
    button.layer.cornerRadius = 4.0;
    button.layer.borderWidth =  1.0;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    [button addTarget:self action:@selector(viewMenuOptions:)
     forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton=[[UIBarButtonItem alloc] init];
    [barButton setCustomView:button];
    //self.navigationItem.rightBarButtonItem=barButton;
    
    
    
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

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    // Make sure your segue name in storyboard is the same as this line
//    if ([[segue identifier] isEqualToString:@"viewLogin"])
//    {
//        // Get reference to the destination view controller
//        ABALoginTVC *vc = [segue destinationViewController];
//        vc.delegate = self;
//    }
//}
#pragma mark - FriensoViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    printf("[ Dashboard: FriensoVC ]\n");
    
    self.navigationController.navigationBarHidden = NO;
    self.friendsLocationArray = [[NSMutableArray alloc] init]; // friends location cache
    
    // Show progress indicator to tell user to wait a bit
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.loadingView setColor:UIColorFromRGB(0xf47d44)];
    [self.view addSubview:self.loadingView];
    [self.loadingView setCenter:CGPointMake(self.view.center.x, self.view.bounds.size.height*0.2)];
    [self.loadingView startAnimating];
    
    [self setupToolBarIcons];
    [self setupNavigationBarImage];
    /*[self setupHalfMapView]; */
    [self trackFriendsView];  // who is active?
    [self setupEventsTableView];
    
    //[self syncCoreFriendsLocation]; // from parse to coredata

    
    
    // Check if friends have ongoing event
    //[[ParseAlertEvent alloc] init] ongoingAlertEventCheck];
    
    
}
- (void)viewDidUnload {
    [super viewDidUnload];
    NSLog(@"viewDidUnload");
    self.tableView = nil;
}
-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    NSLog(@"viewWillAppear");
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear");
    
    NSString       *adminKey    = [[NSUserDefaults standardUserDefaults] objectForKey:@"adminID"];
    if ([adminKey isEqualToString:@""] || adminKey == NULL || adminKey == nil){
        [self performSegueWithIdentifier:@"loginView" sender:self];
        NSLog(@"{Presenting loginView}");
    } else {
        BOOL newUser = [[NSUserDefaults standardUserDefaults] boolForKey:@"newUserFlag"];
        if (newUser == YES){
            [self performSegueWithIdentifier:@"newCoreCircle" sender:self];
            NSLog(@"{Presenting newCoreCircle}");
        }
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userLocation"] != NULL) {
        [self setupHalfMapView];
//        [self.locationManager startUpdatingLocation];
//        [self setInitialLocation:self.locationManager.location];
    }
    
    //  cache resources from parse
    // The className to query on
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
                    /*for(FriensoEvent *thisFEvent in items){
                        if([thisFEvent.eventObjId isEqualToString: nameToEnter]){
                            unique = NO;
                        }
                        //NSLog(@"%@", thisPerson);
                    }
                    */
                    unique = NO;
                    //NSLog(@"%ld", [items count]);
                    
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
            } else NSLog(@"! Parse event is not unique");
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - CoreData helper methods
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
    [self configureOverlay]; NSLog(@"calling configureOverlay");
    
}
-(void) syncCoreFriendsLocation {
    NSLog(@"--- syncCoreFriendsLocation  [ Sync friends' location to CoreData ]");
    
    FRCoreDataParse *frCDPObject = [[FRCoreDataParse alloc] init];
    [frCDPObject updateThisUserLocation];
    [frCDPObject updateCoreFriendsLocation];
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
//        [self configureOverlay];
    }
}

- (CLLocationManager *)locationManager {
	
    if (_locationManager != nil) {
		return _locationManager;
	}
	//NSLog(@"[1]");
	_locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    _locationManager.delegate = self;
    //_locationManager.purpose = @"Your current location is used to demonstrate PFGeoPoint and Geo Queries.";
	
	return _locationManager;
}
- (void)setInitialLocation:(CLLocation *)aLocation {
    self.location = aLocation;
//    self.radius = 1000;
    //NSLog(@"%.2f,%.2f",self.location.coordinate.latitude, self.location.coordinate.longitude);
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            NSLog(@"My geo-location: %f, %f", geoPoint.latitude, geoPoint.longitude);
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
    if (self.location) {
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView removeOverlays:self.mapView.overlays];
        
        /**CircleOverlay *overlay = [[CircleOverlay alloc] initWithCoordinate:self.location.coordinate radius:self.radius];
        [self.mapView addOverlay:overlay];
        **/
        
        //[self addCoreFriendBubblesToMap:self.mapView];
        
        GeoQueryAnnotation *annotation = [[GeoQueryAnnotation alloc] initWithCoordinate:self.location.coordinate radius:1000];
        [self.mapView addAnnotation:annotation];
        
        [self updateLocations];
    } else
        NSLog(@"! no location ");
}
-(void)friendLocInteraction:(UIButton *)sender
{
    NSLog(@"...friendLocInteraction");
//    NSLog(@"%@", [self.friendsLocationArray objectAtIndex:sender.tag]);
    NSString *coordinateStr =[self.friendsLocationArray objectAtIndex:sender.tag];
    CGFloat geoLatitude = [[coordinateStr componentsSeparatedByString:@","][0] doubleValue];
    CGFloat geoLongitude = [[coordinateStr componentsSeparatedByString:@","][1] doubleValue];

    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(geoLatitude, geoLongitude),
                                                   MKCoordinateSpanMake(0.01, 0.01) )];
    NSArray *array = @[sender.titleLabel.text,                               // Initials
                       [coordinateStr componentsSeparatedByString:@","][0],  // latitude
                       [coordinateStr componentsSeparatedByString:@","][1]]; // longitude
    
    GeoCDPointAnnotation *geoCDPointAnn = [[GeoCDPointAnnotation alloc] initWithObject:array];
    [self.mapView addAnnotation:geoCDPointAnn];
    
#warning Insert an annotation using stored loc info fromCoreData, then update if network availability
    
    /** location for sender.tag
        **/

    //[self lastKnownLocationForFriend:[coFrDic objectForKey:keys[0]]];
    /*NSDictionary *coFrDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"CoreFriendsContactInfoDicKey"];
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
    */
    
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
    NSLog(@"... updateLocations");
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init]; // Create the fetch request
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CoreFriends"
                                              inManagedObjectContext:[self managedObjectContext]];
    
    [fetchRequest setEntity:entity];
    NSSortDescriptor *phoneSort =  [[NSSortDescriptor alloc] initWithKey:@"corePhone"
                                                                  ascending:YES];
    
//    NSSortDescriptor *eventTitleSort =  [[NSSortDescriptor alloc] initWithKey:@"coreFirstName"
//                                                                    ascending:NO];
    
    fetchRequest.sortDescriptors = @[phoneSort];
    
    NSError *error;
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        // Handle the error.
    } else if ( [[self.trackingStatusView subviews] count] < [fetchedObjects count]){
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
            [self.trackingStatusView addSubview:mLocBtn];
            [mLocBtn setCenter:CGPointMake(mLocBtn.frame.size.width + mLocBtn.center.x + i*(mLocBtn.frame.size.width), self.trackingStatusView.frame.size.height - mLocBtn.center.y)];
            
                
            [self.friendsLocationArray insertObject:([mObject valueForKey:@"coreLocation"] == NULL)  ? @"0,0" : [mObject valueForKey:@"coreLocation"]  atIndex:i];
            i++;
        }
    }
    
    NSLog(@"subviews: %ld", [[self.trackingStatusView subviews] count]);

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
/*
 *  http://borkware.com/quickies/one?topic=Graphics
 *  http://stackoverflow.com/questions/10895035/coregraphics-draw-an-image-on-a-white-canvas
 *  http://iwork3.us/2013/09/13/pantone-ny-fashion-week-2014-spring-colors/
 **/
@end
