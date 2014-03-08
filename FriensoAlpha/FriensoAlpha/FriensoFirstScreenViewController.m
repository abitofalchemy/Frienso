//
//  FriensoFirstScreenViewController.m
//  FriensoAlpha
//
//  Created by Sal Aguinaga on 2/27/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "FriensoFirstScreenViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "FriensoViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@interface FriensoFirstScreenViewController ()
{
    IBOutlet UILabel *welcomeLabel;
    IBOutlet UIButton *chngTheWorldBtn;
}
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UIButton *chngTheWorldBtn;

@end

@implementation FriensoFirstScreenViewController
@synthesize welcomeLabel = _welcomeLabel;
@synthesize chngTheWorldBtn = _chngTheWorldBtn;


- (void) CheckUserDefaults {
    NSLog(@"check userdefaults");
    NSString       *adminKey    = [[NSUserDefaults standardUserDefaults] objectForKey:@"adminID"];
    if ([adminKey isEqualToString:@""] || adminKey == NULL){
        NSLog(@"[0]");
        return;
    } else {
        NSLog(@"[ jumping to the dashboard ]");
        [self popDashboardVC];
        
    }
}

-(void) popDashboardVC{
//    FriensoViewController *dashboardVC = [[FriensoViewController alloc] init];
//    dashboardVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//    UINavigationController *navigationController = [[UINavigationController alloc] init];
////    [navigationController setViewControllers:@{dashboardVC} animated:YES]
//    //[self presentViewController:navigationController animated:YES completion:nil];
//    [self.navigationController pushViewController:navigationController animated:YES];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"  bundle:nil];
    FriensoViewController  *dashboardVC = (FriensoViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"dashboardVC"];
    [self.navigationController pushViewController:dashboardVC animated:NO];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewDidAppear:(BOOL)animated {
    
    NSLog(@"view did appear");
    [UIView animateWithDuration:1.0 animations:^{
        self.navigationController.navigationBarHidden = YES;
        // This will fix the view from being framed underneath the navigation bar and status bar.
        self.navigationController.navigationBar.translucent = YES;
        [super viewDidAppear:YES];
    }];
    
}

-(void) setupTopLabel{
    welcomeLabel = [[UILabel alloc] init];
    welcomeLabel.backgroundColor = [UIColor clearColor];
    welcomeLabel.text = @"Panic Alert!";
    welcomeLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:24.0];
    welcomeLabel.textColor = [UIColor blackColor];
    welcomeLabel.shadowColor = [UIColor lightGrayColor];
    welcomeLabel.shadowOffset = CGSizeMake(2.0f, 2.0f);
    [welcomeLabel sizeToFit];
    
    welcomeLabel.center = CGPointMake(self.view.center.x,self.view.bounds.size.height*0.8);
    [self.view addSubview:welcomeLabel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self CheckUserDefaults];
    
    // This will fix the view from being framed underneath the navigation bar and status bar.
    self.navigationController.navigationBar.translucent = YES;
    
    [[self view] setBackgroundColor: [UIColor colorWithPatternImage: [UIImage imageNamed:@"first-view-cover.png"]]];
    
    /** Animate the baground experimental
    CABasicAnimation* fade = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    fade.fromValue = (id)[UIColor whiteColor].CGColor;
    fade.toValue = (id)[UIColor blackColor].CGColor;
    [fade setDuration:5];
    [self.view.layer addAnimation:fade forKey:@"fadeAnimation"];
    
	[UIView animateWithDuration:5.0 animations:^{
        self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"first-view-cover-2.png"]];
    } completion:^(BOOL finished)
     {
         self.view.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"first-view-cover-3.png"]];
     }];
    **/
    
    [self setupTopLabel];
    
    UIButton *button= [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, self.view.bounds.size.width/2.0f, 50);
    [button.titleLabel setTextColor:[UIColor whiteColor]];
    [button.titleLabel setTintColor:[UIColor whiteColor]];
    [button addTarget:self action:@selector(popDashboardVC) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Start Frienso" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:16.0]];
    button.layer.cornerRadius = 6.0f;
    button.layer.borderWidth = 1.2f;
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    button.backgroundColor = UIColorFromRGB(0x4962D6);
    [button setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2,
                                  [UIScreen mainScreen].bounds.size.height*0.9)];
    [self.view addSubview:button];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
