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

#define ARC4RANDOM_MAX      0x100000000
static NSString *eventCell = @"eventCell";



@interface FriensoViewController ()
{
    NSMutableArray *coreFriendsArray;
}
@property (nonatomic,retain) NSMutableArray *coreFriendsArray;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *frc;

-(void)actionPanicEvent: (UIButton *)theButton;
-(void)viewMenuOptions: (UIButton *)theButton;
-(void)viewCoreCircle:  (UIButton *)theButton;
-(void)makeFriensoEvent:(UIButton *)theButton;
-(void)actionHomeView:  (UIButton *)sender;


@end

@implementation FriensoViewController
@synthesize coreFriendsArray = _coreFriendsArray;

-(void)actionPanicEvent:(UIButton *)theButton {
    [self animateThisButton:theButton];
    [theButton.layer setBorderColor:[UIColor redColor].CGColor];
    [theButton setHidden:YES];
    [theButton setEnabled:NO];
    [self performSegueWithIdentifier:@"panicEvent" sender:self];
}
-(void)makeFriensoEvent:(UIButton *)theButton {
    [self animateThisButton:theButton];
    [theButton.layer setBorderColor:[UIColor grayColor].CGColor];
    [theButton setHidden:YES];
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
- (void)actionHomeView:(UIButton *)sender {
    
    
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        anim.duration = 0.125;
        anim.repeatCount = 1;
        anim.autoreverses = YES;
        anim.removedOnCompletion = YES;
        anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)];
        [self.tableView.layer addAnimation:anim forKey:nil];
    
}

- (NSManagedObjectContext *) managedObjectContext{
    
    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
    
}
#pragma mark - UITableViewDataSource Methods
-(void) setupEventsTableView {
    self.tableView = [[UITableView alloc] init];
    [self.tableView setFrame:CGRectMake(0, self.view.bounds.size.height*0.4,
                                        self.view.bounds.size.width,
                                        self.view.bounds.size.height*0.50)];
    
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    self.tableView.layer.cornerRadius = 6.0f;
    self.tableView.layer.borderWidth = 1.0f;
    self.tableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.view addSubview:self.tableView];
    
    /* Create the fetch request first */
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]
                                    initWithEntityName:@"FriensoEvent"];
    
    NSSortDescriptor *modifiedSort =
    [[NSSortDescriptor alloc] initWithKey:@"eventModified"
                                ascending:NO];
    
    NSSortDescriptor *eventTitleSort =
    [[NSSortDescriptor alloc] initWithKey:@"eventTitle"
                                ascending:NO];
    
    fetchRequest.sortDescriptors = @[modifiedSort, eventTitleSort];
    
    self.frc =
    [[NSFetchedResultsController alloc]
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
}
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
    cell.detailTextLabel.textColor  = [UIColor lightGrayColor];
    cell.textLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:10.0];
    cell.detailTextLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:10.0];
    if ([event.eventCategory isEqualToString:@"calendar"]) {
        cell.imageView.image = [self imageWithBorderFromImage:[UIImage imageNamed:@"cal-ic-24.png"]];
        cell.backgroundColor = [UIColor clearColor];
    }
    return cell;
}
#pragma mark - NSFetchResultsController delegate methods
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    //printf("refreshing frc\n");
    [self.tableView reloadData];
}

#pragma mark - Local Actions
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
-(void) friendsIWatchView {
    
}
-(void) setupMapButton {
    UIButton *button= [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0,
                              self.view.frame.size.width,
                              self.view.frame.size.height*0.4);
    [button addTarget:self
               action:@selector(friensoMapViewCtrlr:)
     forControlEvents:UIControlEventTouchDown];
    button.layer.cornerRadius = 6.0f;
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    //button.backgroundColor = UIColorFromRGB(0x4962D6);
    /*NSMutableArray *imageArray = [NSMutableArray new];
    
    for (int i = 0; i < 2; i ++) {
        [imageArray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"map-btn-%d.png",i]]];
    }
    
    [button setImage:[UIImage imageNamed:@"map-btn-0.png"] forState:UIControlStateNormal];
    [button.imageView setAnimationImages:[imageArray copy]];
    [button.imageView setAnimationDuration:0.5];
    [button.imageView startAnimating];*/
    double rndNbr = ((double)arc4random() / ARC4RANDOM_MAX);
    NSLog(@"%f", rndNbr);
    
    [button setBackgroundImage:[UIImage imageNamed: (rndNbr<.5) ? @"map-btn-0.png" : @"map-btn-1.png"] forState:UIControlStateNormal];
    
    [self.view addSubview:button];
    
    
}
-(void) setupToolBarIcons{
    self.navigationController.toolbarHidden = NO;

    UIColor *violetTulip = [UIColor colorWithRed:155.0/255.0 green:144.0/255.0 blue:182.0/255.0 alpha:1.0];
    
    // Left CoreCircle button
    FriensoCircleButton *coreCircleBtn = [[FriensoCircleButton alloc]
                                          initWithFrame:CGRectMake(0, 0, 27, 27)];
    coreCircleBtn.layer.cornerRadius = 4.0;
    coreCircleBtn.layer.borderWidth =  1.0;
    coreCircleBtn.layer.borderColor = [UIColor blackColor].CGColor;//[UIColor colorWithRed:540./255.0 green:545.0/255.0 blue:255.0/255.0 alpha:0.25].CGColor;
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
    calEventBtn.layer.borderColor = violetTulip.CGColor;
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
    panicButton.layer.borderColor = violetTulip.CGColor;
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
    UIButton *ugcTopLeftBtn = [[UIButton alloc]
                                          initWithFrame:CGRectMake(0, 0, 27, 27)];
    [ugcTopLeftBtn setTitle:@"💬" forState:UIControlStateNormal];
    ugcTopLeftBtn.layer.cornerRadius = 4.0;
    ugcTopLeftBtn.layer.borderWidth =  0.5;
    ugcTopLeftBtn.layer.borderColor = [UIColor grayColor].CGColor;//[UIColor colorWithRed:540./255.0 green:545.0/255.0 blue:255.0/255.0 alpha:0.25].CGColor;
    [ugcTopLeftBtn setEnabled:NO];
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
                cFriends.coreModified  = [NSDate date];
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
	
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"CoreFriendsContactInfoDicKey"] count] == 0) {
        [self syncFromParse];
    } else
        NSLog(@"all loaded already");
    
    
    [self setupNavigationBarImage];
    [self syncCoreFriendsLocation]; //  from parse to coredata
    [self setupEventsTableView];
    [self setupMapButton];
    [self friendsIWatchView];
    
}
- (void)viewDidUnload {
    self.tableView = nil;
    
    [super viewDidUnload];
}
-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self setupToolBarIcons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - CoreData helper methods
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
    const CGFloat margin = 4.0f;
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

/*
 *  http://borkware.com/quickies/one?topic=Graphics
 *  http://stackoverflow.com/questions/10895035/coregraphics-draw-an-image-on-a-white-canvas
 *  http://iwork3.us/2013/09/13/pantone-ny-fashion-week-2014-spring-colors/
 **/
@end
