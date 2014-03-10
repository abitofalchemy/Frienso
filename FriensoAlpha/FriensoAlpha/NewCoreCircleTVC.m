//
//  NewCoreCircleTVC.m
//  FriensoAlpha
//
//  Created by Sal Aguinaga on 3/10/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "NewCoreCircleTVC.h"
#import <CoreData/NSFetchedResultsController.h>
#import "FriensoViewController.h"

static NSString *eventCell = @"coreFriendCell";


@interface NewCoreCircleTVC ()
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *frc;
@property (nonatomic, strong) NSMutableArray *coreCircleContacts;
@property (nonatomic, strong) NSMutableArray *coreCircleOfFriends;
@end

@implementation NewCoreCircleTVC

-(void) updateLocalArray:(NSArray *)localCoreFriendsArray
{
    NSLog(@"updateLocalArray:");
    NSDictionary *retrievedCoreFriendsDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"CoreFriendsContactInfoDicKey"]; // immutable
    if ( retrievedCoreFriendsDictionary != NULL) {
        NSEnumerator *enumerator = [retrievedCoreFriendsDictionary keyEnumerator];
        self.coreCircleOfFriends = [[NSMutableArray alloc] initWithArray:[enumerator allObjects]];
        
        // Handle if the array has less than 3 objects
        switch ([self.coreCircleOfFriends count]) {
            case 0:
                self.coreCircleOfFriends = [[NSMutableArray alloc] initWithObjects:@"CoreFriend 1",
                                       @"CoreFriend 2", @"CoreFriend 3",nil];
                break;
            case 1:
                [self.coreCircleOfFriends addObject:@"CoreFriend X"];
                [self.coreCircleOfFriends addObject:@"CoreFriend Y"];
                break;
            case 2:
                [self.coreCircleOfFriends addObject:@"CoreFriend Z"];
                break;
            default:
                break;
                
        }
    } else {
        self.coreCircleOfFriends = [[NSMutableArray alloc] initWithObjects:@"Core Friend 1",@"Core Friend 2",@"Core Friend 3", nil];
    }
}

#pragma mark - Navigation bar actions
- (void) save {
    NSLog(@"[ Cancel Core Circle of Friends ]");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) cancel {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"coreCircleSet"])
        [self.navigationController popViewControllerAnimated:YES];
    else {
        // set default values
        NSMutableDictionary *coreCircleDic = [[NSMutableDictionary  alloc] init];
        NSInteger i = 0;
        for (NSString *circleContactName in self.coreCircleOfFriends){
            [coreCircleDic setValue:[self.coreCircleContacts objectAtIndex:i++] forKey:circleContactName];
        }
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:coreCircleDic forKey:@"CoreFriendsContactInfoDicKey"];
        [userDefaults synchronize];
        
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"  bundle:nil];
    FriensoViewController  *nxtVC = (FriensoViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"dashboardVC"];
    [self.navigationController pushViewController:nxtVC animated:YES];
        
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Setup Core Circle";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    
    //
    [self updateLocalArray:self.coreCircleOfFriends];
    self.coreCircleContacts = [[NSMutableArray alloc] initWithObjects:@"0",@"0",@"0",nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
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
