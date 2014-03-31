//
//  UserProfileViewController.m
//  FriensoAlpha
//
//  Created by Sal Aguinaga on 3/9/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "UserProfileViewController.h"
#import "CoreCircleTVC.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]




@interface UserProfileViewController ()  <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    UIButton *viewYourCoreCircleBtn;
    UITableView *miniTableView;
}
@property (nonatomic,strong) UIButton *viewYourCoreCircleBtn;
@property (nonatomic,strong) UITextField *firstNameField;
@property (nonatomic,strong) UITextField *lastNameField;
@property (nonatomic,strong) UITextField *userNameField;
@property (nonatomic,strong) UITextField *phoneNumberField;
@property (nonatomic,strong) UITableView *miniTableView;
@property (nonatomic,strong) UITextView  *textView;
@property (nonatomic,strong) UITableViewCell     *profileImageCell;
@end

@implementation UserProfileViewController
@synthesize viewYourCoreCircleBtn = _viewYourCoreCircleBtn;
@synthesize miniTableView = _miniTableView;
//######################################

- (void) setText:(NSString *)paramText{
    self.title = paramText;
}

- (void) coreFriendsAction:(id) sender {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"  bundle:nil];
    CoreCircleTVC  *coreCircleController = (CoreCircleTVC*)[mainStoryboard instantiateViewControllerWithIdentifier: @"coreCircleView"];
    [self.navigationController pushViewController:coreCircleController animated:YES];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) setupNavigationBarWidget
{
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editProfile:)];
    
    self.navigationItem.rightBarButtonItem=rightBtn;
}
- (void) editProfile:(UIBarButtonItem*)sender
{
    printf("[ Edit Profile ]\n");
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    // change back button [self.navigationItem.backBarButtonItem setTitle:@"Cancel"];
    
    
    miniTableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    miniTableView.delegate = self;
    miniTableView.dataSource = self;
    [miniTableView setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:miniTableView];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;   // iOS 7 specific
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupNavigationBarWidget];
    
//    // Profile photo
//    UIImageView *profilePhoto =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile-landscape-1.png"]];
//    [profilePhoto setFrame:CGRectMake(0, 0,self.view.bounds.size.width, self.view.bounds.size.width/2)];
//    profilePhoto.layer.borderColor  = [UIColor whiteColor].CGColor;
//    profilePhoto.contentMode = UIViewContentModeScaleAspectFill;
//    /*
//    profilePhoto.layer.borderWidth  = 1.0f;
//    profilePhoto.layer.cornerRadius = 8.0f;
//    profilePhoto.layer.borderColor = [UIColor lightGrayColor].CGColor;*/
//    [self.view addSubview:profilePhoto];
//    /*
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width*0.85, 40)];
//    [label setText:@"Change your profile photo"];
//    [label sizeToFit];
//    label.center = CGPointMake(self.view.center.x, self.view.bounds.size.height*0.25+10.0);
//    [label setTextAlignment:NSTextAlignmentCenter];
//    //    [label setTextColor:[UIColor blackColor]];
//    [label setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:16.0]];
//    [self.view addSubview:label];
//    */
//    
//    // Credentials
//    self.userInfo = [NSString stringWithFormat:@"UserName: %@\nEmail: %@\nPhone: %@\n"
//                                                     "First Name: %@\nLast Name: %@",
//                     ([[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]== NULL) ? [[NSUserDefaults standardUserDefaults] objectForKey:@"userEmail"] : [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],
//                          [[NSUserDefaults standardUserDefaults] objectForKey:@"userEmail"],
//                          [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhone"],
//                          ([[NSUserDefaults standardUserDefaults] objectForKey:@"userFName"] == NULL) ? @"" : [[NSUserDefaults standardUserDefaults] objectForKey:@"userFName"],
//                          ([[NSUserDefaults standardUserDefaults] objectForKey:@"userLName"] == NULL) ? @"" : [[NSUserDefaults standardUserDefaults] objectForKey:@"userLName"]];
//                          
//    NSAttributedString *textString =  [[NSAttributedString alloc] initWithString:_userInfo attributes:@{
//                                                                                                       NSFontAttributeName: [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:18]
//                                                                                                       }];
//    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:textString];
//    NSLayoutManager *textLayout = [[NSLayoutManager alloc] init];
//    // Add layout manager to text storage object
//    [textStorage addLayoutManager:textLayout];
//    // Create a text container
//    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.view.bounds.size];
//    // Add text container to text layout manager
//    [textLayout addTextContainer:textContainer];
//    // Instantiate UITextView object using the text container
//    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width*0.9, self.view.bounds.size.height*0.20)
//                                               textContainer:textContainer];
//    // Add text view to the main view of the view controler
//    [textView setCenter:CGPointMake(self.view.center.x, profilePhoto.center.y +
//                                    profilePhoto.bounds.size.height/2 +
//                                    30.0 + textView.bounds.size.height/2)];
//    [self.view addSubview:textView];
    [self setProfileViewContent];
    
    // Edit Button
    viewYourCoreCircleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 35)];
    [viewYourCoreCircleBtn setTitle:@"Core Friends" forState:UIControlStateNormal];
    
    [viewYourCoreCircleBtn addTarget:self
                  action:@selector(coreFriendsAction:)
        forControlEvents:UIControlEventTouchUpInside];
    [viewYourCoreCircleBtn.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:16.0]];
    viewYourCoreCircleBtn.layer.cornerRadius = 6.0f;
    viewYourCoreCircleBtn.layer.borderWidth = 0.5f;
    viewYourCoreCircleBtn.layer.borderColor = [UIColor blackColor].CGColor;
    viewYourCoreCircleBtn.layer.backgroundColor = [UIColor colorWithRed:250/255.00f
                                                           green:244/250.00f
                                                            blue:250/255.00f
                                                           alpha:0.7f].CGColor;
    [viewYourCoreCircleBtn setCenter:CGPointMake(self.view.center.x, self.view.center.y)];
    [viewYourCoreCircleBtn.titleLabel setTextColor:[UIColor blackColor]];
    [self.view addSubview:viewYourCoreCircleBtn];
 
    
    [UIView animateWithDuration:0.8 animations:^{
        [viewYourCoreCircleBtn setCenter:CGPointMake(self.view.center.x, self.view.bounds.size.height*0.8)];
    }];
    
    /** gestures **/
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:nil usingBlock:^(NSNotification *notification) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [self.view addGestureRecognizer:tap];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *notification) {
        [self.view removeGestureRecognizer:[self.view.gestureRecognizers lastObject]];
    }];
    /** end gestures dismisses the keyboard nicely **/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - TableView delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 5;
    else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"Cell"];
    }
    
    if (indexPath.section == 0 ) {
        
    switch (indexPath.row) {
//#warning Find a way to fetch a picture from an assets url
        case 0:
        {
            NSURL *assetURL = [[NSUserDefaults standardUserDefaults] URLForKey:@"profileImageUrl"];
            ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
            UIImage __block *thumbImg = nil;
            [assetLibrary assetForURL:assetURL
                          resultBlock:^(ALAsset *asset) {
                thumbImg = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]
                                               scale:0.5
                                         orientation:UIImageOrientationUp];
//                cell.backgroundView = [[UIImageView alloc] initWithImage:copyOfOriginalImage];
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.imageView.image = thumbImg;
                    });
            } failureBlock:^(NSError *err) {
                cell.imageView.image = [UIImage imageNamed:@"Profile-256.png"];
                NSLog(@"Error: %@",[err localizedDescription]);
            }];
            if (thumbImg == nil)
                cell.imageView.image = [UIImage imageNamed:@"Profile-256.png"];
            
            cell.textLabel.text = @"Picture";
            self.profileImageCell = cell;
            break;
        }
        case 1:
            cell.textLabel.text = @"First Name:";
            self.firstNameField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, cell.bounds.size.width*0.5, cell.bounds.size.width*0.95)];
            NSLog(@"hello:%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userFName"]);
            if (([[NSUserDefaults standardUserDefaults] objectForKey:@"userFName"] == NULL) ||
                ([[[NSUserDefaults standardUserDefaults] objectForKey:@"userFName"] isEqualToString:@""]))
                [self.firstNameField setPlaceholder:@"Enter your first name"];
            else
                [self.firstNameField setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"userFName"]];
            cell.accessoryView = self.firstNameField;
            break;
        case 2:
            cell.textLabel.text = @"Last Name:";
            self.lastNameField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, cell.bounds.size.width*0.5, cell.bounds.size.width*0.95)];
            if (([[NSUserDefaults standardUserDefaults] objectForKey:@"userLName"] == NULL) ||
                ([[[NSUserDefaults standardUserDefaults] objectForKey:@"userFName"] isEqualToString:@""]))
                [self.lastNameField setPlaceholder:@"Enter your last name"];
            else
                [self.lastNameField setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"userLName"]];
            cell.accessoryView = self.lastNameField;
            break;
        case 3:
            cell.textLabel.text = @"Username:";
            self.userNameField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, cell.bounds.size.width*0.5, cell.bounds.size.width*0.95)];
            if (([[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] == NULL) ||
                ([[[NSUserDefaults standardUserDefaults] objectForKey:@"userFName"] isEqualToString:@""]))
                [self.userNameField setPlaceholder:@"Enter your Username"];
            else
                [self.userNameField setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]];
            self.userNameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            cell.accessoryView = self.userNameField;
            break;
        case 4:
            cell.textLabel.text = @"Phone Number:";
            self.phoneNumberField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, cell.bounds.size.width*0.5, cell.bounds.size.width*0.95)];
            if (([[NSUserDefaults standardUserDefaults] objectForKey:@"userPhone"] == NULL) ||
                ([[[NSUserDefaults standardUserDefaults] objectForKey:@"userFName"] isEqualToString:@""]))
                [self.phoneNumberField setPlaceholder:@"Enter your phone number"];
            else
                [self.phoneNumberField setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"userPhone"]];
            self.phoneNumberField.keyboardType = UIKeyboardTypePhonePad;
            self.phoneNumberField.returnKeyType = UIReturnKeyDone;
            cell.accessoryView = self.phoneNumberField;
            break;
        default:
            break;
    }
    } else {
        
        UILabel *saveDoneLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        saveDoneLabel.text = @"Save";
        
        saveDoneLabel.textAlignment = NSTextAlignmentCenter;
        saveDoneLabel.textColor = UIColorFromRGB(0x4962D6);
        [saveDoneLabel sizeToFit];
        
        cell.accessoryView      = saveDoneLabel;
        cell.backgroundColor    = [UIColor clearColor];
        
        
    }
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:16.0];
    cell.backgroundColor = [UIColor clearColor];
    
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        // Prompt user to pick a photo out of the photo library
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        
        imagePicker.delegate = self;
        
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypePhotoLibrary;
        
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        
        imagePicker.allowsEditing = YES;
        [self presentViewController:imagePicker
                           animated:YES completion:nil];
    }
    else if (indexPath.section == 1){
        // save and dismiss the view
        [self dismissTableView];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
        NSLog(@"%@",self.firstNameField.text);
        [[NSUserDefaults standardUserDefaults] setObject:self.firstNameField.text forKey:@"userFName"];
        NSLog(@"%@",self.lastNameField.text);
        [[NSUserDefaults standardUserDefaults] setObject:self.lastNameField.text forKey:@"userLName"];
        NSLog(@"%@",self.userNameField.text);
        [[NSUserDefaults standardUserDefaults] setObject:self.userNameField.text forKey:@"userName"];
        NSLog(@"%@",self.phoneNumberField.text);
        [[NSUserDefaults standardUserDefaults] setObject:self.phoneNumberField.text forKey:@"userPhone"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.textView removeFromSuperview];
        self.textView = nil;
        [self setProfileViewContent];
    }
}

#pragma mark - TextField delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)dismissKeyboard:(UIGestureRecognizer *)gesture
{
    [self.view endEditing:NO];
}
#pragma mark - Helper View Methods 
-(void) dismissTableView {
    [miniTableView removeFromSuperview];
    self.miniTableView = nil;
}

-(void) setProfileViewContent {
    // Profile photo
    UIImageView __block  *profilePhoto = [[UIImageView alloc] initWithFrame:CGRectZero];
    NSURL *assetURL = [[NSUserDefaults standardUserDefaults] URLForKey:@"profileImageUrl"];
    ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
    UIImage __block *thumbImg = nil;
    [assetLibrary assetForURL:assetURL
                  resultBlock:^(ALAsset *asset) {
                      thumbImg = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]
                                                     scale:0.5
                                               orientation:UIImageOrientationUp];
                      //                cell.backgroundView = [[UIImageView alloc] initWithImage:copyOfOriginalImage];
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [profilePhoto setImage:thumbImg];
                      });
                  } failureBlock:^(NSError *err) {
                      //profilePhoto =[[UIImageView alloc] initWithImage:[UIImage imageNamed::@"Profile-256.png"];
                      NSLog(@"Error: %@",[err localizedDescription]);
                  }];
    if (profilePhoto == nil)
        [profilePhoto setImage:[UIImage imageNamed:@"profile-landscape-1.png"]];
    [profilePhoto setFrame:CGRectMake(0, 0,self.view.bounds.size.width, self.view.bounds.size.width/2)];
    profilePhoto.layer.borderColor  = [UIColor whiteColor].CGColor;
    profilePhoto.contentMode = UIViewContentModeScaleAspectFill;
    /*
     profilePhoto.layer.borderWidth  = 1.0f;
     profilePhoto.layer.cornerRadius = 8.0f;
     profilePhoto.layer.borderColor = [UIColor lightGrayColor].CGColor;*/
    [self.view addSubview:profilePhoto];
    
    // Credentials
    NSString *userInfo = [NSString stringWithFormat:@"UserName: %@\nEmail: %@\nPhone: %@\n"
                     "First Name: %@\nLast Name: %@",
                     ([[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]== NULL) ? [[NSUserDefaults standardUserDefaults] objectForKey:@"userEmail"] : [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"],
                     [[NSUserDefaults standardUserDefaults] objectForKey:@"userEmail"],
                     [[NSUserDefaults standardUserDefaults] objectForKey:@"userPhone"],
                     ([[NSUserDefaults standardUserDefaults] objectForKey:@"userFName"] == NULL) ? @"" : [[NSUserDefaults standardUserDefaults] objectForKey:@"userFName"],
                     ([[NSUserDefaults standardUserDefaults] objectForKey:@"userLName"] == NULL) ? @"" : [[NSUserDefaults standardUserDefaults] objectForKey:@"userLName"]];
    NSAttributedString *textString =  [[NSAttributedString alloc] initWithString:userInfo attributes:@{
                                                                                                        NSFontAttributeName: [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:18]
                                                                                                        }];
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:textString];
    NSLayoutManager *textLayout = [[NSLayoutManager alloc] init];
    // Add layout manager to text storage object
    [textStorage addLayoutManager:textLayout];
    // Create a text container
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.view.bounds.size];
    // Add text container to text layout manager
    [textLayout addTextContainer:textContainer];
    // Instantiate UITextView object using the text container
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width*0.9, self.view.bounds.size.height*0.20)
                                               textContainer:textContainer];
    [self.textView sizeToFit];
    // Add text view to the main view of the view controler
    [self.textView setCenter:CGPointMake(self.view.center.x, profilePhoto.center.y +
                                    profilePhoto.bounds.size.height/2 +
                                    30.0 + self.textView.bounds.size.height/2)];
    [self.view addSubview:self.textView];
}
#pragma mark - UIImagePicker Methods
-(void)imagePickerController:
(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Code here to work with media
    NSLog(@"%@", info);
    self.profileImageCell.imageView.image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    [[NSUserDefaults standardUserDefaults] setURL:[info objectForKey:@"UIImagePickerControllerReferenceURL"]
                                               forKey:@"profileImageUrl"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.miniTableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:
(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
