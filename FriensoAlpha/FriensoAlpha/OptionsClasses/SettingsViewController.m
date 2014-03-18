//
//  SettingsViewController.m
//  FriensoAlpha
//
//  Created by Sal Aguinaga on 3/3/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "SettingsViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SettingsViewController ()
@property(nonatomic) CGRect buttonFrame;
@end

@implementation SettingsViewController

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
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = UIColorFromRGB(0xecf0f1);
    self.view = contentView;
    
    self.buttonFrame = CGRectMake(0, 0, self.view.frame.size.width/2, 40);
    /*  Tell others about Frienso
     *  Help Center
     *  ? Activity Log
     *  Terms & Policies
     *  Report a Problem
     *  Log Out      
     ********************/
    // Share Frienso
    [self setupShareFrienso];
    
    // Help Center
    [self setupHelpCenter];
    
    // Report a Problem
    [self setupReportProblem];
    
    // Logout Button
    UIButton *logoutBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    [logoutBtn setTitle:@"Logout" forState:UIControlStateNormal];
    
    [logoutBtn addTarget:self
                  action:@selector(logoutAction:)
        forControlEvents:UIControlEventTouchUpInside];
    [logoutBtn.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:16.0]];
    logoutBtn.layer.cornerRadius = 4.0f;
    logoutBtn.layer.borderWidth = 0.75f;
    logoutBtn.layer.borderColor = [UIColor blackColor].CGColor;
    //    logoutBtn.layer.backgroundColor = [UIColor colorWithRed:250/255.00f green:244/250.00f
    //                                                       blue:250/255.00f alpha:0.7f].CGColor;
    [logoutBtn setCenter:CGPointMake(self.view.center.x, self.view.center.y)];
    [logoutBtn.titleLabel setTextColor:[UIColor blackColor]];
    [self.view addSubview:logoutBtn];
    
    // Timer length
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText:@"Alarm Time Duration:"];
    [label setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:14.0]];
    [label sizeToFit];
    label.center = CGPointMake(self.view.center.x * 0.05 + label.frame.size.width/2,
                               self.view.bounds.size.height*0.48);
    [self.view addSubview:label];
    
    UITextField *editAlarmTimer = [[UITextField alloc] initWithFrame:self.buttonFrame];
    [editAlarmTimer setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:16.0]];
    editAlarmTimer.placeholder = @"00:00:15";
    editAlarmTimer.textAlignment = NSTextAlignmentCenter;
    editAlarmTimer.layer.cornerRadius = 6.0f;
    editAlarmTimer.layer.borderWidth = 0.5f;
    editAlarmTimer.layer.borderColor = [UIColor blackColor].CGColor;
    editAlarmTimer.layer.backgroundColor = [UIColor colorWithRed:250/255.00f green:244/250.00f
                                                         blue:250/255.00f alpha:0.7f].CGColor;
    [editAlarmTimer setCenter:CGPointMake(self.view.bounds.size.width - 12 - editAlarmTimer.frame.size.width/2, self.view.center.y)];
    [self.view addSubview:editAlarmTimer];
    
    [UIView animateWithDuration:0.8 animations:^{
        //[editAlarmTimer setCenter:CGPointMake(self.view.center.x, self.view.bounds.size.height*0.5)];
        [logoutBtn setCenter:CGPointMake(self.view.center.x, self.view.bounds.size.height*0.8)];
    }];
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

#pragma mark - setup UI
- (void) setupShareFrienso {
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectZero];
    [label1 setTextAlignment:NSTextAlignmentCenter];
    [label1 setText:@"Tell Others About Frienso:"];
    [label1 setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:14.0]];
    [label1 sizeToFit];
    CGFloat vwidth =self.view.bounds.size.width;
    CGFloat vheight=self.view.bounds.size.height;
    label1.frame = CGRectMake(vwidth *0.05, vheight *0.13,
                              label1.frame.size.width, label1.frame.size.height);
    [self.view addSubview:label1];
    
    UIButton *button = [[UIButton alloc] initWithFrame:self.buttonFrame];
    [button setTitle:@"Share Frienso" forState:UIControlStateNormal];

    [button addTarget:self
                         action:@selector(reportProblemAction:)
               forControlEvents:UIControlEventTouchUpInside];
    [button.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:16.0]];
    button.layer.cornerRadius = 6.0f;
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    //    button.layer.backgroundColor = [UIColor colorWithRed:250/255.00f green:244/250.00f
    //                                                       blue:250/255.00f alpha:0.7f].CGColor;
    [button setCenter:CGPointMake(self.view.bounds.size.width - 12 - button.frame.size.width/2,
                                            self.view.bounds.size.height*0.2)];
    [button.titleLabel setTextColor:UIColorFromRGB(0x2c3e50)];
    [self.view addSubview:button];
}
- (void) setupHelpCenter{
    // Timer length
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectZero];
    [label1 setTextAlignment:NSTextAlignmentCenter];
    [label1 setText:@"Help Center:"];
    [label1 setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:14.0]];
    [label1 sizeToFit];
    label1.center = CGPointMake(self.view.center.x * 0.1 + label1.frame.size.width/2,
                                self.view.bounds.size.height*0.25);
    [self.view addSubview:label1];
    
    UIButton *button = [[UIButton alloc] initWithFrame:self.buttonFrame];
    [button setTitle:@"About Frienso" forState:UIControlStateNormal];

    [button addTarget:self
                         action:@selector(reportProblemAction:)
               forControlEvents:UIControlEventTouchUpInside];
    [button.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:16.0]];
    button.layer.cornerRadius = 6.0f;
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    //    button.layer.backgroundColor = [UIColor colorWithRed:250/255.00f green:244/250.00f
    //                                                       blue:250/255.00f alpha:0.7f].CGColor;
    [button setCenter:CGPointMake(self.view.bounds.size.width - 12 - button.frame.size.width/2, self.view.bounds.size.height*0.3)];
    [button.titleLabel setTextColor:UIColorFromRGB(0x2c3e50)];
    [self.view addSubview:button];
}
- (void) setupReportProblem{
    // Timer length
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectZero];
    [label1 setTextAlignment:NSTextAlignmentCenter];
    [label1 setText:@"Report a Problem:"];
    [label1 setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:14.0]];
    [label1 sizeToFit];
    label1.center = CGPointMake(self.view.center.x * 0.1 + label1.frame.size.width/2,
                               self.view.bounds.size.height*0.35);
    [self.view addSubview:label1];
    
    UIButton *button = [[UIButton alloc] initWithFrame:self.buttonFrame];
    [button setTitle:@"Send us email" forState:UIControlStateNormal];
    [button addTarget:self
                         action:@selector(reportProblemAction:)
               forControlEvents:UIControlEventTouchUpInside];
    [button.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:16.0]];
    button.layer.cornerRadius = 6.0f;
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    //    button.layer.backgroundColor = [UIColor colorWithRed:250/255.00f green:244/250.00f
    //                                                       blue:250/255.00f alpha:0.7f].CGColor;
    [button setCenter:CGPointMake(self.view.bounds.size.width - 12 - button.frame.size.width/2, self.view.bounds.size.height*0.4)];
    [button.titleLabel setTextColor:UIColorFromRGB(0x2c3e50)];
    [self.view addSubview:button];
}

#pragma mark - Actions or selectors
-(void) logoutAction:(id) sender {
    [sender setEnabled:YES];
    NSLog(@"[ logout ]");
//TODO: logout in full
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void) reportProblemAction:(id) sender {
    NSLog(@"[ reporting a problem  ]");
    
}

@end
