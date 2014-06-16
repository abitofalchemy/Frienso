//
//  FriensoOptionsTVC.m
//  FriensoAlpha
//
//  Created by Sal Aguinaga on 3/1/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "FriensoOptionsTVC.h"
#import <QuartzCore/QuartzCore.h>
#import "UserProfileViewController.h"
#import "SettingsViewController.h"
#import "tstWatchingViewController.h"
#import "FriensoResourcesTVC.h"
#import "AboutFriensoViewController.h"
#import "SearchViewController.h"
#import "FRStringImage.h"
#import "FriensoOptionsButton.h"


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
    self.title = @"View Options";
    
    for (id subview in [self.navigationController.toolbar subviews]){
        if ( [subview isKindOfClass:[FriensoOptionsButton class]] )
        {
            [subview setHidden:YES];
        }
    }
    
    self.optionsArray = [[NSMutableArray alloc] initWithArray:@[@"Profile",/*@"Watching",*/ @"Resources",@"Settings",@"About"/*,@"Map",@"Event"*/]];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
//- (void) viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:YES];
//    
//    for (id subview in [self.navigationController.toolbar subviews]){
//        if ( [subview isKindOfClass:[FriensoOptionsButton class]] )
//        {
//            [subview setHidden:NO];
//        }
//    }
//}
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
//                cell.imageView.image = [UIImage imageNamed:@"umbrella-24.png"];
//                break;
//            case 2:
                cell.imageView.image = [UIImage imageNamed:@"lighthouse-24.png"];
                break;
            case 2:
                cell.imageView.image = [UIImage imageNamed:@"settings-24.png"];
                break;
            case 3:
                cell.imageView.image = [UIImage imageNamed:@"about-24.png"];
                break;
            /*case 4:
                cell.imageView.image = [self imageWithString:@"🌐" font:[UIFont systemFontOfSize:[UIFont systemFontSize]] size:CGSizeMake(24, 24)];
                break;
            case 5:
                cell.imageView.image = [[FRStringImage alloc] calendarDrawRectImage:CGSizeMake(24,24)];
                break;*/
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
            UserProfileViewController *detailViewController = [[UserProfileViewController alloc] initWithNibName:nil bundle:nil];
            
            // Pass the selected object to the new view controller.
            [detailViewController setText:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
//            NSDictionary *dictTemp = [arrItems objectAtIndex:indexPath.row];
//            detailViewController.strDesc = [dictTemp objectForKey:@"Desc"];
        
            // Push the view controller.
            [self.navigationController pushViewController:detailViewController
                                                 animated:YES];
            break;
        }
        /*case 1:{
            //NSLog(@"%@", [tableView cellForRowAtIndexPath:indexPath].textLabel.text);
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"  bundle:nil];
            tstWatchingViewController  *wtvc = (tstWatchingViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"friensoWatching"];
            [wtvc setText:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
            [self.navigationController pushViewController:wtvc animated:YES];
            break;
        }*/
        case 1:     {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"  bundle:nil];
            FriensoResourcesTVC  *rtvc = (FriensoResourcesTVC*)[mainStoryboard instantiateViewControllerWithIdentifier:@"friensoResources"];
            [self.navigationController pushViewController:rtvc animated:YES];
            break;  }
        case 2:{
            //NSLog(@"%@", [tableView cellForRowAtIndexPath:indexPath].textLabel.text);
            SettingsViewController *detailViewController = [[SettingsViewController alloc] initWithNibName:nil bundle:nil];
            [detailViewController setText:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
            [self.navigationController pushViewController:detailViewController animated:YES];
            break;
        }
        case 3:{
            //NSLog(@"%@", [tableView cellForRowAtIndexPath:indexPath].textLabel.text);
            AboutFriensoViewController *detailViewController = [[AboutFriensoViewController alloc] initWithNibName:nil bundle:nil];
            [detailViewController setText:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
            [self.navigationController pushViewController:detailViewController
                                                 animated:YES];
            break;
        }
        /*case 4: {
            [self performSegueWithIdentifier:@"friensoMap" sender:self];
            break;
        }*/
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
- (UIImage *)imageWithString:(NSString *)string // What we want an image of.
                        font:(UIFont *)font     // The font we'd like it in.
                        size:(CGSize)size       // Size of the desired image.
{
    // Create a context to render into.
    UIGraphicsBeginImageContext(size);
    
    // Work out what size of font will give us a rendering of the string
    // that will fit in an image of the desired size.
    
    // We do this by measuring the string at the given font size and working
    // out the ratio scale to it by to get the desired size of image.
    NSDictionary *attributes = @{NSFontAttributeName:font};
    // Measure the string size.
    CGSize stringSize = [string sizeWithAttributes:attributes];
    
    // Work out what it should be scaled by to get the desired size.
    CGFloat xRatio = size.width / stringSize.width;
    CGFloat yRatio = size.height / stringSize.height;
    CGFloat ratio = MIN(xRatio, yRatio);
    
    // Work out the point size that'll give us the desired image size, and
    // create a UIFont that size.
    CGFloat oldFontSize = font.pointSize;
    CGFloat newFontSize = floor(oldFontSize * ratio);
    ratio = newFontSize / oldFontSize;
    font = [font fontWithSize:newFontSize];
    
    // What size is the string with this new font?
    stringSize = [string sizeWithAttributes:attributes];
    
    // Work out where the origin of the drawn string should be to get it in
    // the centre of the image.
    CGPoint textOrigin = CGPointMake((size.width - stringSize.width) / 2,
                                     (size.height - stringSize.height) / 2);
    
    // Draw the string into out image!
    [string drawAtPoint:textOrigin withAttributes:attributes];
    
    // We're done!  Grab the image and return it!
    // (Don't forget to end the image context first though!)
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return retImage;
}
@end
