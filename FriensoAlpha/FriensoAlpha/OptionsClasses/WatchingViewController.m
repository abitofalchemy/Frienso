//
//  WatchingViewController.m
//  Frienso_iOS
//
//  Created by Salvador Aguinaga on 9/14/13.
//  Copyright (c) 2013 Salvador Aguinaga. All rights reserved.
/*
 *  https://github.com/ParsePlatform/TodoTable/tree/master/ParseStarterProject
 *
 *  Parse hints: http://stackoverflow.com/questions/21366065/parse-com-trying-to-get-a-value-from-a-user-class-once-i-have-queried-another-cl
 *
 *  */

#import "WatchingViewController.h"

@interface WatchingViewController ()
@property (nonatomic,retain) NSString * resourcePhoneNumber;
@property (nonatomic,retain) NSMutableArray *thoseIWatchArray;
@end

@implementation WatchingViewController

- (void) setText:(NSString *)paramText{
    self.title = paramText;
}
/**- (id)initWithStyle:(UITableViewStyle)style
 {
 self = [super initWithStyle:style];
 if (self) {
 // This table displays items in the Todo class
 self.parseClassName = @"User";
 self.pullToRefreshEnabled = YES;
 self.paginationEnabled = NO;
 //self.objectsPerPage = 25;
 }
 return self;
 }**/
- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        // Customize the table
        
        // The className to query on
        self.self.parseClassName = @"UserCoreFriends";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"createdAt";
        
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setHidden:NO];
    NSLog(@"[ WatchingViewController ]");
    
    self.thoseIWatchArray = [[NSMutableArray alloc] init];
    
//    self.navigationItem.title = @"Resources";
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
    }
    
    [query includeKey:@"user"];
    [query orderByDescending:@"user"];
    
    return query;
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
    
    // getting the dictionaries
    NSMutableDictionary *parseCoreFriendsDic = [object valueForKey:@"userCoreFriends"];
    PFUser   *friensoUser    = [object valueForKey:@"user"];
    //PFUser *testUser = [testObject objectForKey:@"user"];
//    PFQuery *testQuery = [PFQuery queryWithClassName:@"test"];
//    [testQuery includeKey:@"user"];
//
//    PFObject *testObject = [testQuery getFirstObject];
//    NSLog(@"username: %@",friensoUser.username); // not null
    
    NSString *root_ph_nbr_str = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhone"];
    if ( parseCoreFriendsDic != NULL) {
        self.thoseIWatchArray = [[NSMutableArray alloc] initWithArray:[parseCoreFriendsDic allValues]];
        //NSLog(@"%@", root_ph_nbr_str);
        
        for (NSString *phone_nbr in self.thoseIWatchArray){
            if([[self stripStringOfUnwantedChars:phone_nbr] isEqualToString:root_ph_nbr_str])
            {
                NSLog(@"Phone nbr match in user:%@", friensoUser);
                cell.textLabel.text = friensoUser.username;
            }
        }
    }
    
    
    
//    self.resourcePhoneNumber    = [object objectForKey:@"phonenumber"];
//    cell.detailTextLabel.text   = @"Test";//fullDetails;//[NSString stringWithFormat:@"%@", [object objectForKey:@"detail"]];
    
    //cell.detailTextLabel.numberOfLines = 2;
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
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellText = cell.detailTextLabel.text;
    NSArray *strings = [cellText componentsSeparatedByString:@"|"];
    
    if (![[strings objectAtIndex:1] isEqualToString:@""]) {
        NSLog(@"1");
        NSString *phoneNumber = [@"tel://" stringByAppendingString:strings[1]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
        
    } else if(![[strings objectAtIndex:2] isEqualToString:@""]) {
        NSLog(@"2");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[strings objectAtIndex:2]]];
    } else {
        NSLog(@"nothing");
        return;
    }
}

#pragma mark - Helper Methods
-(NSString *) stripStringOfUnwantedChars:(NSString *)phoneNumber {
    NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];

//    return  [dirtyContactName stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"-()"]];
    return cleanedString;
}

//- (void) evaluateInputString:(NSString *)inputString {
//    // References:
//    // https://developer.apple.com/library/mac/documentation/Foundation/Reference/NSDataDetector_Class/Reference/Reference.html
//    // ^(?:\+?1\s*(?:[.-]\s*)?)?(?:\(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\s*\)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})$
//    //http://www.iossnippet.com/snippets/validation/how-to-validate-a-phone-number-in-objective-c-ios/
//    
//    NSError *error = NULL;
//    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink|NSTextCheckingTypePhoneNumber
//                                                               error:&error];
//    
//    __block NSUInteger count = 0;
//    [detector enumerateMatchesInString:inputString
//                               options:0
//                                 range:NSMakeRange(0, [inputString length])
//                            usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
//                                NSRange matchRange = [match range];
//                                //NSLog(@"input length: %d, input location: %d",matchRange.length,matchRange.location);
//                                if ( matchRange.length >12 || matchRange.length <10){
//                                    [self alertViewPhoneNumberWarning];
//                                    *stop = YES;
//                                }
//                                if ([match resultType] == NSTextCheckingTypePhoneNumber) {
//                                    NSString *phoneNumber = [match phoneNumber];
//                                    NSMutableString *strippedString = [NSMutableString
//                                                                       stringWithCapacity:phoneNumber.length];
//                                    NSScanner *scanner = [NSScanner scannerWithString:phoneNumber];
//                                    NSCharacterSet *numbers = [NSCharacterSet
//                                                               characterSetWithCharactersInString:@"0123456789"];
//                                    while ([scanner isAtEnd] == NO) {
//                                        NSString *buffer;
//                                        if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
//                                            [strippedString appendString:buffer];
//                                            
//                                        } else {
//                                            [scanner setScanLocation:([scanner scanLocation] + 1)];
//                                        }
//                                    }
//                                    if (strippedString.length <10){
//                                        [self alertViewPhoneNumberWarning];
//                                        *stop = YES;
//                                    }
//                                    // Save phone # to NSUserDefaults
//                                    NSUserDefaults *userInLocal = [NSUserDefaults standardUserDefaults];
//                                    [userInLocal setObject:strippedString forKey:@"userPhone"];
//                                    [userInLocal synchronize];
//                                    
//                                    // update the working array
//                                    [userProfileArray replaceObjectAtIndex:2 withObject:strippedString];
//                                    [self.tableView reloadData];
//                                }
//                                if (++count >= 1) *stop = YES;
//                            }];
//    
//    NSRange inputRange = NSMakeRange(0, [inputString length]);
//    NSArray *matches = [detector matchesInString:inputString options:0 range:inputRange];
//    
//    /*for (NSTextCheckingResult *match in matches) {
//     NSRange matchRange = [match range];
//     if ([match resultType] == NSTextCheckingTypeLink) {
//     NSURL *url = [match URL];
//     } else if ([match resultType] == NSTextCheckingTypePhoneNumber) {
//     NSString *phoneNumber = [match phoneNumber];
//     NSLog(@"%@",phoneNumber);
//     }
//     }*/
//    
//    // no match at all
//    if ([matches count] == 0) {
//        //return NO;
//        return;
//    }
//    
//    // found match but we need to check if it matched the whole string
//    NSTextCheckingResult *result = (NSTextCheckingResult *)[matches objectAtIndex:0];
//    
//    if ([result resultType] == NSTextCheckingTypePhoneNumber && result.range.location == inputRange.location && result.range.length == inputRange.length) {
//        // it matched the whole string
//        //return YES;
//        NSLog(@"input string is a complete phone #");
//    }
//    else {
//        // it only matched partial string
//        //return NO;
//        NSLog(@"input string is not a phone #");
//    }
//}

@end
