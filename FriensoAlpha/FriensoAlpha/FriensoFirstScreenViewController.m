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
        NSLog(@"[1]");
        //[username setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"adminID"]];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self CheckUserDefaults];
    self.navigationController.navigationBarHidden = YES;
    
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
    
    [self.welcomeLabel setTextColor:[UIColor whiteColor]];
    [self.welcomeLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:28.0]];
    [self.welcomeLabel setText:@"Welcome to Frienso"];
    [self.welcomeLabel setCenter:CGPointMake(self.view.center.x, self.view.bounds.size.height*0.8)];
    [self.welcomeLabel sizeToFit];
    
    
    [self.chngTheWorldBtn.titleLabel setTextColor:[UIColor whiteColor]];
    [self.chngTheWorldBtn.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:16.0]];
    self.chngTheWorldBtn.layer.cornerRadius = 8.0f;
    self.chngTheWorldBtn.layer.borderWidth = 1.2f;
    self.chngTheWorldBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.chngTheWorldBtn.layer.backgroundColor = [UIColor blueColor].CGColor;
    [self.chngTheWorldBtn setCenter:self.view.center];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
