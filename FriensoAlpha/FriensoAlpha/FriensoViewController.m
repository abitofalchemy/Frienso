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
#import <QuartzCore/QuartzCore.h>
#import "FriensoAppDelegate.h"
#import "FriensoEvent.h"
#import "CoreFriends.h"

static NSString *eventCell = @"eventCell";


@interface FriensoViewController ()
{
    NSMutableArray *coreFriendsArray;
}
@property (nonatomic,retain) NSMutableArray *coreFriendsArray;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *frc;

-(void)viewMenuOptions:(UIButton *)theButton;
-(void)viewCoreCircle :(UIButton *)theButton;

@end

@implementation FriensoViewController
@synthesize coreFriendsArray = _coreFriendsArray;

-(void)viewMenuOptions:(UIButton *)theButton {
    [self animateThisButton:theButton];
    [self performSegueWithIdentifier:@"showMenuOptions" sender:self];
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
-(void) setupEventsTableView {
    self.tableView = [[UITableView alloc] init];
    [self.tableView setFrame:CGRectMake(0, 0, self.view.bounds.size.width,
                                        self.view.bounds.size.height*0.70)];
    
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    [self.view addSubview:self.tableView];
    //[self.tableView setCenter:self.view.center];
    
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
        NSLog(@"Successfully fetched.");
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
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.textColor  = [UIColor lightGrayColor];

    return cell;
}
#pragma mark - NSFetchResultsController delegate methods
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    printf("refreshing frc\n");
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

-(void) setupNavigationBarImage{
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor blackColor], NSForegroundColorAttributeName,
      [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:16.0], NSFontAttributeName,nil]];
    self.navigationItem.title = @"FRIENSO";
    
    // Right Options Button
    FriensoOptionsButton *button = [[FriensoOptionsButton alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
    button.layer.cornerRadius = 4.0;
    button.layer.borderWidth =  1.0;
    button.layer.borderColor = [UIColor blackColor].CGColor;//[UIColor colorWithRed:540./255.0 green:545.0/255.0 blue:255.0/255.0 alpha:0.25].CGColor;
    [button addTarget:self action:@selector(viewMenuOptions:)
     forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton=[[UIBarButtonItem alloc] init];
    [barButton setCustomView:button];
    self.navigationItem.rightBarButtonItem=barButton;
    
    // Left CoreCircle button
    FriensoCircleButton *coreCircleBtn = [[FriensoCircleButton alloc]
                                          initWithFrame:CGRectMake(0, 0, 27, 27)];
    coreCircleBtn.layer.cornerRadius = 4.0;
    coreCircleBtn.layer.borderWidth =  1.0;
    coreCircleBtn.layer.borderColor = [UIColor blackColor].CGColor;//[UIColor colorWithRed:540./255.0 green:545.0/255.0 blue:255.0/255.0 alpha:0.25].CGColor;
    [coreCircleBtn addTarget:self action:@selector(viewCoreCircle:)
            forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barLeftButton=[[UIBarButtonItem alloc] init];
    [barLeftButton setCustomView:coreCircleBtn];
    self.navigationItem.leftBarButtonItem=barLeftButton;
    
    
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
                                                         NSLog(@"%@",[object valueForKey:@"userCoreFriends"]);
                                                         parseCoreFriendsDic = [object valueForKey:@"userCoreFriends"];
                                                         
                                                     }
                                                     if ( parseCoreFriendsDic != NULL) {
                                                         // Save core friends dictionary to NSUserDefaults
                                                         [self saveCFDictionaryToNSUserDefaults:parseCoreFriendsDic];
                                                         coreFriendsArray = [[NSMutableArray alloc] initWithArray:[parseCoreFriendsDic allKeys]];
                                                         
                                                         
                                                     }
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
    //NSLog(@"%@",friendsDic);
    
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
                
                NSLog(@"%@",[coreCircle objectAtIndex:i] );
                NSError *savingError = nil;
                
                if ([[self managedObjectContext] save:&savingError]){
                    NSLog(@"Successfully saved contact to CoreCircle.");
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
    printf("[ Dashboard: FriensoViewController]\n");
    self.navigationController.navigationBarHidden = NO;
	
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"CoreFriendsContactInfoDicKey"] count] == 0) {
        [self syncFromParse];
    } else
        NSLog(@" all loaded already");
    
    
    [self setupNavigationBarImage];
    
    [self setupEventsTableView];

}
- (void)viewDidUnload {
    self.tableView = nil;
    
    [super viewDidUnload];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
