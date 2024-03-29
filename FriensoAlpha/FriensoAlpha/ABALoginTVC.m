//
//  ABALoginTVC.m
//  ABALoginView
//
//  Created by Salvador Aguinaga on 5/30/13.
//  Copyright (c) 2013 Salvador Aguinaga. All rights reserved.
//
/*  Adapted to work with LoginParse
 +-----------------------
 | Create parseproject
 | Download SDK
 | Add Parse Framework
 +-----------------------
 | NOTES:
 | + when an email is being entered, check it against parse
 | +-- if no network is available, then what?
 | + 11Dec13SA: Defaulting the 'keep me logged in switch to ON'
 | 15Jan14/SA: Need to handle the main user's phone #
 | 19Jun14/SA: Remove the need to enter ph when doing Login
 | 20Jul14/SA: Fixing problems with scrolling and loosing entered txt
 
 *  http://stackoverflow.com/questions/3276504/how-to-set-a-gradient-uitableviewcell-background
 *  https://parse.com/tutorials/geolocations
 *  http://www.raywenderlich.com/42266/augmented-reality-ios-tutorial-location-based
 */

#import "ABALoginTVC.h"
#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>
#import "NewCoreCircleTVC.h"
#import "FriensoEvent.h"
#import "FriensoAppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "FriensoViewController.h"
#import "CoreFriends.h"
#import "FRSyncFriendConnections.h"


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@interface ABALoginTVC () <CLLocationManagerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;
@property (nonatomic, strong) CLLocationManager *myLocationManager;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) PFGeoPoint *geoPoint;
@property (nonatomic,strong) UIView *welcomeView;
@property (nonatomic, retain) NSMutableArray *coreFriendsArray;
@property (nonatomic, strong) NSMutableArray *coreCircleOfFriends;
@property (nonatomic, strong) NSMutableArray *coreCircleContacts;
@property (nonatomic,retain) UISwitch *locationSwitch;
@property (nonatomic,strong) CLLocation *location;
@property (nonatomic, retain) NSMutableString *storedValue;


@end

@implementation ABALoginTVC
@synthesize loginSections   = _loginSections;
@synthesize loginFields     = _loginFields;
@synthesize loginBtnLabel   = _loginBtnLabel;
@synthesize username        = _username;
@synthesize phoneNumber     = _phoneNumber;
@synthesize password        = _password;
@synthesize loginLabel      = _loginLabel;
@synthesize retVal          = _retVal;
@synthesize keepMeLoggedin = _keepMeLoggedin;
@synthesize welcomeView = _welcomeView;

//int activeCoreFriends = 0;
static int MAX_CORE_FRIENDS = 3;
static NSString * coreFriendAcceptMessage = @"Request accepted. User added to core circle";
static NSString * coreFriendRejectMessage = @"Request rejected. Click to select someone else";
static NSString * coreFriendRequestSendMessage = @"Request send. Awaiting response";
static NSString * coreFriendNotOnFriensoMessage = @"User not on Frienso";
static NSString * contactingServersForUpdate = @"Trying to get latest status from the servers";


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (DBG) NSLog(@"[ ABALoginTVC ]");

    // Initialization
    loginSections = [[NSArray alloc] initWithObjects:@"FRIENSO", @"Log In",@"Options",nil];
    loginFields   = [[NSArray alloc] initWithObjects:@"Email", @"Password", @"(###) ###-####", nil];
    loginBtnLabel = [[NSMutableArray alloc] initWithObjects:@"Sign In", @"Register", nil];
    [self.navigationController.navigationBar setHidden:YES];
    
    self.coreCircleRequestStatus= [[NSMutableArray alloc] init ]; //stores status of the requests
    self.coreCircleContacts     = [[NSMutableArray alloc] init]; //stores phone #s
    self.coreCircleOfFriends    = [[NSMutableArray alloc] init];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:@"installationStep"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSManagedObjectContext *) managedObjectContext{
    
    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.managedObjectContext;
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [loginSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0)
        return [loginFields count];
    else if (section == 2)
        return 2;
    else
        return 1;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 2 ) {
        if ( indexPath.row == 1)
            return [tableView rowHeight]*1.2f;
        else return [tableView rowHeight];
    }
    else return [tableView rowHeight];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 ){
        return 65;
    } else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                           forIndexPath:indexPath];
    
    
    if ( indexPath.section == 0) {
        
        
        if (indexPath.row == 0) {
            username = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 280, 21)];
            NSString *myString = [loginFields objectAtIndex:0];
            
            username .autocorrectionType = UITextAutocorrectionTypeNo;
            username.keyboardType = UIKeyboardTypeEmailAddress;
            [username setClearButtonMode:UITextFieldViewModeWhileEditing];
            [username setAutocapitalizationType:UITextAutocapitalizationTypeNone];
            username.delegate  = self;
            cell.accessoryView = username;
            username .placeholder = myString;
            
        } else if (indexPath.row == 1) {
            password = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 280, 21)];
            NSString *myString = [loginFields objectAtIndex:1];
            password.placeholder = myString;
            password.secureTextEntry = YES;
            password.autocorrectionType = UITextAutocorrectionTypeNo;
            [password setClearButtonMode:UITextFieldViewModeWhileEditing];
            //password.delegate = self;
            cell.accessoryView = password;
            
        } else if (indexPath.row == 2) {
            phoneNumber = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, 280, 21)];
            NSString *myString = [loginFields objectAtIndex:2];
            phoneNumber.placeholder = myString;
            phoneNumber.secureTextEntry = NO;
            phoneNumber.keyboardType = UIKeyboardTypePhonePad;
            [phoneNumber setClearButtonMode:UITextFieldViewModeWhileEditing];
//            [phoneNumber addTarget:self
//             
//                            action:@selector(autoFormatTextField:)
//             
//                  forControlEvents:UIControlEventEditingChanged
//             
//             ];
//            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//            [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
//            phoneNumber.text = [formatter stringFromNumber: [formatter numberFromString:phoneNumber.text]];
            phoneNumber.delegate = self;
            phoneNumber.tag = 199;
            cell.accessoryView = phoneNumber;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            NSString *myString = [loginBtnLabel objectAtIndex:0];
            cell.textLabel.text = myString;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.accessoryView = loginLabel;
            
        }
    } else if (indexPath.section == 2){
        /*if (indexPath.row == 0) {
            NSString *myString = @"Turn on Location";
            cell.textLabel.text = myString;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            UIFont *myFont = [ UIFont fontWithName: @"HelveticaNeue-Light" size: 16.0 ];
            cell.textLabel.font  = myFont;
            cell.textLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0.6 alpha:1];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            self.locationSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            [self.locationSwitch setOn:YES animated:YES];
            self.locationSwitch.tag = 10;
            [self.locationSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = self.locationSwitch;
            [self switchChanged:self.locationSwitch];
            
        }else if (indexPath.row == 1)
        {
            NSString *myString = @"Stayed Logged In";
            cell.textLabel.text = myString;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            UIFont *myFont = [ UIFont fontWithName: @"HelveticaNeue-Light" size: 14.0 ];
            cell.textLabel.font  = myFont;
            cell.textLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0.6 alpha:1];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            [switchView setOn:YES animated:NO];
            switchView.tag = 11;
            [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switchView;
            
            [self switchChanged:switchView];
            
        } else */
        if (indexPath.row == 0) {
            UIFont *myFont = [ UIFont fontWithName: @"HelveticaNeue-Light" size: 14.0 ];
            cell.textLabel.font  = myFont;
            NSString *myString = @"Forgot your password?";
            cell.textLabel.text = myString;
            cell.textLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0.6 alpha:1];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
//            cell.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3];
        } else {
            NSString *myString = @"By creating a Frienso Account you acknowledge that "
            "you have read, understood, and agreed to the Frienso "
            "App Use Waiver http://frienso.tumblr.com";
            UITextView *cellTV = [[UITextView alloc] initWithFrame:CGRectMake(0, 0,
                                                                              tableView.bounds.size.width,
                                                                              cell.frame.size.height*2.0f)];
            cellTV.text =myString;
            cellTV.textAlignment = NSTextAlignmentCenter;
            cellTV.dataDetectorTypes = UIDataDetectorTypeLink;
            cellTV.backgroundColor = [UIColor clearColor];
            cellTV.editable = NO;
            [cell addSubview:cellTV];
        }
    } else {
//        UIFont *myFont = [ UIFont fontWithName: @"HelveticaNeue-Light" size: 14.0 ];
//        cell.textLabel.font  = myFont;

    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        lbl.textAlignment = NSTextAlignmentCenter;
        NSString *myString = [loginSections objectAtIndex:0];
        
        [lbl setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f]];
        //lbl.font = [UIFont systemFontOfSize:16];
        lbl.text = myString;//stringByAppendingString:@"Enter your email, password, and phone number"];
        lbl.numberOfLines = 2;
        lbl.backgroundColor = [UIColor clearColor];
        return lbl;
    } else
        return nil ;
    
}
///** footer:
//    http://stackoverflow.com/questions/5111748/setting-a-basic-footer-to-a-uitableview 
// **/
//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
//    
//    
//    if(section == 2) {
//        return @"By creating a Frienso Account you acknowledge that you have read, "
//        "understood, and agreed to the Frienso App Use Waiver";
//    }
//    else    return nil;
//}
//- (UIView*) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    UIView* view = [[UIView alloc] init];
//    UILabel* label = [[UILabel alloc] init];
//    
//    label.text = @"Something something";
//    label.textAlignment = NSTextAlignmentCenter;
//    
//    [label sizeToFit];
//    label.translatesAutoresizingMaskIntoConstraints = NO;
//    
//    [view addSubview:label];
//    
//    [view addConstraints:
//     @[[NSLayoutConstraint constraintWithItem:label
//                                    attribute:NSLayoutAttributeCenterX
//                                    relatedBy:NSLayoutRelationEqual
//                                       toItem:view
//                                    attribute:NSLayoutAttributeCenterX
//                                   multiplier:1 constant:0],
//       [NSLayoutConstraint constraintWithItem:label
//                                    attribute:NSLayoutAttributeCenterY
//                                    relatedBy:NSLayoutRelationEqual
//                                       toItem:view
//                                    attribute:NSLayoutAttributeCenterY
//                                   multiplier:1 constant:0]]];
//    
//    return view;
//}


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
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
//}
#pragma mark - TextField delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.username resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *nameTextField;
    
    nameTextField = username.text;
    
    if ( [self isUsernameNew:username.text])
    {
        //[loginBtnLabel replaceObjectAtIndex:0 withObject:@"Register"];
        //[self.tableView reloadData];
        //self.tableView set[username setText:nameTextField];
        [self reloadSection:1 withRowAnimation:UITableViewRowAnimationNone];
        //if (DBG) NSLog(@"[ Register Email]");
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == phoneNumber) {
        NSCharacterSet *numSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789-() "];
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        unsigned long charCount = [newString length];
        if ([newString rangeOfCharacterFromSet:[numSet invertedSet]].location != NSNotFound
            || [string rangeOfString:@")"].location != NSNotFound
            || [string rangeOfString:@"("].location != NSNotFound
            || [string rangeOfString:@"-"].location != NSNotFound
            || charCount > 14) {
            return NO;
        }
        if (![string isEqualToString:@""])
        {
            if (charCount == 1)
            {
                newString = [NSString stringWithFormat:@"(%@", newString];
            }
            else if(charCount == 4)
            {
                newString = [newString stringByAppendingString:@") "];
            }
            else if(charCount == 5)
            {
                newString = [NSString stringWithFormat:@"%@) %@", [newString substringToIndex:4], [newString substringFromIndex:4]];
            }
            else if(charCount == 6)
            {
                newString = [NSString stringWithFormat:@"%@ %@", [newString substringToIndex:5], [newString substringFromIndex:5]];
            }
            
            else if (charCount == 9)
            {
                newString = [newString stringByAppendingString:@"-"];
            }
            else if(charCount == 10)
            {
                newString = [NSString stringWithFormat:@"%@-%@", [newString substringToIndex:9], [newString substringFromIndex:9]];
            }
        }
        textField.text = newString;
        return NO;
    }
    return YES;
}
//// handle events
//int myTextFieldSemaphore;
//- (void)autoFormatTextField:(id)sender {
//    
//    if(myTextFieldSemaphore) return;
//    
//    myTextFieldSemaphore = 1;
//    NSNumberFormatter *phoneNumberFormatter = [[NSNumberFormatter alloc] init];
//    [phoneNumberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
//    phoneNumber.text = [phoneNumberFormatter stringFromNumber: [phoneNumberFormatter numberFromString:phoneNumber.text]];
//    myTextFieldSemaphore = 0;
//    
//}

- (BOOL) isUserInNSUserDefaults: (NSString *)user havingPassword: (NSString *)pass
{
    BOOL returnVal = NO;
    // look for the saved search location in NSUserDefaults
    //if (DBG) NSLog(@"isUserInNSUserDefuaults");
    NSUserDefaults *userInLocal = [NSUserDefaults standardUserDefaults];
    NSString *adminKey = [userInLocal objectForKey:@"adminID"];
    NSString *passwKey = [userInLocal objectForKey:@"adminPass"];
    
    if (adminKey == nil || passwKey == nil) {
        returnVal = NO;
    } else {
        if (![adminKey isEqualToString:user] )
        {
            returnVal = NO;
        } else if (![passwKey isEqualToString:pass]){
            returnVal = NO;
        } else {
            
            //if ([adminKey isEqualToString:user] && [passwKey isEqualToString:pass]) {
            if (DBG) NSLog(@"*** in NSUserDefaults and a match ***");
            returnVal = YES;
        }
        
    }
    return returnVal;
}
- (NSString*) formatPlainPhoneString:(NSString*)phone_str_arg {
    NSString* formattedString = nil;
    if (phone_str_arg.length <10 )
        return nil;
    NSRange range = NSMakeRange(3, 3);
    formattedString = [NSString stringWithFormat:@"(%@) %@-%@",
                       [phone_str_arg substringToIndex:3],
                       [phone_str_arg substringWithRange:range],
                       [phone_str_arg substringFromIndex:6]];
    return formattedString;
}
- (BOOL) isUsernameNew: (NSString *)userStr
{   // is username (admin) text entered a new user?
    retVal = NO;
    
    NSUserDefaults *userInLocal = [NSUserDefaults standardUserDefaults];
    NSString *adminKey = [userInLocal objectForKey:@"adminID"];
    if ([adminKey isEqualToString:userStr] )
    {
        return NO;
    } else {
        // user must be new
        
        // rule out sign in check against parse!  Sign In test
        PFQuery *query= [PFUser query];
        
        [query whereKey:@"username" equalTo:userStr];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error && [objects count]>0) {
                
                [loginBtnLabel replaceObjectAtIndex:0 withObject:@"Sign In"];
                PFUser *friensoUser = [objects objectAtIndex:0];
                NSString *cloudPhnNbr = [friensoUser objectForKey:@"phoneNumber"];
                [phoneNumber setText:[self formatPlainPhoneString:[self stripStringOfUnwantedChars:cloudPhnNbr]]];
                [self reloadSection:1 withRowAnimation:UITableViewRowAnimationNone];
                /**
                [self.locationSwitch setOn:YES animated:YES];  // Existing user->force location tracking
                [self.locationSwitch setEnabled:YES];
                **/
                
                
                //  if (DBG) NSLog(@"existingUser set");
                //  Sign In and skip coreCircle View Controller
                [userInLocal setObject:@"1" forKey:@"existingUser"];
                [userInLocal synchronize];
                
                retVal = NO;
            } else{
                retVal = YES;
                [loginBtnLabel replaceObjectAtIndex:0 withObject:@"Register"];
                [self reloadSection:1 withRowAnimation:UITableViewRowAnimationNone];
                // "New User" 
            }
        }];
        
        return retVal;
    }
}
//- (BOOL)registerAdminUser:(NSString *)userNm userEmail:(NSString *)email userPassword:(NSString *)passWrd
//    /* https://gist.github.com/vksaini13/4509465 a gist
//     * http://www.theappcodeblog.com/2011/05/16/nsnotificationcenter-tutorial-using-the-notification-center-in-your-iphone-app/
//     * */
//{
//    if (DBG) NSLog(@"*** registerAdminUser ***");
//    _retVal = NO;
//    
//    if ([self validUsername:email andPassword:passWrd]){
//        // validate user email and password
//        NSMutableDictionary *newUserDict = [[NSMutableDictionary alloc] init] ;
//        [newUserDict setObject:userNm  forKey:@"user_name"];
//        [newUserDict setObject:email   forKey:@"user_email"];
//        [newUserDict setObject:passWrd forKey:@"user_passw"];
//        
//        // From the iOS6 book hardcoding
////        NSString *urlAsString = REGISTER_URL;   //@"http://10.0.0.18/tremcam/putuserregister.php";
//        urlAsString = [urlAsString stringByAppendingString:@"?email="];
//        urlAsString = [urlAsString stringByAppendingString:email];
//        urlAsString = [urlAsString stringByAppendingString:@"&name="];
//        urlAsString = [urlAsString stringByAppendingString:userNm];
//        urlAsString = [urlAsString stringByAppendingString:@"&passwrd="];
//        urlAsString = [urlAsString stringByAppendingString:passWrd];
//        
//        NSURL *url = [NSURL URLWithString:urlAsString];
//        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
//        [urlRequest setTimeoutInterval:30.0f];
//        [urlRequest setHTTPMethod:@"POST"];
//        
////        NSString *body = @"bodyParam1=BodyValue1&bodyParam2=BodyValue2";
////        [urlRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
//        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//        [NSURLConnection sendAsynchronousRequest:urlRequest
//                                           queue:queue
//                               completionHandler:^(NSURLResponse *response,
//                                                   NSData *data, NSError *error) {
//                                               if ([data length] >0 && error == nil){
//                                                   NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                                                   if (DBG) NSLog(@"HTML = %@", html);
//                                                   UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Response from server"
//                                                                                                       message:html
//                                                                                                      delegate:nil
//                                                                                             cancelButtonTitle:@"OK"
//                                                                                             otherButtonTitles:nil];
//                                                   
//                                                   //[alertView show];
//                                                   [alertView performSelectorOnMainThread:@selector(show)
//                                                                               withObject:nil
//                                                                            waitUntilDone:YES];
//                                                   
//                                               }
//                                               else if ([data length] == 0 && error == nil){
//                                                   if (DBG) NSLog(@"Nothing was downloaded.");
//                                                   
//                                               }
//                                               else if (error != nil){
//                                                   if (DBG) NSLog(@"Error happened = %@", error);
//                                                   
//                                               }
//                                           }];
//        
//        /*   or can we use :
//         NSString *str = [self stringFromDict:dict];
//         if (DBG) NSLog(@"from: writeDictionary:%@",str);
//         NSData *myRequestData = [str dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:NO];
//         
//        [[NSNotification ]removeObserver:self];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newsfeedFetchCompleted:) name:kNewsfeedFetchCompleted object:nil];
//        
//        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"RegisterUserWithUserAccountDictNotification" object:self userInfo:newUserDict]];
//        [[NSNotification defaultCenter]removeObserver:self];
//        if (DBG) NSLog(@"Notification with dict: %@", newUserDict);
//         */
//        
//        return _retVal = YES;
//    }else
//        return _retVal;
//}

-(BOOL) forgotPasswordValidInput:(NSString *)emailInput{
//  Reference [1]
    NSString *emailRegex   = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:emailInput];
}

-(BOOL)validUsername:(NSString *)usr andPassword:(NSString *)pass{
    // here we need to check for more that just empty fields
    if (([usr length]==0) || ([pass length]==0)) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Username and Password fields must be completed."
                                  message:nil
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
        
        return NO;
    }else
        return YES;
    
}

//-(void)registerUserWithUserAccountDictNotification:(NSNotification *)notification{
//    
//    if (DBG) NSLog(@"notification: %@", notification);
//    
//    NSMutableDictionary *accountDict = [notification object];
//    NSString *emailStr = [accountDict objectForKey:@"user_email"];
//    
//    NSString *responseStr = [self writeDictionary:accountDict outToURL:[NSURL URLWithString:REGISTER_URL]];
//    
//    if ([responseStr isEqualToString:@"User Created"]) {
//        
//        NSString *alertViewStr =[NSString stringWithFormat:@"User: %@ created!", emailStr];
//        NSString *message = @"Login to start updating your profile.";
//        
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertViewStr message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        
//        [alertView show];
//        //        [alertView release];
//    }
//    else{
//        if ([responseStr isEqualToString:@"User Taken"]) {
//            NSString *alertViewStr =[NSString stringWithFormat:@"User: %@ taken.", emailStr];
//            NSString *message = @"Choose a different email address";
//            
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertViewStr message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            
//            [alertView show];
//            //            [alertView release];
//            
//        }
//        else{ // the response string is malformed or reads error
//            NSString *alertViewStr =[NSString stringWithFormat:@"Error"];
//            NSString *message = @"The server could not create this username. Make sure you are connected to the internet or try again later.";
//            
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertViewStr message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            
//            [alertView show];
//            //            [alertView release];
//        }
//        
//    }
//}
-(NSString *)writeDictionary:(NSDictionary *)dict outToURL:(NSURL *)url{
    /*  resources
     http://homepages.ius.edu/RWISMAN/C490/html/chapter22.htm
     http://stackoverflow.com/questions/1571336/sending-post-data-from-iphone-over-ssl-https
     http://stackoverflow.com/questions/3245191/send-nsmutablearray-as-json-using-json-framework?rq=1
     http://stackoverflow.com/questions/11527231/how-to-pass-nsarray-which-is-part-of-nsdictionary-in-http-get-method
     http://blogs.captechconsulting.com/blog/nathan-jones/getting-started-json-ios5
     
     */
    // HERE WE POST THE SENSOR DATA ARRAYS TO MYSQL
    
    //    NSArray * myA = [dict allKeys];
    //    NSString *key = [myA objectAtIndex:1];
    //    if ([key hasSuffix:@"axis"])//([key isKindOfClass:[NSMutableArray class]])
    //        str = [self stringFromDictWithArray:dict];
    //    else
    
    
    NSString *str = [self stringFromDict:dict];
    if (DBG) NSLog(@"from: writeDictionary:%@",str);
    NSData *myRequestData = [str dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:NO];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: myRequestData];
    
    NSError *err;
    
    NSURLResponse *response;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding] ;
    
    if (DBG) NSLog(@"Response string from writedict... is : %@",responseStr);
    return responseStr;
    
}

-(NSString *)stringFromDict:(NSDictionary *)dict{
    //if (DBG) NSLog(@"stringFromDict %d", dict.count);
    NSArray * myA = [dict allKeys];
    NSString *key;
    NSString *val;
    NSString *fullstr =@"";
    for (int i = 0; i < dict.count; i++) {
        key = [myA objectAtIndex:i];
        val = [dict objectForKey:key];
        fullstr = [fullstr stringByAppendingString:key];
        fullstr =  [fullstr stringByAppendingString:@"="];
        if ( [key hasSuffix:@"axis"] || [key hasPrefix:@"time"])
            fullstr  =[fullstr stringByAppendingString:[NSString stringWithFormat:@"=%@",val]];
        else
            fullstr  =[fullstr stringByAppendingString:val];
        if (i != (dict.count -1)) {
            fullstr = [fullstr stringByAppendingString:@"&"];
        }
    }
    return fullstr;
}


#pragma mark - Table view delegate
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    if (section == 2) {
//        // Set the text color of our header/footer text.
////        UITableViewHeaderFooterView *view = [[UITableViewHeaderFooterView alloc] init];
////        [header.textLabel setTextColor:[UIColor whiteColor]];
////        header.textLabel.text = @"Text information is ";
////        header.textLabel.textAlignment = NSTextAlignmentCenter;
//        // Set the background color of our header/footer.
////        header.contentView.backgroundColor = [UIColor blackColor];
////        header.frame = CGRectMake(0, 0, 100, 80);
//        // You can also do this to set the background color of our header/footer,
//        //    but the gradients/other effects will be retained.
//        // view.tintColor = [UIColor blackColor];
//    // create the label
////    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
////    headerLabel.backgroundColor = [UIColor clearColor];
////    headerLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0];
////    headerLabel.frame = CGRectMake(0, 0, 200, 80.0f);
////        headerLabel.numberOfLines = 2;
////    headerLabel.textAlignment = NSTextAlignmentCenter;
////        headerLabel.text = @"By creating a Frienso ";
////    headerLabel.textColor = [UIColor whiteColor];
////        UILabel* headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
////        headerLabel.text = @"sskjdf sldkjf  sldskfj";
////        headerLabel.textColor = [UIColor whiteColor];
////        headerLabel.textAlignment = NSTextAlignmentCenter;
////        [headerLabel sizeToFit];
////        headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
////        
////        // create the parent view that will hold header Label
////        UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
////        customView.backgroundColor = [UIColor blackColor];
////        [customView addSubview:headerLabel];
////        [customView addConstraints:
////         @[[NSLayoutConstraint constraintWithItem:headerLabel
////                                        attribute:NSLayoutAttributeCenterX
////                                        relatedBy:NSLayoutRelationEqual
////                                           toItem:customView
////                                        attribute:NSLayoutAttributeCenterX
////                                       multiplier:1 constant:0],
////           [NSLayoutConstraint constraintWithItem:headerLabel
////                                        attribute:NSLayoutAttributeCenterY
////                                        relatedBy:NSLayoutRelationEqual
////                                           toItem:customView
////                                        attribute:NSLayoutAttributeCenterY
////                                       multiplier:1 constant:0]]];
////    return customView;
//        // Create label with section title
//        UITextView *label = [[UITextView alloc] init];
//        label.frame = CGRectMake(20, 6, 280, 30);
//        label.backgroundColor = [UIColor clearColor];
//        label.textColor = [UIColor whiteColor];
//        label.editable = NO;
//        label.dataDetectorTypes = UIDataDetectorTypeLink;
//        label.tintColor = [UIColor lightTextColor];
//        label.textAlignment = NSTextAlignmentCenter;
////        label.shadowColor = [UIColor lightGrayColor];
////        label.shadowOffset = CGSizeMake(0.0, 1.0);
//        //label.font = [UIFont boldSystemFontOfSize:16];
//        label.text = @"By creating a Frienso Account you acknowledge that "
//                      "you have read, understood, and agreed to the Frienso "
//                      "App Use Waiver www.ibm.com";
//        [label sizeToFit];
//        
//        // you could also just return the label (instead of making a new view and adding the label as subview. With the view you have more flexibility to make a background color or different paddings
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.sectionFooterHeight)];
//        [view addSubview:label];
//        
//        
//        
//        [view  addConstraints:
//         @[[NSLayoutConstraint constraintWithItem:label
//                                        attribute:NSLayoutAttributeCenterX
//                                        relatedBy:NSLayoutRelationEqual
//                                           toItem:view
//                                        attribute:NSLayoutAttributeCenterX
//                                       multiplier:1 constant:0],
//           [NSLayoutConstraint constraintWithItem:label
//                                        attribute:NSLayoutAttributeCenterY
//                                        relatedBy:NSLayoutRelationEqual
//                                           toItem:view
//                                        attribute:NSLayoutAttributeCenterY
//                                       multiplier:1 constant:0]]];
//        
//        return view;
//    } else return nil;
//}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1){
        if (![self checkAppropriatePhoneNumberInput])
        {
            [UIView animateWithDuration:1.5 animations:^{
                [phoneNumber setTextColor:[UIColor darkGrayColor]];
                [phoneNumber setAlpha:0.5];
                [phoneNumber setTextAlignment:NSTextAlignmentRight];
                [phoneNumber setTextColor:[UIColor blueColor]];
                [phoneNumber setTextAlignment:NSTextAlignmentLeft];
                [phoneNumber setAlpha:1.0];
            }];
             
            return; // do nothing and go back if not a complete phone #
        }
        if ( [self validUsername:username.text andPassword:password.text]) // Is input valid?
        {
            if (DBG) NSLog(@"** valid input **");
        } else {
            return ;
        }
        
        if ( [self isUserInNSUserDefaults: username.text havingPassword:password.text]){
            // Case might occur when user created an account but did not complete coreCircle
            if (DBG) NSLog(@"Already Stored Locally, check cloud if a circle exists");
            [self presentCoreCircleSetupAndCheckCloudVC];
            //add logic to handle if the user is already in Parse!
                
        } else {
            if ([self userInParse]){
                // login this user to parse
                [self loginThisUserToParse:username.text withPassword:password.text andPhoneNumber:phoneNumber.text];         // already set?
                [self saveNewUserLocallyWithEmail:username.text plusPassword:password.text];
                NSString *message = @"You are logged in as: ";
                [self actionAddFriensoEvent:[message stringByAppendingString:username.text]
                               withSubtitle:@"Welcome back to Frienso."]; // FriensoEvent
                
                // sync core circle from Parse | skip to the Frienso Dashboard
                if (DBG) NSLog(@"  --- Returning to Home View");
                [self popDashboardVC];
                
            } else {
                if (!DBG) NSLog(@"  [ Registering a new user ]");
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"newUserFlag"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                NSString *msgStr = @"Thank you for joining Frienso.";
                [self actionAddFriensoEvent:[msgStr stringByAppendingString:username.text]
                               withSubtitle:@"Welcome!!"]; // FriensoEvent
                
                [self saveNewUserLocallyWithEmail:username.text plusPassword:password.text];
                
                [self registerNewUserToParseWithEmail:username.text
                                         plusPassword:password.text
                                      withPhoneNumber:[self stripStringOfUnwantedChars:phoneNumber.text]];
            
                [self popCoreCircleSetupVC]; // go to the core circle first setup
            }
            
        }
        
    } else if (indexPath.section == 2){
        //if (DBG) NSLog(@"section 2: %d",tableView.indexPathForSelectedRow.row);
        NSString *alertTitleStr = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitleStr
                                                            message:@"Enter your institution email"
                                                           delegate:self
                                                  cancelButtonTitle:@"Submit" otherButtonTitles:nil, nil];
        alertView.tag = 100;
        alertView.delegate = self;
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        
        // Add a placehold and set keyboard type
        UITextField *_UITextField  = [alertView textFieldAtIndex:0];
        _UITextField.placeholder = @"frienso@university.edu";
        _UITextField.keyboardType = UIKeyboardTypeEmailAddress;
        
        [alertView show];
    }

}
- (BOOL) checkAppropriatePhoneNumberInput {
    //NSLog(@"    entered phone number %@", phoneNumber.text);
    //    (###) ###-####
    if (phoneNumber.text.length <14) {
        [[[UIAlertView alloc] initWithTitle:@"Enter your complete phone#" message:@"(###) ###-####, your phone # will be used to connect you with your Core Friends and to send push notifications." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
        return NO;
    } else
        return YES;
}
- (void) reloadSection:(NSInteger)section withRowAnimation:(UITableViewRowAnimation)rowAnimation {
    //if (DBG) NSLog(@"login btn label %@", loginBtnLabel);
    NSRange range = NSMakeRange(section, 1);
    NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView reloadSections:sectionToReload withRowAnimation:rowAnimation];
}

- (void) loginThisUserToParse:(NSString *)userName
                 withPassword:(NSString *)userPass
               andPhoneNumber:(NSString*)phoneNbr
{
    [PFUser logInWithUsernameInBackground:userName password:userPass
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            if (DBG) NSLog(@"[ Parse successful login ]"); // Do stuff
                                            [user setObject:[self stripStringOfUnwantedChars:phoneNbr] forKey:@"phoneNumber"];
                                            [user saveInBackground];
                                            [self insertCurrentLocation:user];
                                            
                                            if (DBG) NSLog(@"[ Stored this user's current loc ]");
                                            [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
                                                if (!error) {
                                                    if (DBG) NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
                                                    
                                                    [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
                                                    [[PFUser currentUser] saveInBackground];
                                                }
                                            }];
                                            
                                            // Sync from parse!
                                            PFQuery *query = [PFQuery queryWithClassName:@"UserCoreFriends"];
                                            [query whereKey:@"user" equalTo:userName];
                                            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
                                             {
                                                 if (!error) {
                                                     // The find succeeded.
                                                     if (DBG) NSLog(@"Successfully retrieved %d scores.", (int)objects.count);
                                                     // Do something with the found objects
                                                     for (PFObject *object in objects) {
                                                         if (DBG) NSLog(@"%@", object.objectId);
                                                     }
                                                 } else {
                                                     // Log details of the failure
                                                     if (DBG) NSLog(@"Error: %@ %@", error, [error userInfo]);
                                                 }
                                             }];
                                            
                                            if (DBG) NSLog(@" setting existingUser ");
                                            //ToDo: set existsingUser to 2 = synchronized (downloaded info)
                                            NSUserDefaults *userInLocal = [NSUserDefaults standardUserDefaults];
                                            [userInLocal setObject:@"2" forKey:@"existingUser"];
                                            [userInLocal synchronize];
                                        } else {
                                            if (DBG) NSLog(@"[ ERROR: Login failed | %@",error);// The login failed. Check error to see why.
                                        }
                                    }];
}
- (void) popDashboardVC
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"CoreFriendsContactInfoDicKey"] count] == 0)
        [self syncFromParse]; /// how well is this working ???
    else
        if (DBG) NSLog(@"all loaded already");
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:2]
                                              forKey:@"afterFirstInstall"];
    [[NSUserDefaults standardUserDefaults] setBool:YES
                                            forKey:@"getStartedFlag"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) popCoreCircleSetupVC
{
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"newUserFlag"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
//    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"  bundle:nil];
//    NewCoreCircleTVC  *coreCircleController = (NewCoreCircleTVC*)[mainStoryboard instantiateViewControllerWithIdentifier: @"coreCircleView"];
//    coreCircleController.checkCloud = NO;
//    [self.navigationController pushViewController:coreCircleController animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self presentViewController:coreCircleController animated:YES completion:nil];
//    [self performSegueWithIdentifier:@"coreFriendsView" sender:self];
}
- (void) presentCoreCircleSetupAndCheckCloudVC
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"  bundle:nil];
    NewCoreCircleTVC  *coreCircleController = (NewCoreCircleTVC*)[mainStoryboard instantiateViewControllerWithIdentifier: @"coreCircleView"];
    coreCircleController.checkCloud = YES;
    [self.navigationController pushViewController:coreCircleController animated:YES];
    
    //    [self presentViewController:coreCircleController animated:YES completion:nil];
    //    [self performSegueWithIdentifier:@"coreFriendsView" sender:self];
}

#pragma mark - CoreData helper methods
- (void) actionAddFriensoEvent:(NSString *) message withSubtitle:(NSString *)subtitle{
    if (DBG) NSLog(@"[ actionAddFriensoEvent ]");
    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *managedObjectContext =
    appDelegate.managedObjectContext;
    
    FriensoEvent *firstFriensoEvent = [NSEntityDescription insertNewObjectForEntityForName:@"FriensoEvent"
                                                                    inManagedObjectContext:managedObjectContext];
    /** What the right way to manage geolocation points between coredata and parse.com? **/
    if (firstFriensoEvent != nil){
        //NSString *loginFriensoEvent = @"You are logged in as: ";
        firstFriensoEvent.eventTitle     = message;
        firstFriensoEvent.eventSubtitle  = subtitle;
        firstFriensoEvent.eventLocation  = [NSString stringWithFormat:@"%f,%f", self.coordinate.latitude, self.coordinate.longitude];
        firstFriensoEvent.eventContact   = @"me";
        firstFriensoEvent.eventCreated   = [NSDate date];
        firstFriensoEvent.eventModified  = [NSDate date];
        
        NSError *savingError = nil;
        if([managedObjectContext save:&savingError]) {
            if (DBG) NSLog(@"Successfully saved the context");
        } else { if (DBG) NSLog(@"Failed to save the context. Error = %@", savingError); }
    } else {
        if (DBG) NSLog(@"Failed to create a new event.");
    }
}
- (void)saveNewUserLocallyWithEmail:(NSString *)newUserEmail plusPassword:(NSString *)newUserPassword
    {
        NSUserDefaults *userInLocal = [NSUserDefaults standardUserDefaults];
        [userInLocal setObject:newUserEmail forKey:@"adminID"];
        [userInLocal setObject:newUserEmail forKey:@"userName"];
        [userInLocal setObject:newUserEmail forKey:@"userEmail"];
        [userInLocal setObject:newUserPassword forKey:@"adminPass"];
        [userInLocal setObject:@"0" forKey:@"adminInParse"];
        [userInLocal setObject:[self stripStringOfUnwantedChars:phoneNumber.text] forKey:@"userPhone"];
        [userInLocal synchronize];
        if (DBG) NSLog(@"[New user saved locally]");
    }

// register or sign-up
- (void)registerNewUserToParseWithEmail:(NSString *)newUserEmail
                           plusPassword:(NSString *)newUserPassword withPhoneNumber:(NSString *)userPhoneNumber{
    PFUser *user   = [PFUser user];
    user.email     = newUserEmail;
    user.username  = newUserEmail;
    user.password  = newUserPassword;
    //remove dashes
    userPhoneNumber = [self stripStringOfUnwantedChars:userPhoneNumber];
    //[userPhoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    user[@"phoneNumber"] = userPhoneNumber;
    
    
    [self insertCurrentLocation:user];// MIGHT NOT BE NEEDED
    // add current location to User object
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
            [[PFUser currentUser] saveInBackground];
            //if (DBG) NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
            if (DBG) NSLog(@"Saved your location to cloud-store");
        }
    }];
    // other fields can be set just like with PFObject
    //[user setObject:@"415-392-0202" forKey:@"phone"];
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Hooray! Let them use the app now.
            // Add Phone
            //23Jun14/SA: [self addPhoneNumberToCloudForEmail: newUserEmail withPhoneNumber:userPhoneNumber];
            
            NSUserDefaults *userInLocal = [NSUserDefaults standardUserDefaults];
            [userInLocal setObject:@"1" forKey:@"adminInParse"];
            [userInLocal setBool:YES forKey:@"isUserNew"];
            [userInLocal synchronize];
            if (DBG) NSLog(@"[NSUserDefaults/Parse sync confirmed]");
            
        } else {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];
            // Show the errorString somewhere and let the user try again.
            if (DBG) NSLog(@"Error: %@",errorString);
        }
    }];
}

- (void) switchChanged:(id)sender {
    UISwitch* switchControl = sender;
    
    if (switchControl.tag == 10)
    {
        if (DBG) NSLog(@"loc switch activated");
        [self.locationManager startUpdatingLocation];
        [self setInitialLocation:self.locationManager.location];

    } else {
        BOOL keepLoggedIn = NO;
        if ( switchControl.on )
            keepLoggedIn = YES;
        else
            keepLoggedIn = NO;
            
        NSUserDefaults *userInLocal = [NSUserDefaults standardUserDefaults];
        [userInLocal setBool:keepLoggedIn forKey:@"keepUserLoggedIn"];
        [userInLocal synchronize];
        //if (DBG) NSLog( @"The switch is %@", switchControl.on ? @"ON" : @"OFF" );
    }
}
- (BOOL) userInParse{
    NSUserDefaults *userInLocal = [NSUserDefaults standardUserDefaults];
    NSString       *inParse    = [userInLocal objectForKey:@"existingUser"];
    if([inParse isEqualToString:@"1"])
        return YES;
    else
        return NO;
}


#pragma mark * Actions
- (void)setInitialLocation:(CLLocation *)aLocation {
    self.location = aLocation;
    //self.radius = 1000;
    //if (DBG) NSLog(@"%.2f,%.2f",self.location.coordinate.latitude, self.location.coordinate.longitude);
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            if (DBG) NSLog(@"My geo-location: %f, %f", geoPoint.latitude, geoPoint.longitude);
            NSNumber *lat = [NSNumber numberWithDouble:geoPoint.latitude];
            NSNumber *lon = [NSNumber numberWithDouble:geoPoint.longitude];
            NSDictionary *userLocation=@{@"lat":lat,@"long":lon};
            
            [[NSUserDefaults standardUserDefaults] setObject:userLocation forKey:@"userLocation"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
            [[PFUser currentUser] saveInBackground];
        }
    }];
}
-(void) addPhoneNumberToCloudForEmail:(NSString *)userEmail  withPhoneNumber:(NSString *)userPhone {
    PFObject *userCoreFriends = [PFObject objectWithClassName:@"UserConnection"]; //connection = phone number
    [userCoreFriends setObject:userPhone forKey:@"userNumber"];
    
    /*[PFUser logInWithUsernameInBackground:userEmail
                                 password:
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            PFUser *currentUser = [PFUser currentUser];
                                            if (currentUser) {
                                                if (DBG) NSLog(@"%@, login successful",currentUser.email);
                                            } else {
                                                // show the signup or login screen
                                                if (DBG) NSLog(@"no current user");
                                            }
                                        } else {
                                            if (DBG) NSLog(@"The login failed. Check error to see why. %@",error);
                                        }
                                    }];
    */
    // Set the proper ACLs
    PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [ACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:ACL withAccessForCurrentUser:YES];
    //comment.ACL = ACL;
    // Set the access control list to current user for security purposes
    userCoreFriends.ACL = ACL;// [PFACL ACLWithUser:[PFUser currentUser]];
    
    PFUser *user = [PFUser currentUser];
    if (DBG) NSLog(@"%@",user.email);
    [userCoreFriends setObject:user forKey:@"user"];
    [userCoreFriends saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            //[self refresh:nil];
            if (DBG) NSLog(@"[ CoreFriends Dictionary for User upload attempted. ]");
        }
        else{
            // Log details of the failure
            if (DBG) NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Submit"])
    {
        // Validate email input
        if ( [self forgotPasswordValidInput:[alertView textFieldAtIndex:0].text])
        {   // Good! //
            // Request a reset from Parse.com
            // NB:
            //  Not ideal; we should collect new password and set it manually rather than exposing
            //  the user to Parse.com ** don't want to confuse user **
            [PFUser requestPasswordResetForEmailInBackground:[alertView textFieldAtIndex:0].text];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Check email to reset password"
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            [alertView show];
        }else {
            if (DBG) NSLog(@"Bad input!");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Incorrect Email Format"
                                                                message:@"Please try again"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            [alertView show];
        }
        
    }
    
    
}


#pragma mark - Core Location Services
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    
    CLLocation *lastLocation = [locations lastObject];
    CLLocationAccuracy accuracy = [lastLocation horizontalAccuracy];
	if (DBG) NSLog(@"Received location %@ with accuracy %f", lastLocation, accuracy);
    CLLocation *location = manager.location;

	if(accuracy <= 50.0) {
		//4
//        if (DBG) NSLog(@"latitude and longitude: %ld, %@", [locations count], locations );
        self.coordinate = [location coordinate];
        
        self.geoPoint = [PFGeoPoint geoPointWithLatitude:self.coordinate.latitude
                                                      longitude:self.coordinate.longitude];
        //[self actionAddFriensoEvent:username.text withSubtitle:<#(NSString *)#>]; // FriensoEvent
		[manager stopUpdatingLocation];
	}
    
    
    
}
- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if (DBG) NSLog(@"Failed to receive location information, see error: %@", error);
}

-(void) getDeviceLocationInfo {
    if ([CLLocationManager locationServicesEnabled]) {
        self.myLocationManager = [[CLLocationManager alloc] init];
        //self.myLocationManager.distanceFilter = kCLDistance; // whenever we move
        self.myLocationManager.desiredAccuracy = kCLLocationAccuracyBest; // 100 m
        self.myLocationManager.delegate = self;
        [self.myLocationManager startUpdatingLocation];
    } else
        if (DBG) NSLog(@"Location services are not enabled");
        
        
}

- (void) insertCurrentLocation:(PFUser *)pfUser {
    if (DBG) NSLog(@"-- insertCurrentLocation --");
    [self getDeviceLocationInfo];
    
	// If it's not possible to get a location, then return.
	CLLocation *location = self.myLocationManager.location;
	if (!location) {
		return;
	}
    
    /*  NO LONGER NEEDED, location is now tracked via User object 
     *
	// Configure the new event with information from the location.
	CLLocationCoordinate2D coordinate = [location coordinate];
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    PFObject *object = [PFObject objectWithClassName:@"Location"];
    [object setObject:geoPoint forKey:@"location"];
    [object setObject:pfUser.username forKey:@"user"];
    
    [object saveEventually:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // Reload the PFQueryTableViewController
            if (DBG) NSLog(@"...location saved to cloud");//[self loadObjects];
            [self actionAddFriensoEvent:@"Location Saved"
                           withSubtitle:[NSString stringWithFormat:@"%4.f, %4.f",coordinate.latitude, coordinate.longitude]];
        }
    }];
     */
}
#pragma mark - Configure UIView
-(void) setupTopLabel{
    UILabel *welcomeLabel = [[UILabel alloc] init];
    welcomeLabel.backgroundColor = [UIColor clearColor];
    welcomeLabel.text = @"Frienso";
    welcomeLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:28.0];
    welcomeLabel.textColor = [UIColor whiteColor];
    [welcomeLabel setTextAlignment:NSTextAlignmentCenter];
    [welcomeLabel sizeToFit];
    
    UILabel *welcomeLabel2 = [[UILabel alloc] init];
    welcomeLabel2.backgroundColor = [UIColor clearColor];
    welcomeLabel2.text = @"Your μSocial Safety Network\nfor College Campus";
    welcomeLabel2.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:20.0];
    welcomeLabel2.textColor = [UIColor whiteColor];
    [welcomeLabel2 setTextAlignment:NSTextAlignmentCenter];
    [welcomeLabel2 setNumberOfLines:2];
    [welcomeLabel2 sizeToFit];
    welcomeLabel.center = CGPointMake(self.view.center.x,self.view.bounds.size.height*0.125);
    welcomeLabel2.center = CGPointMake(self.view.center.x,self.view.bounds.size.height*0.20);
    
    [self.view addSubview:welcomeLabel];
    [self.view addSubview:welcomeLabel2];
}
-(void) configureView:(UIView *)welcomeView
{
    UILabel *welcomeLabel = [[UILabel alloc] init];
    welcomeLabel.backgroundColor = [UIColor clearColor];
    welcomeLabel.text = @"Frienso";
    welcomeLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:28.0];
    welcomeLabel.textColor = [UIColor whiteColor];
    [welcomeLabel setTextAlignment:NSTextAlignmentCenter];
    [welcomeLabel sizeToFit];
    
    UILabel *welcomeLabel2 = [[UILabel alloc] init];
    welcomeLabel2.backgroundColor = [UIColor clearColor];
    welcomeLabel2.text = @"Your μSocial Safety Network\nfor College Campus";
    welcomeLabel2.font = [UIFont fontWithName:@"AppleSDGothicNeo-Light" size:20.0];
    welcomeLabel2.textColor = [UIColor whiteColor];
    [welcomeLabel2 setTextAlignment:NSTextAlignmentCenter];
    [welcomeLabel2 setNumberOfLines:2];
    [welcomeLabel2 sizeToFit];
    welcomeLabel.center = CGPointMake(self.view.center.x,self.view.bounds.size.height*0.125);
    welcomeLabel2.center = CGPointMake(self.view.center.x,self.view.bounds.size.height*0.20);
    
    [welcomeView addSubview:welcomeLabel];
    [welcomeView addSubview:welcomeLabel2];
    
    
    UIButton *button= [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, self.view.bounds.size.width/2.0f, 50);
    [button.titleLabel setTextColor:[UIColor whiteColor]];
    [button.titleLabel setTintColor:[UIColor whiteColor]];
    [button addTarget:self
               action:@selector(pushNextViewController:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Join the Movement" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:16.0]];
    button.layer.cornerRadius = 6.0f;
    button.backgroundColor = UIColorFromRGB(0x4962D6);
    //    [button setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2,
    //                                  [UIScreen mainScreen].bounds.size.height*0.9)];
    [welcomeView addSubview:button];
    
    [self.view addSubview:welcomeView];
    
    [UIView animateWithDuration:1.5 animations:^{
        [button setCenter:CGPointMake(self.view.center.x, self.view.bounds.size.height*0.9)];
    }];
}
//#pragma mark - Fetched results controller
/*
 Returns the fetched results controller. Creates and configures the controller if necessary.
 */
//- (NSFetchedResultsController *)fetchedResultsController {
//    
//    if (_fetchedResultsController != nil) {
//        return _fetchedResultsController;
//    }
//    
//    // Create and configure a fetch request with the Book entity.
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    if (DBG) NSLog(@"[1]");
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FriensoEvent" inManagedObjectContext:self.managedObjectContext];
//    [fetchRequest setEntity:entity];
//    
//    // Create the sort descriptors array.
//    NSSortDescriptor *authorDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eventCreated" ascending:YES];
//    NSSortDescriptor *titleDescriptor = [[NSSortDescriptor alloc] initWithKey:@"eventModified" ascending:YES];
//    NSArray *sortDescriptors = @[authorDescriptor, titleDescriptor];
//    [fetchRequest setSortDescriptors:sortDescriptors];
//    
//    // Create and initialize the fetch results controller.
//    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"eventTitle" cacheName:@"Root"];
//    _fetchedResultsController.delegate = self;
//    
//    return _fetchedResultsController;
//}


/*
    References
    [1] http://stackoverflow.com/questions/800123/what-are-best-practices-for-validating-email-addresses-in-objective-c-for-ios-2
 
 [[self view] setBackgroundColor: [UIColor colorWithPatternImage: [UIImage imageNamed:@"first-view-cover.png"]]];
 [self setupTopLabel];
 
 UIButton *button= [UIButton buttonWithType:UIButtonTypeCustom];
 button.frame = CGRectMake(0, 0, self.view.bounds.size.width/2.0f, 50);
 [button.titleLabel setTextColor:[UIColor whiteColor]];
 [button.titleLabel setTintColor:[UIColor whiteColor]];
 [button addTarget:self
 action:@selector(pushNextViewController:)
 forControlEvents:UIControlEventTouchUpInside];
 [button setTitle:@"Join the Movement" forState:UIControlStateNormal];
 [button.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:16.0]];
 button.layer.cornerRadius = 6.0f;
 button.backgroundColor = UIColorFromRGB(0x4962D6);
 //    [button setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2,
 //                                  [UIScreen mainScreen].bounds.size.height*0.9)];
 [self.view addSubview:button];
 
 [UIView animateWithDuration:1.5 animations:^{
 [button setCenter:CGPointMake(self.view.center.x, self.view.bounds.size.height*0.9)];
 }];
 
 
 Override the View background
CAGradientLayer *gradient = [CAGradientLayer layer];
gradient.frame       = cell.bounds;
UIColor *startColour = [UIColor colorWithHue:.580555 saturation:0.31 brightness:0.90 alpha:1.0];
UIColor *endColour   = [UIColor colorWithHue:.58333 saturation:0.50 brightness:0.62 alpha:1.0];
gradient.colors = [NSArray arrayWithObjects:(id)[startColour CGColor],(id)[endColour CGColor], nil];
//[cell.layer insertSublayer:gradient atIndex:0];
[cell setBackgroundView:[[UIView alloc] init]];
[cell.backgroundView.layer insertSublayer:gradient atIndex:0];
[cell setBackgroundColor:[UIColor clearColor]];
 
 CAGradientLayer *grad = [CAGradientLayer layer];
 grad.frame = cell.bounds;
 grad.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
 
 [cell setBackgroundView:[[UIView alloc] init]];
 [cell.backgroundView.layer insertSublayer:grad atIndex:0];
 
 CAGradientLayer *selectedGrad = [CAGradientLayer layer];
 selectedGrad.frame = cell.frame;
 selectedGrad.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
 
 [cell setSelectedBackgroundView:[[UIView alloc] init]];
 [cell.selectedBackgroundView.layer insertSublayer:selectedGrad atIndex:0];
 */

#pragma mark - Navigation
-(void) pushNextViewController:(UIButton *)sender {
    [sender setBackgroundColor:[UIColor clearColor]];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WelcomeViewShown"];
    [UIView animateWithDuration:1.0 animations:^{
        [self.welcomeView removeFromSuperview];
    }];
    
}
#pragma mark - Sync from Parse Methods
- (void) syncFromParse {
    if (DBG) NSLog(@"syncFromParse -- getting the coreFriends");     // sync from parse!
    
    //if (DBG) NSLog(@"Current user: %@", [PFUser currentUser].username);
    
    NSMutableDictionary *udCoreCircleDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"CoreFriendsContactInfoDicKey"];
    if ([udCoreCircleDictionary count] == 0 || udCoreCircleDictionary == NULL)
    {
        [PFUser logInWithUsernameInBackground:[[NSUserDefaults standardUserDefaults] objectForKey:@"adminID"]
                                     password:[[NSUserDefaults standardUserDefaults] objectForKey:@"adminPass"]
                                        block:^(PFUser *user, NSError *error) {
                                            
                                            if (user) {
                                                if (DBG) NSLog(@"[ Parse successful login ]"); // Do stuff after successful login.
                                                // sync from parse!
                                                //[self syncExistingCoreFriendsFromParseForUser:user];
                                                PFQuery * pfquery = [PFQuery queryWithClassName:@"CoreFriendRequest"];
                                                [pfquery whereKey:  @"sender" equalTo:user];
                                                [pfquery includeKey:@"recipient"];
                                                [pfquery findObjectsInBackgroundWithBlock:^(NSArray *objects,
                                                                                            NSError *error)
                                                {
                                                    if (!error) {
                                                        //if (DBG) NSLog(@"number of sent requests: %ld",objects.count);
                                                        //if (DBG) NSLog(@"%@",objects);
                                                        for (PFObject *object in objects) {
                                                            if (DBG) NSLog(@"of: %@", [object objectForKey:@"recipientName"]);
                                                            [self.coreCircleOfFriends addObject:[object objectForKey:@"recipientName"]];
                                                            PFUser *pUser = [object objectForKey:@"recipient"];
                                                            [self.coreCircleContacts  addObject:[pUser objectForKey:@"phoneNumber"]];
                                                            if (self.coreCircleContacts.count ==3){
                                                                [self coreFriendsListToPersistentStorage];
                                                                break;
                                                            }
                                                        }
                                                        
                                                    }
                                                }];
                                                PFQuery *query = [PFQuery queryWithClassName:@"CoreFriendNotOnFriensoYet"];
                                                [query whereKey:  @"sender" equalTo:user];
                                                [query includeKey:@"recipient"];
                                                [query findObjectsInBackgroundWithBlock:^(NSArray *objects,
                                                                                            NSError *error)
                                                 {
                                                     if (!error) {
                                                         //if (DBG) NSLog(@"number of sent requests to users not on frienso: %ld",objects.count);
                                                         //if (DBG) NSLog(@"%@",objects);
                                                         for (PFObject *object in objects) {
                                                             if (DBG) NSLog(@"nof: %@", [object objectForKey:@"recipientName"]);
                                                             [self.coreCircleOfFriends addObject:[object objectForKey:@"recipientName"]];
                                                             //PFUser *pUser = [object objectForKey:@"recipient"];
                                                             [self.coreCircleContacts  addObject:[object objectForKey:@"recipientPhoneNumber"]];
                                                             if (self.coreCircleContacts.count ==3)
                                                             {
                                                                 if (DBG) NSLog(@"Save coreFriends to NSUserDefs and to CoreFriends");
                                                                 [self coreFriendsListToPersistentStorage];
                                                                 break;
                                                             }
                                                         }
                                                     }
                                                 }];
                                                // Notify that records were fetched from Parse
                                                [self  actionAddFriensoEvent:@"Your Core Friends fetched and restored."
                                                                withSubtitle:@"Select the Friends icon to review the list"];
                                                
                                                /********************************************
                                                PFQuery *query = [PFQuery queryWithClassName:@"UserCoreFriends"];
                                                [query whereKey:@"user" equalTo:user];
                                                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
                                                 {
                                                     if (!error) { // The find succeeded.
                                                         NSDictionary *parseCoreFriendsDic = [[NSDictionary alloc] init];
                                                         for (PFObject *object in objects) {
                                                             parseCoreFriendsDic = [object valueForKey:@"userCoreFriends"];
                                                             
                                                         }
                                                         if ( parseCoreFriendsDic != NULL) {
                                                             // Save core friends dictionary to NSUserDefaults
                                                             [self saveCFDictionaryToNSUserDefaults:parseCoreFriendsDic];
                                                             self.coreFriendsArray = [[NSMutableArray alloc] initWithArray:[parseCoreFriendsDic allKeys]];
                                                             
                                                             // cache those uWatch
                                                             //[[[FRSyncFriendConnections alloc] init] syncUWatchToCoreFriends]; // Sync those uWatch
                                                 
                                                         }
                                                         // Notify that records were fetched from Parse
                                                         [self  actionAddFriensoEvent:@"Contacts successfully fetched and restored."];
                                                     } else {
                                                         // Log details of the failure
                                                         if (DBG) NSLog(@"!Error: %@ %@", error, [error userInfo]);
                                                     }
                                                 }];
                                                ********************************************/
                                                
                                            } else {
                                                if (DBG) NSLog(@"[ ERROR: Login failed | %@",error);// The login failed. Check error to see why.
                                            }
                                        }];
    }// testing if core circle dic is in nsuserdefaults
    else        if (DBG) NSLog(@"not nil");
}
- (void) coreFriendsListToPersistentStorage {
    
    if(DBG) NSLog(@"%@", self.coreCircleOfFriends);
    if(DBG) NSLog(@"%@", self.coreCircleContacts);
    
    NSDictionary *dic = [[NSDictionary alloc] initWithObjects:self.coreCircleContacts forKeys:self.coreCircleOfFriends];
    if(DBG) NSLog(@"%@", dic);
    
    [self saveCFDictionaryToNSUserDefaults:dic];
}
-(void) saveCFDictionaryToNSUserDefaults:(NSDictionary *)friendsDic {
    // From Parse
    if(DBG) NSLog(@"[ saveCFDictionaryToNSUserDefaults ]");
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:friendsDic forKey:@"CoreFriendsContactInfoDicKey"];
    [userDefaults synchronize];
    
    // Save dictionary to CoreFriends Entity (CoreData)
    NSArray *coreCircle = [friendsDic allKeys];   // holds names
    NSArray *valueArray = [friendsDic allValues]; // holds phone numbers

    
    // Access to CoreData
    for (int i=0; i<[coreCircle count]; i++) {
       CoreFriends *cFriends = [NSEntityDescription insertNewObjectForEntityForName:@"CoreFriends"
                                                             inManagedObjectContext:[self managedObjectContext]];
        if (cFriends != nil){
            cFriends.coreFirstName = [coreCircle objectAtIndex:i];
            cFriends.corePhone     = [valueArray objectAtIndex:i];
            cFriends.coreCreated   =  [NSDate date];
            cFriends.coreModified  = [NSDate date];
            cFriends.coreType      = @"iCore Friends";
            
            NSError *savingError = nil;
            if ([[self managedObjectContext] save:&savingError]){
                if (DBG) if (DBG) NSLog(@"Successfully saved contacts to CoreCircle.");
            } else {
                if (DBG) NSLog(@"Failed to save the managed object context.");
            }
        } else {
            if (DBG) NSLog(@"Failed to create the new person object.");
        }
    }
    
}
- (void) actionAddFriensoEvent:(NSString *) message {
    if (DBG) NSLog(@"[ actionAddFriensoEvent ]");
    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    
    FriensoEvent *firstFriensoEvent = [NSEntityDescription insertNewObjectForEntityForName:@"FriensoEvent"
                                                                    inManagedObjectContext:managedObjectContext];
    
    if (firstFriensoEvent != nil){
        NSString *loginFriensoEvent = @"";
        firstFriensoEvent.eventTitle     = [loginFriensoEvent stringByAppendingString:message];
        firstFriensoEvent.eventSubtitle  = @"Review these data";
        firstFriensoEvent.eventLocation  = @"Right here";
        firstFriensoEvent.eventContact   = @"me";
        firstFriensoEvent.eventCreated   = [NSDate date];
        firstFriensoEvent.eventModified  = [NSDate date];
        
        NSError *savingError = nil;
        if([managedObjectContext save:&savingError]) {
            if (DBG) NSLog(@"Successfully saved the context");
        } else { if (DBG) NSLog(@"Failed to save the context. Error = %@", savingError); }
    } else {
        if (DBG) NSLog(@"Failed to create a new event.");
    }
    //[self configureOverlay]; if (DBG) NSLog(@"calling configureOverlay");
    
}
- (void) syncExistingCoreFriendsFromParseForUser:(PFUser*)thisUser
{
    
    ///update status from Parse:
    PFQuery * pfquery = [PFQuery queryWithClassName:@"CoreFriendRequest"];
    [pfquery includeKey:@"recipient"];
    [pfquery whereKey:  @"sender" equalTo:[PFUser currentUser]];
    [pfquery findObjectsInBackgroundWithBlock:^(NSArray *objects,
                                                NSError *error) {
        NSInteger i = 0;
        int activeCoreFriends = 0;
        if(!error) {
            if([objects count] >0) {//if atleast one record is found, then only we want to
                //reload the table view
                //if (DBG) NSLog(@"no of core friend req's: %ld",objects.count);
                for (id object in objects) {
                    if (DBG) NSLog(@"Number of active friends %d",activeCoreFriends);
                    if(activeCoreFriends >= MAX_CORE_FRIENDS) {
                        if (DBG) NSLog(@"Atleast %d  core friends found in frienso",MAX_CORE_FRIENDS);
                        break;
                    }
                    //PFObject * pfobject = object;
                    PFUser * sender = [object objectForKey:@"recipient"];
                    NSString *senderPhoneNumber = sender[@"phoneNumber"];
                    NSString *response = [object objectForKey:@"status"];
                    NSString *senderName = [object objectForKey:@"recipientName"];
                    [self.coreCircleRequestStatus replaceObjectAtIndex:i withObject:coreFriendRequestSendMessage];
                    [self.coreCircleContacts replaceObjectAtIndex:i withObject:senderPhoneNumber];
                    [self.coreCircleOfFriends replaceObjectAtIndex:i withObject:senderName];
                    
                    //if (DBG) NSLog(@"> %@,%@,%@,%@",sender, senderName,response, senderPhoneNumber);
                    
                    if([response isEqualToString:@"send"]) {
                        [self.coreCircleRequestStatus replaceObjectAtIndex:i withObject:coreFriendRequestSendMessage];
                    } else if ([response isEqualToString:@"reject"]) {
                        [self.coreCircleRequestStatus replaceObjectAtIndex:i withObject:coreFriendRejectMessage];
                    } else  if([response isEqualToString:@"accept"]) {
                        [self.coreCircleRequestStatus replaceObjectAtIndex:i withObject:coreFriendAcceptMessage];
                    } else {
                        [self.coreCircleRequestStatus replaceObjectAtIndex:i withObject:response];
                    }
                    i++;
                    activeCoreFriends++;
                    
                }
            }
            
            //only if max are not found.
//            if(activeCoreFriends < MAX_CORE_FRIENDS) {
//                
//                // check if the contact is pending list, then show that information
//                PFQuery * pfquery = [PFQuery queryWithClassName:@"CoreFriendNotOnFriensoYet"];
//                [pfquery whereKey:@"sender" equalTo:[PFUser currentUser]];
//                // [pfquery whereKey:@"recipientPhoneNumber" containedIn:self.coreCircleContacts];
//                [pfquery findObjectsInBackgroundWithBlock:^(NSArray *objects,
//                                                            NSError *error) {
//                    if(!error) {
//                        int i = activeCoreFriends;
//                        if([objects count] >0) {//if atleast one record is found, then only we want to
//                            //reload the table view
//                            for (id object in objects) {
//                                if(activeCoreFriends >= MAX_CORE_FRIENDS) {
//                                    if (DBG) NSLog(@"Atleast %d  core friends found",MAX_CORE_FRIENDS);
//                                    break;
//                                }
//                                
//                                NSString *senderPhoneNumber = (NSString *)object[@"recipientPhoneNumber"];
//                                NSString *senderName = [object objectForKey:@"recipientName"];
//                                [self.coreCircleContacts replaceObjectAtIndex:i withObject:senderPhoneNumber];
//                                [self.coreCircleOfFriends replaceObjectAtIndex:i withObject:senderName];
//                                [self.coreCircleRequestStatus replaceObjectAtIndex:i withObject:coreFriendNotOnFriensoMessage];
//                                i++;
//                                activeCoreFriends++;
//                            }
//                        }
//                    }else {
//                        if (DBG) NSLog(@"%@",error);
//                    }
//                    //[self refresh];
//                }];
//            } else {
//                //[self refresh];
//            }
        } else {
            if (DBG) NSLog(@"%@",error);
        }
    }];

}
#pragma mark - Helper methods
- (NSString *) stripStringOfUnwantedChars:(NSString *)phoneNumberString {
     NSString *cleanedString = [[phoneNumberString componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
     return cleanedString;
 }
                 
@end
