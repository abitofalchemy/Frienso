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
    //NSLog(@"check userdefaults");
    NSString       *adminKey    = [[NSUserDefaults standardUserDefaults] objectForKey:@"adminID"];
    if ([adminKey isEqualToString:@""] || adminKey == NULL || adminKey == nil){
        return;
    } else {
        //NSLog(@"%@,[ jumping to the dashboard ]", adminKey);
        [self popDashboardVC];
        
    }
}

#pragma mark - Navigation
-(void) pushNextViewController:(UIButton *)sender {
//    [self performSegueWithIdentifier:@"loginView" sender:self];
    [sender setBackgroundColor:[UIColor clearColor]];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WelcomeViewShown"];
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.parentViewController performSegueWithIdentifier:@"loginView" sender:self];
}

-(void) popDashboardVC{

    [self performSegueWithIdentifier:@"dashboardView" sender:self];
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
    
    //NSLog(@"view did appear");
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self CheckUserDefaults];
    
    // This will fix the view from being framed underneath the navigation bar and status bar.
    //self.navigationController.navigationBar.translucent = YES;
    
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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
