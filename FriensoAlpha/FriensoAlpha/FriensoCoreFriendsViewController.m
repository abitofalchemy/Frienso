//
//  FriensoCoreFriendsViewController.m
//  FriensoAlpha
//
//  Created by Sal Aguinaga on 3/1/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "FriensoCoreFriendsViewController.h"
#import "FriensoAppDelegate.h"

@interface FriensoCoreFriendsViewController ()
{
    NSMutableArray *coreFriendsArray;
}
@property (nonatomic,retain) NSMutableArray *coreFriendsArray;
@property (nonatomic, strong) NSFetchedResultsController *frc;
@end

@implementation FriensoCoreFriendsViewController
@synthesize coreFriendsArray = _coreFriendsArray;

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

    NSDictionary *retrievedCoreFriendsDictionary = [[NSUserDefaults standardUserDefaults]
                                                    dictionaryForKey:@"CoreFriendsContactInfoDicKey"]; // immutable
    if ( retrievedCoreFriendsDictionary != NULL) {
        NSEnumerator *enumerator = [retrievedCoreFriendsDictionary keyEnumerator];
        coreFriendsArray = [[NSMutableArray alloc] initWithArray:[enumerator allObjects]];
        
        // Handle if the array has less than 3 objects
        switch ([coreFriendsArray count]) {
            case 0:
                coreFriendsArray = [[NSMutableArray alloc] initWithObjects:@"CoreFriend 1",
                                    @"CoreFriend 2", @"CoreFriend 3",nil];
                break;
            case 1:
                [coreFriendsArray addObject:@"CoreFriend X"];
                [coreFriendsArray addObject:@"CoreFriend Y"];
                break;
            case 2:
                [coreFriendsArray addObject:@"CoreFriend Z"];
                break;
            default:
                //coreFriendsArray = [[NSMutableArray alloc] initWithObjects:@"CoreFriend 1",
                //                    @"CoreFriend 2", @"CoreFriend 3",nil];
                break;
                
        }
    } else {
        coreFriendsArray = [[NSMutableArray alloc] initWithObjects:@"Core Friend 1",@"Core Friend 2",@"Core Friend 3", nil];
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [coreFriendsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    NSString *friendName = [coreFriendsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = friendName;
    
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

@end
