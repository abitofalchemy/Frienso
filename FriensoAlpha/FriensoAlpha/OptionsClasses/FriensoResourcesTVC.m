//
//  FriensoResourcesTVC.m
//  Frienso_iOS
//
//  Created by Salvador Aguinaga on 9/14/13.
//  Copyright (c) 2013 Salvador Aguinaga. All rights reserved.
/*  
 *  https://github.com/ParsePlatform/TodoTable/tree/master/ParseStarterProject
 *  https://www.parse.com/questions/core-data-with-nsincrementalstore-or-plain-sync
 *
 *  */

#import "FriensoResourcesTVC.h"
#import "FriensoAppDelegate.h"
#import "FriensoEvent.h"
#import "CoreFriends.h"

@interface FriensoResourcesTVC ()
@property (nonatomic,retain) NSString * resourcePhoneNumber;
@end

@implementation FriensoResourcesTVC

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        // Customize the table
        
        // The className to query on
        self.self.parseClassName = @"Resources";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"resource";
        
        // Uncomment the following line to specify the key of a PFFile on the PFObject to display in the imageView of the default cell style
        // self.imageKey = @"image";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 25;
    }
    return self;
}
- (void) setText:(NSString *)paramText{
    self.title = paramText;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden:NO];
    NSLog(@"[ FriensoResourcesTVC ]");
    
    self.navigationItem.title = @"Resources";
    self.resourcePhoneNumber =@"";
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    
//    // Return the number of sections.
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 1;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}
//
///*
//// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}
//*/
//
///*
//// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }   
//    else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
//}
//*/
//
///*
//// Override to support rearranging the table view.
//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
//{
//}
//*/
//
///*
//// Override to support conditional rearranging of the table view.
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the item to be re-orderable.
//    return YES;
//}
//*/
//
//#pragma mark - Table view delegate
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Navigation logic may go here. Create and push another view controller.
//    /*
//     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
//     // ...
//     // Pass the selected object to the new view controller.
//     [self.navigationController pushViewController:detailViewController animated:YES];
//     */
//}

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    // If no objects are loaded in memory, we look to the cache
    // first to fill the table and then subsequently do a query
    // against the network.
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    } //NSLog(@"%d", [self.objects count]);
    
    [query orderByDescending:@"createdAt"];
    
    return query;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0)
        return [tableView rowHeight]*3.0f;
    else
        return [tableView rowHeight]*1.5f;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject    *)object {
    static NSString *CellIdentifier = @"resourceCell";
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell // to show todo item with a priority at the bottom
    NSString *fullDetails = [NSString stringWithFormat:@"%@%@%@",[object objectForKey:@"detail"],
                             ([object objectForKey:@"phonenumber"]) ? [NSString stringWithFormat:@"|%@",[object objectForKey:@"phonenumber"]] : @"|",
                             ([object objectForKey:@"ResourceLink"]) ? [NSString stringWithFormat:@"|%@",[object objectForKey:@"ResourceLink"]]: @"|"];
    
    cell.textLabel.text         = [object objectForKey:@"resource"];    // title
    cell.textLabel.font         = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:14.0];
    self.resourcePhoneNumber    = [object objectForKey:@"phonenumber"];
    cell.detailTextLabel.text   = fullDetails;
    cell.detailTextLabel.font   = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:12.0];
    if (indexPath.row == 0 )
    {
        [cell.textLabel setNumberOfLines:3];
        [cell.textLabel adjustsFontSizeToFitWidth];
        [cell.detailTextLabel setNumberOfLines:4];
        if ( [[object objectForKey:@"categoryType"] isEqualToString:@"general"])
        {// image
            NSURL *imageURL = [NSURL URLWithString:[object objectForKey:@"rImage"]];
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            UIImage *img = [UIImage imageWithData:imageData];
            //NSLog(@"img: %2.f, %2.f", img.size.width, img.size.height);
            //NSLog(@"cell:%2.f, %2.f", cell.frame.size.width, cell.frame.size.height);
            CGFloat ratio = (cell.frame.size.width*0.4*cell.frame.size.height)/cell.frame.size.height;
            cell.imageView.image = [self scaleImage:img
                                             toSize:CGSizeMake(cell.frame.size.width*0.4,ratio)];//[self imageWithBorderFromImage:img];
        }
    } else if ([[object objectForKey:@"categoryType"] isEqualToString:@"inst,contact"]) {
        //NSLog ( @"inst.contact,%@", object.objectId);
        if ( [self isResourceCached:object.objectId forCell:cell] ){
            
            UIButton *label = [UIButton buttonWithType:UIButtonTypeCustom];
            [label setTitle:@"📥" forState:UIControlStateNormal];
            [label sizeToFit];
            [label addTarget:self action:@selector(checkButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
            
            cell.accessoryType = UITableViewCellAccessoryDetailButton;
            cell.accessoryView = label;
            [cell.detailTextLabel setNumberOfLines:2];
            PFFile *instImageFile = [object objectForKey:@"image"];
            [instImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:imageData];
                    cell.imageView.image = (imageData) ? image : [UIImage imageNamed:@"und_logo29.png"];
                } else NSLog(@"Error: %@", [error localizedDescription]);
            }];

        } else {
            NSLog(@"Not Unique!");
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.textLabel.textColor = [UIColor grayColor];
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
            
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellText = cell.textLabel.text;
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:cellText
                              message:cell.detailTextLabel.text
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
    
    
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"-- Save resource");
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    /*
    NSArray *strings = [cellText componentsSeparatedByString:@"|"];
    
    if (![[strings objectAtIndex:1] isEqualToString:@""]) {
        
        NSString *phoneNumber = [@"tel://" stringByAppendingString:strings[1]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    
    } else if(![[strings objectAtIndex:2] isEqualToString:@""]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[strings objectAtIndex:2]]];
    } else {
        NSLog(@"nothing");
        return;
    }
    */
    
    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    // First check to see if the objectId already exists
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"CoreFriends"
                                                         inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    PFObject *pfObj = [self.objects objectAtIndex:indexPath.row];
    [request setPredicate:[NSPredicate predicateWithFormat:@"coreObjId like %@",pfObj.objectId]];//[pfObj objectForKey:@"resObjId"]]];
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
        CoreFriends  *coreFResource = [NSEntityDescription insertNewObjectForEntityForName:@"CoreFriends"
                                                                        inManagedObjectContext:managedObjectContext];
        
        if (coreFResource != nil)
        {
            coreFResource.coreTitle = [pfObj objectForKey:@"resource"];
            coreFResource.corePhone = [pfObj objectForKey:@"phonenumber"];
            coreFResource.coreObjId     = pfObj.objectId;
            coreFResource.coreModified  = [NSDate date];
            coreFResource.coreCreated   = [NSDate date];
            coreFResource.coreType      = @"Resource";
            
            
            NSError *savingError = nil;
            if([managedObjectContext save:&savingError]) {
                NSLog(@"Successfully cached the resource");
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else
                NSLog(@"Failed to save the context. Error = %@", savingError);
            
            
        } else {
            NSLog(@"Failed to create a new event.");
        }
    } else NSLog(@"! Parse event is not unique");
}
#pragma mark - Image Actions
- (UIImage*) scaleImage:(UIImage*)image toSize:(CGSize)newSize {
    CGSize scaledSize = newSize;
    float scaleFactor = 1.0;
    if( image.size.width > image.size.height ) {
        scaleFactor = image.size.width / image.size.height;
        scaledSize.width = newSize.width;
        scaledSize.height = newSize.height / scaleFactor;
    }
    else {
        scaleFactor = image.size.height / image.size.width;
        scaledSize.height = newSize.height;
        scaledSize.width = newSize.width / scaleFactor;
    }
    
    UIGraphicsBeginImageContextWithOptions( scaledSize, NO, 0.0 );
    CGRect scaledImageRect = CGRectMake( 0.0, 0.0, scaledSize.width, scaledSize.height );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}
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
-(BOOL) isResourceCached:(NSString *)objectId forCell:(UITableViewCell *)currentCell{
    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    // First check to see if the objectId already exists
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"CoreFriends"
                                                         inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPredicate:[NSPredicate predicateWithFormat:@"coreObjId like %@",objectId]];//[pfObj objectForKey:@"resObjId"]]];
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
//        NSLog(@"Not unique %d", [items count]);
////        NSLog(@"Index: %@", [self.t indexPathForCell:currentCell]);
////        [self.tableView beginUpdates];
//        currentCell.accessoryView = nil;
//        currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
//        NSIndexPath *index = [self.tableView indexPathForCell:currentCell];
//        [self.tableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
//        [self.tableView endUpdates];
    } else {
        NSLog(@"Unique");
    }
    return unique;
}
#pragma mark - Button Selectors
- (void)checkButtonTapped:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
    
    if (indexPath != nil)
    {
        [self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}
@end
/** References
 *
 *  http://stackoverflow.com/questions/869421/using-a-custom-image-for-a-uitableviewcells-accessoryview-and-having-it-respond
 *
 *
 ****/