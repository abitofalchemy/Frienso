//
//  FriensoOptionsTVC.m
//  FriensoAlpha
//
//  Created by Sal Aguinaga on 3/1/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "FriensoOptionsTVC.h"
#import "ProfileViewController.h"
#import "SettingsViewController.h"
#import "tstWatchingViewController.h"
#import "FriensoResourcesTVC.h"


@interface FriensoOptionsTVC ()
@property (nonatomic,retain) NSMutableArray *optionsArray;
@end

@implementation FriensoOptionsTVC

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
    self.optionsArray = [[NSMutableArray alloc] initWithArray:@[@"Profile",@"Watching", @"Resources",@"Settings",@"About"]];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.optionsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    if ( indexPath.section == 0) {
        cell.textLabel.text = [self.optionsArray objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:18.0];
        switch (indexPath.row) {
            case 0:
                cell.imageView.image = [UIImage imageNamed:@"profile-24.png"];
                break;
            case 1:
                cell.imageView.image = [UIImage imageNamed:@"umbrella-24.png"];
                break;
            case 2:
                cell.imageView.image = [UIImage imageNamed:@"lighthouse-24.png"];
                break;
            case 3:
                cell.imageView.image = [UIImage imageNamed:@"settings-24.png"];
                break;
            case 4:
                cell.imageView.image = [UIImage imageNamed:@"about-24.png"];
                break;
            default:
                break;
        }
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:{
            NSLog(@"%@", [tableView cellForRowAtIndexPath:indexPath].textLabel.text);
            
            ProfileViewController *detailViewController = [[ProfileViewController alloc] initWithNibName:nil bundle:nil];
            
            // Pass the selected object to the new view controller.
            [detailViewController setText:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
//            NSDictionary *dictTemp = [arrItems objectAtIndex:indexPath.row];
//            detailViewController.strDesc = [dictTemp objectForKey:@"Desc"];
        
            // Push the view controller.
            [self.navigationController pushViewController:detailViewController
                                                 animated:YES];
            //[self presentViewController:detailViewController animated:YES completion:nil];
//            [self.view addSubview:detailViewController];
            break;
        }
        case 1:{
            NSLog(@"%@", [tableView cellForRowAtIndexPath:indexPath].textLabel.text);
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"  bundle:nil];
            tstWatchingViewController  *wtvc = (tstWatchingViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"friensoWatching"];
            [wtvc setText:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
            [self.navigationController pushViewController:wtvc animated:YES];
            break;
        }
        case 2:{
            NSLog(@"%@", [tableView cellForRowAtIndexPath:indexPath].textLabel.text);
            /*FriensoResourcesTVC *detailViewController = [[FriensoResourcesTVC alloc] initWithNibName:nil
                                                                                              bundle:nil];
            // Pass the selected object to the new view controller.
            //[detailViewController setText:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
            // Push the view controller.
            [self.navigationController pushViewController:detailViewController
                                                 animated:YES];
            */
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"  bundle:nil];
            FriensoResourcesTVC  *rtvc = (FriensoResourcesTVC*)[mainStoryboard instantiateViewControllerWithIdentifier:@"friensoResources"];
            [self.navigationController pushViewController:rtvc animated:YES];
            break;
        }
        case 3:{
            NSLog(@"%@", [tableView cellForRowAtIndexPath:indexPath].textLabel.text);
            SettingsViewController *detailViewController = [[SettingsViewController alloc] initWithNibName:nil bundle:nil];
            [detailViewController setText:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
            [self.navigationController pushViewController:detailViewController
                                                 animated:YES];
            break;
        }
        case 4:{
            NSLog(@"%@", [tableView cellForRowAtIndexPath:indexPath].textLabel.text);
            ProfileViewController *detailViewController = [[ProfileViewController alloc] initWithNibName:nil bundle:nil];
            [detailViewController setText:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
            [self.navigationController pushViewController:detailViewController
                                                 animated:YES];
            break;
        }
        
        default:
            break;
    }
        
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
