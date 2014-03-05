//
//  ProfileViewController.m
//  FriensoAlpha
//
//  Created by Sal Aguinaga on 3/3/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "ProfileViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]



@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void) setText:(NSString *)paramText{
    self.title = paramText;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)loadView{
    // This will fix the view from being framed underneath the navigation bar and status bar.
    self.navigationController.navigationBar.translucent = NO;
    
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = UIColorFromRGB(0xF6E4CC);
    self.view = contentView;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width*0.85, 40)];
    [label setText:@"Change your profile photo"];
    [label sizeToFit];
    label.center = CGPointMake(self.view.center.x, self.view.bounds.size.height*0.25+10.0);
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:14.0]];
    [self.view addSubview:label];
    
    // Profile photo
    UIImageView *profilePhoto =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Profile-256.png"]];
    [profilePhoto setFrame:CGRectMake(0, 0,self.view.bounds.size.width, self.view.bounds.size.height*0.25)];
    profilePhoto.layer.borderColor  = [UIColor whiteColor].CGColor;
    profilePhoto.contentMode = UIViewContentModeScaleAspectFit;
    profilePhoto.layer.borderWidth  = 1.0f;
    profilePhoto.layer.cornerRadius = 8.0f;
    [self.view addSubview:profilePhoto];
    
    // Credentials
    NSString *userInfo = [NSString stringWithFormat:@"Name: %@\nEmail: %@", @"Sal",@"saguinag@nd.edu"];
    NSAttributedString *textString =  [[NSAttributedString alloc] initWithString:userInfo attributes:@{
                                                                                                             NSFontAttributeName: [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:12]
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
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height*0.20)
                                               textContainer:textContainer];
    // Add text view to the main view of the view controler
    [textView setCenter:CGPointMake(self.view.center.x, self.view.bounds.size.height*0.41)];
    [self.view addSubview:textView];
    
    
    // Logout
    UIButton *logoutBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 35)];
    [logoutBtn setTitle:@"Logout" forState:UIControlStateNormal];
    
    [logoutBtn addTarget:self
                  action:@selector(logoutAction:)
        forControlEvents:UIControlEventTouchUpInside];
    [logoutBtn.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:16.0]];
    logoutBtn.layer.cornerRadius = 6.0f;
    logoutBtn.layer.borderWidth = 0.5f;
    logoutBtn.layer.borderColor = [UIColor blackColor].CGColor;
//    logoutBtn.layer.backgroundColor = [UIColor colorWithRed:250/255.00f green:244/250.00f
//                                                       blue:250/255.00f alpha:0.7f].CGColor;
    [logoutBtn setCenter:CGPointMake(self.view.center.x, self.view.bounds.size.height*0.8)];
    [logoutBtn.titleLabel setTextColor:[UIColor blackColor]];
    [self.view addSubview:logoutBtn];
    
}
-(void) logoutAction:(id) sender {
    [sender setEnabled:YES];
    NSLog(@"[ logout ]");
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//	// Do any additional setup after loading the view.
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
