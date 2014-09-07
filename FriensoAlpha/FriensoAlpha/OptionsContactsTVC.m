//
//  OptionsContactsTVC.m
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 8/27/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "OptionsContactsTVC.h"
#import "FriensoAppDelegate.h"
#import "CoreFriends.h"
#import "FRCoreDataParse.h"

@interface OptionsContactsTVC ()
@property (nonatomic,retain) NSMutableArray *optionsArray;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSFetchedResultsController *frc;
@property (nonatomic,strong) NSDictionary *friendToContactDic;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editFriensoContacts;

- (IBAction)editFriensoContactsAction:(id)sender;
//- (UIImage *)imageWithString:(NSString *)string // What we want an image of.
//                        font:(UIFont *)font     // The font we'd like it in.
//                        size:(CGSize)size;       // Size of the desired image.

@end

@implementation OptionsContactsTVC
- (NSManagedObjectContext *) managedObjectContext{
    
    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
    
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:16.0], NSFontAttributeName,nil]];
    self.navigationItem.title = @"Contacts";
    
    
    self.optionsArray = [[NSMutableArray alloc] init];
    NSDictionary *cfDic = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"CoreFriendsContactInfoDicKey"];
    for (id key in cfDic) {
        [self.optionsArray addObject:[cfDic objectForKey:key]];
        NSLog(@"%@",[cfDic objectForKey:key]);
    }
//    WithArray:@[@"School",/*@"Watching",*/
//                                                                @"Resources",
//                                                                @"Settings",
//                                                                @"About"/*,@"Map",@"Event"*/]];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

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
        if (DBG) NSLog(@"CoreCircle fetched with nbr of categories:%lu",(unsigned long)[[self.frc sections] count]);
    } else {
        if (DBG) NSLog(@"Failed to fetch.");
    }

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - VC Actions
- (void) coreFriendsAction:(id) sender {
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:nil
                                                                            action:nil];
    
    [self performSegueWithIdentifier:@"segueToCoreFriends" sender:self];
    
}
#pragma mark - IBActions
- (IBAction)editFriensoContactsAction:(id)sender {
    [self performSelector:@selector(coreFriendsAction:) withObject:self afterDelay:0.0f];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.optionsArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
