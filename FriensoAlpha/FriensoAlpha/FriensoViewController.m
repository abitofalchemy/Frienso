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
#import "GeoQueryAnnotation.h"
#import "FriensoResources.h"


#define ARC4RANDOM_MAX      0x100000000
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
static NSString *eventCell = @"eventCell";
enum PinAnnotationTypeTag {
    PinAnnotationTypeTagGeoPoint = 0,
    PinAnnotationTypeTagGeoQuery = 1
};



@interface FriensoViewController ()
{
    NSMutableArray *coreFriendsArray;
}
@property (nonatomic,retain) NSMutableArray *coreFriendsArray;
@property (nonatomic, strong) NSFetchedResultsController *frc;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UITableView *rsrcTableView; //frienso resources tableview

-(void)actionPanicEvent: (UIButton *)theButton;
-(void)viewMenuOptions: (UIButton *)theButton;
-(void)viewCoreCircle:  (UIButton *)theButton;
-(void)makeFriensoEvent:(UIButton *)theButton;

@end

@implementation FriensoViewController
@synthesize coreFriendsArray = _coreFriendsArray;
@synthesize locationManager  = _locationManager;


-(void)actionPanicEvent:(UIButton *)theButton {
    [self animateThisButton:theButton];
    [theButton.layer setBorderColor:[UIColor redColor].CGColor];
    [theButton setHidden:YES];
    [theButton setEnabled:NO];
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
    if ([theButton isEnabled]) {
        [theButton setEnabled:NO];
        [theButton.layer setBorderColor:[UIColor redColor].CGColor];
    }
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
    
        if (indexPath.row == 0)
            return [tableView rowHeight]*2.0f;
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
        NSLog(@"%@", event.eventImage);
        NSURL *imageURL = [NSURL URLWithString:event.eventImage];
        //[NSURL URLWithString:@"http://static01.nyt.com/images/2014/04/29/us/politics/29ASSAULT/29ASSAULT-master315.jpg"];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        UIImage *img = [UIImage imageWithData:imageData];
        cell.imageView.image = [self imageWithBorderFromImage:img];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setTag:10];
    } else {
        cell.imageView.image = [self imageWithBorderFromImage:[UIImage imageNamed:@"profile-24.png"]];
        cell.backgroundColor = [UIColor clearColor];
    }
//    //
    if (indexPath.row == 0){
        [cell.textLabel setNumberOfLines:3];
        [cell.detailTextLabel setNumberOfLines:3];
//        [cell setFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height*2.0)];
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
    //NSLog(@"-- Map button touched --");
    [self animateThisButton:button];
    [self performSegueWithIdentifier:@"showFriesoMap" sender:self];
}

#pragma mark - Setup view widgets
-(void) setupEventsTableView {
    UIView *tableHelpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                     self.view.bounds.size.width,
                                                                     self.view.bounds.size.height*0.66)];// help view
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
    [self.tableView setFrame:CGRectMake(0, self.view.bounds.size.height*0.305,
                                        self.view.bounds.size.width,
                                        self.view.bounds.size.height*0.66)];
    
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    //self.tableView.layer.cornerRadius = 6.0f;
    self.tableView.layer.borderWidth = 1.0f;
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
    
    
    /* Create the fetch request first */
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]
                                    initWithEntityName:@"FriensoEvent"];
    
    NSSortDescriptor *createdSort =
    [[NSSortDescriptor alloc] initWithKey:@"eventCreated"
                                ascending:NO];
    
    NSSortDescriptor *prioritySort =
    [[NSSortDescriptor alloc] initWithKey:@"eventPriority"
                                ascending:NO];
    
    fetchRequest.sortDescriptors = @[prioritySort,createdSort];
    
    self.frc = [[NSFetchedResultsController alloc]
     initWithFetchRequest:fetchRequest
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

-(void) setupHalfMapView {
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width,self.view.bounds.size.height*0.3)];
    [self.view addSubview:self.mapView];
    self.mapView.region = MKCoordinateRegionMake(self.location.coordinate,MKCoordinateSpanMake(0.05f,0.05f));

    self.mapView.layer.borderWidth = 2.0f;
    self.mapView.layer.borderColor = UIColorFromRGB(0x9B90C8).CGColor;
    [self configureOverlay];
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
    //self.navigationItem.leftBarButtonItem=barLeftButton;
    [coreCircleBtn setCenter:CGPointMake(44.0f,22)];
    
    // right tool bar btn
    FriensoPersonalEvent *calEventBtn = [[FriensoPersonalEvent alloc]
                                            initWithFrame:CGRectMake(0, 0, 27, 27)];
    calEventBtn.layer.cornerRadius = 4.0f;
    calEventBtn.layer.borderWidth = 1.0f;
    calEventBtn.layer.borderColor = UIColorFromRGB(0x006bb6).CGColor;
    [calEventBtn addTarget:self action:@selector(makeFriensoEvent:)
          forControlEvents:UIControlEventTouchUpInside];
    [calEventBtn setCenter:CGPointMake(self.navigationController.toolbar.bounds.size.width - 44.0f,22)];
    [calEventBtn setTitleShadowColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    // center toolbar btn
    UIButton *panicButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
    [panicButton addTarget:self action:@selector(actionPanicEvent:)
          forControlEvents:UIControlEventTouchUpInside];
    [panicButton setTitle:@"\u26A0" forState:(UIControlStateNormal)];
    panicButton.layer.cornerRadius = 4.0f;
    panicButton.layer.borderWidth = 1.0f;
    panicButton.layer.borderColor = UIColorFromRGB(0x006bb6).CGColor;;
//    [panicButton.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:22.0]];
    panicButton.titleLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:107.0/255.0 blue:182.0/255.0 alpha:1.0];
    [panicButton setCenter:CGPointMake(self.navigationController.toolbar.center.x, 22)];
    
    [self.navigationController.toolbar addSubview:coreCircleBtn]; // left
    [self.navigationController.toolbar addSubview:calEventBtn]; // right
    [self.navigationController.toolbar addSubview:panicButton]; // center

}
-(void) setupNavigationBarImage{
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor blackColor], NSForegroundColorAttributeName,
      [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:16.0], NSFontAttributeName,nil]];
    self.navigationItem.title = @"FRIENSO";
    
    // Left CoreCircle button
    UIButton *ugcTopLeftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
    [ugcTopLeftBtn setImage:[UIImage imageNamed:@"ugc-ic-29x2.png"] forState:UIControlStateNormal];
    [ugcTopLeftBtn setTintColor:UIColorFromRGB(0x007aff)];
    [ugcTopLeftBtn addTarget:self action:@selector(viewCoreCircle:)
            forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barLeftButton=[[UIBarButtonItem alloc] init];
    [barLeftButton setCustomView:ugcTopLeftBtn];
    self.navigationItem.leftBarButtonItem=barLeftButton;
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    
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
#pragma mark - Sync from Parse Methods
- (void) syncFromParse {
    printf(" -- syncFromParse --\n");
    //TODO: save core friends to coredata 
    // sync from parse!
    NSMutableDictionary *udCoreCircleDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"CoreFriendsContactInfoDicKey"];
    
    if ([udCoreCircleDictionary count] == 0)
    {
    [PFUser logInWithUsernameInBackground:[[NSUserDefaults standardUserDefaults] objectForKey:@"adminID"]
                                 password:[[NSUserDefaults standardUserDefaults] objectForKey:@"adminPass"]
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            NSLog(@"[ Parse successful login ]"); // Do stuff after successful login.
                                            
                                            // sync from parse!
                                            PFQuery *query = [PFQuery queryWithClassName:@"UserCoreFriends"];
                                            [query whereKey:@"user" equalTo:user];
                                            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
                                             {
                                                 if (!error) { // The find succeeded.
                                                     NSDictionary *parseCoreFriendsDic = [[NSDictionary alloc] init];
                                                     for (PFObject *object in objects) { // Do something w/ found objects
                                                         //NSLog(@"%@",[object valueForKey:@"userCoreFriends"]);
                                                         parseCoreFriendsDic = [object valueForKey:@"userCoreFriends"];
                                                         
                                                     }
                                                     if ( parseCoreFriendsDic != NULL) {
                                                         // Save core friends dictionary to NSUserDefaults
                                                         [self saveCFDictionaryToNSUserDefaults:parseCoreFriendsDic];
                                                         coreFriendsArray = [[NSMutableArray alloc] initWithArray:[parseCoreFriendsDic allKeys]];
                                                         
                                                         
                                                     }
                                                     // Notify that records were fetched from Parse
                                                     [self  actionAddFriensoEvent:@"Contacts successfully fetched and restored."];
                                                 } else {
                                                     // Log details of the failure
                                                     NSLog(@"Error: %@ %@", error, [error userInfo]);
                                                 }
                                             }];
                                            
                                            
                                        } else {
                                            NSLog(@"[ ERROR: Login failed | %@",error);// The login failed. Check error to see why.
                                        }
                                    }];
    }// testing if core circle dic is in nsuserdefaults
    else        NSLog(@"not nil");
}
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
                cFriends.coreType      = @"Person";
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    printf("[ Dashboard: FriensoVC ]\n");
    self.navigationController.navigationBarHidden = NO;

    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"CoreFriendsContactInfoDicKey"] count] == 0)
        [self syncFromParse];
    else
        NSLog(@"all loaded already");
    

    [self setupNavigationBarImage];
    [self.locationManager startUpdatingLocation];
    [self setInitialLocation:self.locationManager.location];

    [self setupHalfMapView];
    [self setupEventsTableView];

    [self syncCoreFriendsLocation]; //  from parse to coredata
    
}
- (void)viewDidUnload {
    self.tableView = nil;
    [super viewDidUnload];
}
-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self setupToolBarIcons];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
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
                    firstFriensoEvent.eventPriority  = [NSNumber numberWithInteger:3];
                    
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
    NSLog(@"[ Sync friends' location to CoreData ]");
    
    FRCoreDataParse *frCDPObject = [[FRCoreDataParse alloc] init];
    [frCDPObject updateThisUserLocation];
    [frCDPObject updateCoreFriendsLocation];
    [frCDPObject showCoreFriendsEntityData];
     
    
}

#pragma mark - core graphics
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
            NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
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
        
        GeoQueryAnnotation *annotation = [[GeoQueryAnnotation alloc] initWithCoordinate:self.location.coordinate radius:1000];
        [self.mapView addAnnotation:annotation];
        
        [self updateLocations];
    }
}
- (void)updateLocations {
    // Get geopoints for coreF
    NSDictionary *retrievedCoreFriendsDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"CoreFriendsContactInfoDicKey"];
    
    if ( [retrievedCoreFriendsDictionary count] > 0) {
        NSArray *connectionKeyArray =  [[NSArray alloc]
                                        initWithArray:[retrievedCoreFriendsDictionary allValues]];
        
        for (NSString *pNumber in connectionKeyArray) {
            //NSLog(@"CoreF contact: %@", pNumber);
            PFQuery *query = [PFQuery queryWithClassName:@"UserConnection"];
            NSRange substrRange = NSMakeRange(pNumber.length-10, 10);
            [query whereKey:@"userNumber" containsString:[pNumber substringWithRange:substrRange]];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
             {
                 if (!error) { // The find succeeded.
                     for (PFObject *object in objects) { // Do something w/ found objects
                         //NSLog(@"%@", object);
                         //NSLog(@"%@", [[object valueForKey:@"user"] objectId]);
                         [self fetchCurrentLocationForUser:[[object valueForKey:@"user"] objectId]];
                     }
                 } else {
                     // Log details of the failure
                     NSLog(@"Error: %@ %@", error, [error userInfo]);
                 }
             }];
            
            
            
            
            
        }
    }
}
-(void) fetchCurrentLocationForUser:(NSString *) coreFriendObjectId {
    /** fetchCurrentLocationForUser
     coreFriendObjectId: objectId in Parse User class
     the connection has to be done via the phone nbr.
     **/

    PFQuery *query = [PFUser query];
    [query getObjectInBackgroundWithId:coreFriendObjectId
                                 block:^(PFObject *object, NSError *error)
     {
         if (!error) {
             NSLog(@"%@, %@", (NSString *)[object valueForKey:@"email"], (PFGeoPoint *)[object valueForKey:@"currentLocation"]);
             [self updateCoreFriendEntity:(NSString *)[object valueForKey:@"email"]
                             withLocation:(PFGeoPoint *)[object valueForKey:@"currentLocation"]];
             GeoPointAnnotation *geoPointAnnotation = [[GeoPointAnnotation alloc] initWithObject:object];
             [self.mapView addAnnotation:geoPointAnnotation];
             
         } else
             NSLog(@"Error: %@ %@", error, [error userInfo]); // Log details of the failure
     }];
}
/*
 *  http://borkware.com/quickies/one?topic=Graphics
 *  http://stackoverflow.com/questions/10895035/coregraphics-draw-an-image-on-a-white-canvas
 *  http://iwork3.us/2013/09/13/pantone-ny-fashion-week-2014-spring-colors/
 **/
@end
