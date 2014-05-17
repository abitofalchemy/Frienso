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
//@property (nonatomic,strong) NSMutableArray *watchingPhoneArray;
@property (nonatomic,strong) UIActivityIndicatorView *loadingView;
@property (nonatomic,strong) NSDictionary *friendToContactDic;
@property (nonatomic,strong) NSMutableDictionary *watchingOverDic;

@end

@implementation tstWatchingViewController

- (void) setText:(NSString *)paramText{
    self.title = paramText;
}
// -------------------------------------------------------------------------------
//	showSMSPicker:
//  IBAction for the Compose SMS button.
// -------------------------------------------------------------------------------
- (void)showSMSPicker:(id)sender
{
    // You must check that the current device can send SMS messages before you
    // attempt to create an instance of MFMessageComposeViewController.  If the
    // device can not send SMS messages,
    // [[MFMessageComposeViewController alloc] init] will return nil.  Your app
    // will crash when it calls -presentViewController:animated:completion: with
    // a nil view controller.
    if ([MFMessageComposeViewController canSendText])
        // The device can send email.
    {
        [self displaySMSComposerSheet];
    }
    else
        // The device can not send email.
    {
//        self.feedbackMsg.hidden = NO;
//		self.feedbackMsg.text = @"Device not configured to send SMS.";
        NSLog(@"Device not configured to send SMS.");
    }
}
// -------------------------------------------------------------------------------
//	displayMailComposerSheet
//  Displays an SMS composition interface inside the application.
// -------------------------------------------------------------------------------
- (void)displaySMSComposerSheet
{
	MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
	picker.messageComposeDelegate = self;
	
    // You can specify one or more preconfigured recipients.  The user has
    // the option to remove or add recipients from the message composer view
    // controller.
    
    // You can specify the initial message text that will appear in the message
    // composer view controller.
    picker.body = @"Are you Okay?";
    /* picker.recipients = @[@"Phone number here"]; */
    picker.recipients = @[[NSString stringWithFormat:@"%@",[self.friendToContactDic allValues]]];
    
    
	[self presentViewController:picker animated:YES completion:NULL];
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
    
    self.watchingOverDic = [[NSMutableDictionary alloc] init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    PFQuery *query = [PFQuery queryWithClassName:@"UserCoreFriends"];
    [query includeKey:@"user"];
    [query orderByDescending:@"createdAt"];
    
    // Show progress indicator to tell user to wait a bit
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.loadingView setColor:UIColorFromRGB(0xf47d44)];
    [self.view addSubview:self.loadingView];
    [self.loadingView startAnimating];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            for (PFObject *object in objects) {
                NSMutableDictionary *parseCoreFriendsDic = [object valueForKey:@"userCoreFriends"];
                PFUser   *friensoUser    = [object valueForKey:@"user"];
                //NSLog(@"users safety network: %@", friensoUser.username);
                NSString *rootPhNbrStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhone"];
                if ( parseCoreFriendsDic != NULL) {
                    
                    for (NSString *phone_nbr in [parseCoreFriendsDic allValues]){
                        if([[self stripStringOfUnwantedChars:phone_nbr] isEqualToString:rootPhNbrStr])
                        {
                            NSLog(@"with connection to me: %@]",friensoUser.username);
                            [self.thoseIWatchArray addObject:friensoUser.username];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self fetchPhoneNbrForThoseIWatch:friensoUser];
                            });

                            
                            //[self.watchingPhoneArray addObject:];
                            //NSLog(@"#:%@", self.watchingPhoneArray);
                            //cell.textLabel.text = friensoUser.username;
                        }
                    }
                }
            }//ends for
            printf("[ filtered those I am watching ]\n");
            [self.tableView reloadData];

        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

    //NSLog(@"userNumber, %@", self.thoseIWatchArray);

//    for (NSString *onWatchFor in self.thoseIWatchArray) {
//    }
    
}
//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    [self.loadingView setColor:UIColorFromRGB(0xf47d44)];
//    [self.view addSubview:self.loadingView];
//    [self.loadingView startAnimating];
//}
- (void)viewDidAppear:(BOOL)animated
{
//    [self.view setBackgroundColor:UIColorFromRGB(0x9eccb3)];



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
    
    if ( indexPath.row == 0 && [self.loadingView isAnimating])
            [self.loadingView stopAnimating];
    
    cell.textLabel.text = @"📞 💬";
    cell.textLabel.textColor = UIColorFromRGB(0x006bb6);
    [cell.imageView setImage:[self imageNamed:@"Profile-256.png"
                                   withString:[[self.thoseIWatchArray objectAtIndex:indexPath.row] substringToIndex:2]
                                         font:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:18.0] size:CGSizeMake(36, 36)] ];
    
    
    // Accessory
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if([cell.textLabel.text isEqualToString:[self.thoseIWatchArray objectAtIndex:indexPath.row]])
        cell.textLabel.text = @"📞 💬";
    else
        cell.textLabel.text = [self.thoseIWatchArray objectAtIndex:indexPath.row];
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"... selected: %@", [self.thoseIWatchArray objectAtIndex:indexPath.row]);
    
//    self.friendToContactDic = [[NSDictionary alloc] initWithObjects:@[[self.watchingPhoneArray objectAtIndex:indexPath.row]]
//                                                       forKeys:@[[self.thoseIWatchArray objectAtIndex:indexPath.row]]];
    [[[UIAlertView alloc] initWithTitle:nil
                               message:nil
                              delegate:self
                      cancelButtonTitle:@"Cancel"
                      otherButtonTitles:@"💬", @"📞", nil ] show];
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
- (UIImage *)imageNamed:(NSString *)imageName
             withString:(NSString *)string // What we want an image of.
                        font:(UIFont *)font     // The font we'd like it in.
                        size:(CGSize)size       // Size of the desired image.
{
    // Create a context to render into.
    UIGraphicsBeginImageContext(size);
    
    
    // Work out what size of font will give us a rendering of the string
    // that will fit in an image of the desired size.
    UIImage *image = [UIImage imageNamed:imageName];
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    
    // We do this by measuring the string at the given font size and working
    // out the ratio scale to it by to get the desired size of image.
//    UIColor* textColor = [UIColor whiteColor];
//    NSDictionary *attributes = @{NSFontAttributeName:font,NSForegroundColorAttributeName:textColor};
    UIColor* textColor = [UIColor whiteColor];
    UIFont*       nFont = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:16];
    NSDictionary* attributes = @{ NSForegroundColorAttributeName: textColor, NSFontAttributeName:nFont };
    NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:string
                                                                  attributes:attributes];
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
//
//    //CGRect rect = CGRectMake(textOrigin.x, textOrigin.y, size.width, size.height);
//
//    // Draw the string into out image!
//    [string drawAtPoint:textOrigin withAttributes:attributes];
    [attrStr drawAtPoint:textOrigin];

    
    // We're done!  Grab the image and return it!
    // (Don't forget to end the image context first though!)
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    return retImage;
}
#pragma mark - UIAlert delegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    //NSLog(@"button index: %d, %@", buttonIndex, title );
    
    switch (buttonIndex) {
        case 0:
            NSLog(@"Cancel");
            break;
        case 1:
            NSLog(@"Message");// to %@", [self.watchingPhoneArray objectAtIndex:but]);
            
            [self showSMSPicker:alertView];
            break;
        case 2:
            NSLog(@"Call");
            break;
        default:
            break;
    }
    
}
#pragma mark - Delegate Methods


// -------------------------------------------------------------------------------
//	messageComposeViewController:didFinishWithResult:
//  Dismisses the message composition interface when users tap Cancel or Send.
//  Proceeds to update the feedback message field with the result of the
//  operation.
// -------------------------------------------------------------------------------
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
/*	self.feedbackMsg.hidden = NO;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MessageComposeResultCancelled:
			self.feedbackMsg.text = @"Result: SMS sending canceled";
			break;
		case MessageComposeResultSent:
			self.feedbackMsg.text = @"Result: SMS sent";
			break;
		case MessageComposeResultFailed:
			self.feedbackMsg.text = @"Result: SMS sending failed";
			break;
		default:
			self.feedbackMsg.text = @"Result: SMS not sent";
			break;
	}
*/
	[self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Async actions
-(void) fetchPhoneNbrForThoseIWatch:(PFUser *)friend2Watch {
    /*********/
    //NSLog(@":%@", friend2Watch.username);
    PFQuery *newQuery = [PFQuery queryWithClassName:@"UserConnection"];
    [newQuery whereKey:@"user" equalTo:friend2Watch];
    [newQuery findObjectsInBackgroundWithBlock:^(NSArray *connObjects, NSError *error)
     {
         if (!error) {
             //NSLog(@"%d", (int)[connObjects count]);
             for (PFObject *newObject in connObjects) {
                 [self.watchingOverDic setObject:[newObject objectForKey:@"userNumber"] forKey:friend2Watch.username];
                 //[self.watchingPhoneArray addObject:[newObject objectForKey:@"userNumber"] ];
                 //NSLog(@"userNumber: %@, %@", friend2Watch.username, [newObject objectForKey:@"userNumber"]);
             }
         } else {
             // Log details of the failure
             NSLog(@"Error: %@ %@", error, [error userInfo]);
         }
     }];// ends 2nd query
    /*********/

}

@end
