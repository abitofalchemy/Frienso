//
//  tstWatchingViewController.m
//  FriensoAlpha
//
//  Created by Sal Aguinaga on 3/6/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "tstWatchingViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:0.8]


@interface tstWatchingViewController ()
@property (nonatomic,strong) NSMutableArray *thoseIWatchArray;

@end

@implementation tstWatchingViewController

- (void) setText:(NSString *)paramText{
    self.title = paramText;
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
    self.thoseIWatchArray = [[NSMutableArray alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    PFQuery *query = [PFQuery queryWithClassName:@"UserCoreFriends"];
    [query includeKey:@"user"];
    [query orderByDescending:@"createdAt"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
            for (PFObject *object in objects) {
                NSMutableDictionary *parseCoreFriendsDic = [object valueForKey:@"userCoreFriends"];
                PFUser   *friensoUser    = [object valueForKey:@"user"];
                NSString *root_ph_nbr_str = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhone"];
                if ( parseCoreFriendsDic != NULL) {
//                    self.thoseIWatchArray = [[NSMutableArray alloc] initWithArray:[parseCoreFriendsDic allValues]];
                    
                    for (NSString *phone_nbr in [parseCoreFriendsDic allValues]){
                        if([[self stripStringOfUnwantedChars:phone_nbr] isEqualToString:root_ph_nbr_str])
                        {
                            NSLog(@"[%@][%@][%@]",friensoUser.username,root_ph_nbr_str, phone_nbr);
                            [self.thoseIWatchArray addObject:friensoUser.username];
                            //NSLog(@"#:%@", self.thoseIWatchArray);
                            //cell.textLabel.text = friensoUser.username;
                        }
                    }
                }
            }//ends for
            printf("[ filtered those I am watching ]");
            [self.tableView reloadData];

        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [self.thoseIWatchArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    //NSLog(@"%@",[self.thoseIWatchArray objectAtIndex:indexPath.row]);
    
    cell.textLabel.text = [self.thoseIWatchArray objectAtIndex:indexPath.row];
    cell.backgroundColor = UIColorFromRGB(0xF6E4CC);
    [cell.imageView setImage:[UIImage imageNamed:@"Profile-256.png"]];
    
    return cell;
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
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */
#pragma mark - Helper Methods
-(NSString *) stripStringOfUnwantedChars:(NSString *)phoneNumber {
    NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    
    //    return  [dirtyContactName stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"-()"]];
    return cleanedString;
}

@end
