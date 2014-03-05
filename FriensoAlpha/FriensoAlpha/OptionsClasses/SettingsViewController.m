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
    contentView.backgroundColor = UIColorFromRGB(0xF6E4CC);

    self.view = contentView;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width*0.8,
                                                               35.0)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText:@"Logout"];
    label.center = CGPointMake(self.view.center.x, self.view.bounds.size.height*0.85);
    [self.view addSubview:label];
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
