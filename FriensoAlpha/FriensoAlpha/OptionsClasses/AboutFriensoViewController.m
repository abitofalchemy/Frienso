//
//  AboutFriensoViewController.m
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 3/18/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//
/*  http://ios7colors.com/
 
 
 */
#import "AboutFriensoViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@interface AboutFriensoViewController ()

@end

@implementation AboutFriensoViewController

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
    [super loadView];
    self.view.backgroundColor = UIColorFromRGB(0xecf0f1);
    
    [self setupUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup UI Methods
-(void) setupUI {
    /* text kit
    NSTextStorage *textStorage = [NSTextStorage new];
    
    NSLayoutManager *layoutManager = [NSLayoutManager new];
    [textStorage addLayoutManager: layoutManager];
    
    NSTextContainer *textContainer = [NSTextContainer new];
    [layoutManager addTextContainer: textContainer];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:self.view.frame
                                               textContainer:textContainer];
    textView.scrollEnabled = YES;
    */
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    
    NSString *build = infoDictionary[(NSString*)kCFBundleVersionKey];
    NSString *version =[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    UILabel *aboutTitle = [UILabel new];
    aboutTitle.text = [NSString stringWithFormat:@"FRIENSO %@\nBuild:%@",version,build];
    aboutTitle.numberOfLines = 2;
    [aboutTitle setFont:[UIFont fontWithName:@"Avenir-Medium" size:24]];
    [aboutTitle sizeToFit];
    [aboutTitle setTextAlignment:NSTextAlignmentCenter];
    aboutTitle.center = CGPointMake(self.view.center.x, self.view.center.y * 0.5);
    [aboutTitle setTextColor:UIColorFromRGB(0x34495e)];
    
    
    UILabel *aboutH1 = [UILabel new];
    aboutH1.text = [NSString stringWithFormat:@"©2013-2014 Frienso Inc."];
    aboutH1.numberOfLines = 2;
    [aboutH1 setFont:[UIFont fontWithName:@"Avenir-Medium" size:18]];
    [aboutH1 sizeToFit];
    [aboutH1 setTextAlignment:NSTextAlignmentCenter];
    aboutH1.center = CGPointMake(self.view.center.x, self.view.center.y * 0.7);
    [aboutH1 setTextColor:UIColorFromRGB(0x34495e)];
    
    // Privacy Policy
    UIButton *termsButton= [UIButton buttonWithType:UIButtonTypeCustom];
    [termsButton.titleLabel setTextColor:[UIColor whiteColor]];
    [termsButton.titleLabel setTintColor:[UIColor blueColor]];
    [termsButton addTarget:self
                    action:@selector(termsOfUseView)
          forControlEvents:UIControlEventTouchUpInside];
    [termsButton setTitle:@"Terms of Use" forState:UIControlStateNormal];
    [termsButton sizeToFit];
    [termsButton.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:16.0]];
    termsButton.layer.cornerRadius = 4.0f;
    //termsButton.layer.borderWidth = 1.2f;
    //termsButton.layer.borderColor = [UIColor whiteColor].CGColor;
    termsButton.backgroundColor = UIColorFromRGB(0x007aff);
    [self.view addSubview:termsButton];
    
    // Terms of Use 007aff
    UIButton *privacyButton= [UIButton buttonWithType:UIButtonTypeCustom];
    [privacyButton.titleLabel setTextColor:[UIColor whiteColor]];
    [privacyButton.titleLabel setTintColor:[UIColor blueColor]];
    [privacyButton addTarget:self
                      action:@selector(privacyPolicyView)
            forControlEvents:UIControlEventTouchUpInside];
    [privacyButton setTitle:@"Privacy Policy" forState:UIControlStateNormal];
    [privacyButton sizeToFit];
    [privacyButton.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:16.0]];
    privacyButton.layer.cornerRadius = 4.0f;
    //privacyButton.layer.borderWidth = 1.2f;
    //privacyButton.layer.borderColor = [UIColor whiteColor].CGColor;
    privacyButton.backgroundColor = UIColorFromRGB(0x007aff);
    
    [self.view addSubview:privacyButton];
    
    
    [privacyButton setFrame:CGRectMake(0, 0,
                                       privacyButton.frame.size.width*1.1,privacyButton.frame.size.height) ];
    [termsButton setFrame:CGRectMake(0,0,
                                       termsButton.frame.size.width*1.1,termsButton.frame.size.height)];
    
    [privacyButton setCenter:CGPointMake(self.view.center.x/2, self.view.center.y)];
    [termsButton   setCenter:CGPointMake(self.view.center.x*1.5, self.view.center.y)];
    
    [self.view addSubview:aboutTitle];
    [self.view addSubview:aboutH1];
    
    
}

#pragma mark - Actions & Selectors
- (void) privacyPolicyView
{
    
    
}

- (void) termsOfUseView
{
    
}


@end
