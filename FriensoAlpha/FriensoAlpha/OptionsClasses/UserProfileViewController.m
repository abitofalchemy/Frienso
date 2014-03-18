//
//  UserProfileViewController.m
//  FriensoAlpha
//
//  Created by Sal Aguinaga on 3/9/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "UserProfileViewController.h"
#import "CoreCircleTVC.h"


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]




@interface UserProfileViewController ()

@end

@implementation UserProfileViewController

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
- (void) editProfile:(id)sender
{
    NSLog(@"edit Profile");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;   // iOS 7 specific
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupNavigationBarWidget];
    
    // Profile photo
    UIImageView *profilePhoto =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profile-landscape-1.png"]];
    [profilePhoto setFrame:CGRectMake(0, 0,self.view.bounds.size.width, self.view.bounds.size.width/2)];
    profilePhoto.layer.borderColor  = [UIColor whiteColor].CGColor;
    profilePhoto.contentMode = UIViewContentModeScaleAspectFill;
    /*
    profilePhoto.layer.borderWidth  = 1.0f;
    profilePhoto.layer.cornerRadius = 8.0f;
    profilePhoto.layer.borderColor = [UIColor lightGrayColor].CGColor;*/
    [self.view addSubview:profilePhoto];
    /*
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width*0.85, 40)];
    [label setText:@"Change your profile photo"];
    [label sizeToFit];
    label.center = CGPointMake(self.view.center.x, self.view.bounds.size.height*0.25+10.0);
    [label setTextAlignment:NSTextAlignmentCenter];
    //    [label setTextColor:[UIColor blackColor]];
    [label setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:16.0]];
    [self.view addSubview:label];
    */
    
    // Credentials
    NSString *userInfo = [NSString stringWithFormat:@"UserName: %@\nEmail: %@\nPhone: %@\n"
                                                     "First Name: %@\nLast Name: %@",
                          [[NSUserDefaults standardUserDefaults] objectForKey:@"userEmail"],
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
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width*0.9, self.view.bounds.size.height*0.20)
                                               textContainer:textContainer];
    // Add text view to the main view of the view controler
    [textView setCenter:CGPointMake(self.view.center.x, profilePhoto.center.y +
                                    profilePhoto.bounds.size.height/2 +
                                    30.0 + textView.bounds.size.height/2)];
    [self.view addSubview:textView];
    
    
    // Edit Button
    UIButton *editProfileBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 35)];
    [editProfileBtn setTitle:@"Core Friends" forState:UIControlStateNormal];
    
    [editProfileBtn addTarget:self
                  action:@selector(coreFriendsAction:)
        forControlEvents:UIControlEventTouchUpInside];
    [editProfileBtn.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:16.0]];
    editProfileBtn.layer.cornerRadius = 6.0f;
    editProfileBtn.layer.borderWidth = 0.5f;
    editProfileBtn.layer.borderColor = [UIColor blackColor].CGColor;
    editProfileBtn.layer.backgroundColor = [UIColor colorWithRed:250/255.00f
                                                           green:244/250.00f
                                                            blue:250/255.00f
                                                           alpha:0.7f].CGColor;
    [editProfileBtn setCenter:CGPointMake(self.view.center.x, self.view.center.y)];
    [editProfileBtn.titleLabel setTextColor:[UIColor blackColor]];
    [self.view addSubview:editProfileBtn];
 
    
    [UIView animateWithDuration:0.8 animations:^{
        [editProfileBtn setCenter:CGPointMake(self.view.center.x, self.view.bounds.size.height*0.8)];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
