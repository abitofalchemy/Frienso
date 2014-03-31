//
//  aBoAViewController.m
//  PageScrollView
//
//  Created by Sal Aguinaga on 1/30/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "aBoAViewController.h"

@interface aBoAViewController ()
{
    UIButton *dismissButton;
}
@property (nonatomic,weak)   UIImage *originalImage;
@end

@implementation aBoAViewController
@synthesize dismissButton = _dismissButton;

-(UIImageView *) newImageViewWithImage:(UIImage *)image showInFrame:(CGRect)paramFrame{
    UIImageView *result = [[UIImageView alloc] initWithFrame:paramFrame];
    result.contentMode  = UIViewContentModeScaleAspectFit;
    result.image        = image;
    return result;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Help/Info";
    //[self.navigationController setNavigationBarHidden:YES];
    
    //initialize and allocate your scroll view
    CGRect scrollViewRect = CGRectMake(0, 0,
                                       self.view.bounds.size.width,
                                       self.view.bounds.size.height*0.85);
    self.myScrollView = [[UIScrollView alloc]
                         initWithFrame:scrollViewRect];
    self.myScrollView.backgroundColor = [UIColor whiteColor];
    self.myScrollView.pagingEnabled = YES;
    self.myScrollView.delegate = self;
    self.myScrollView.showsVerticalScrollIndicator=NO;
    self.myScrollView.userInteractionEnabled=YES;

    //set the content size of the scroll view, we keep the height same so it will only
    //scroll horizontally
    self.myScrollView.contentSize = CGSizeMake(self.view.frame.size.width * 3,
                                               self.view.frame.size.height*0.8);
    //we set the origin to the 3rd page
    CGPoint scrollPoint = CGPointMake(self.view.frame.size.width * 0, 0);
    //change the scroll view offset the the 3rd page so it will start from there
    [self.myScrollView setContentOffset:scrollPoint animated:YES];
    
    // Page Control
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0,0,50.0,30.0)];
    self.pageControl.center = CGPointMake(self.view.center.x, self.view.bounds.size.height*0.85f);
    self.pageControl.numberOfPages = 3;
    self.pageControl.currentPage = 0;
    self.pageControl.currentPageIndicatorTintColor = [UIColor blueColor];
    self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    
    
    //[self addDismissButtonToView];
  
    CGRect helpInfoFrame = CGRectMake(0,0,self.view.bounds.size.width * 0.70,
                                      self.view.bounds.size.height*0.70);
    self.imageView = [UIImageView new];
    [self.imageView setFrame:helpInfoFrame];
    [self.myScrollView addSubview:self.imageView];
    
    self.helpInfoLabel = [[UILabel alloc] initWithFrame:self.navigationController.navigationBar.bounds];
    self.helpInfoLabel.text = @"Test";
    self.helpInfoLabel.center = CGPointMake(self.navigationController.navigationBar.center.x, self.navigationController.navigationBar.center.x*2);
    
    [self.view addSubview:self.helpInfoLabel];
    [self.view addSubview:self.myScrollView];
    [self.view addSubview:self.self.pageControl];

    
    [self updatePageImage:0];// help/info content set
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) animateWarningLabel:(UILabel *) label {
    //[self.myScrollView addSubview:self.helpInfoLabel];
    
    [UIView animateWithDuration:2.0
                     animations:^{
                         CGRect frame = label.frame;
                         frame.origin.y = 0;
                         label.frame = frame;
                         
                     } completion:nil];
}
//
-(void) scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.myScrollView setAlpha:0.5f];
    
}
-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self.myScrollView setAlpha:1.0f];
    
    
    switch ((long)(self.myScrollView.contentOffset.x/self.view.bounds.size.width)) {
        case 0:
            self.helpInfoLabel.text = @"For use with Serim Strips ONLY!";
            self.pageControl.currentPage = 0;
            [self updatePageImage:0];
            break;
        case 1:
            self.helpInfoLabel.text = @"Instructions for use of test strips";
            self.pageControl.currentPage = 1;
            [self updatePageImage:1];
            break;
        case 2:
            self.helpInfoLabel.text = @"Save, Email, and or Export Data";
            self.pageControl.currentPage = 2;
            [self updatePageImage:2];
            break;
        default:
            self.pageControl.currentPage = 0;
            //[self updatePageImage:0];
            break;
    }
}
//
//
-(void) updatePageImage:(NSUInteger)currentPage
{
    self.pageControl.currentPage = currentPage;
    //NSLog(@" page %d", (NSInteger) currentPage);
    self.originalImage =  [UIImage imageNamed:[NSString stringWithFormat:@"frienso-info-%lu.png",(unsigned long)currentPage]];
    
    self.imageView.image = self.originalImage;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.imageView setCenter:CGPointMake(self.view.center.x + self.myScrollView.contentOffset.x
                                     ,self.view.bounds.size.height/2)];
    NSLog(@"%f,%f",self.imageView.center.x, self.imageView.center.y);
    
    
    CGFloat labelCenterY = self.helpInfoLabel.frame.size.height/2.0f;
    [self.helpInfoLabel setCenter:CGPointMake(self.imageView.center.x, labelCenterY)];
    
    
}
-(void) addDismissButtonToView{
    dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [dismissButton addTarget:self
                      action:@selector(dismissViewAction)
            forControlEvents:UIControlEventTouchDown];
    [dismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
    dismissButton.backgroundColor = [UIColor blueColor];
    
    dismissButton.layer.borderWidth = 1.0f;
    dismissButton.layer.cornerRadius = 6.0f;
    dismissButton.layer.borderColor = [UIColor blueColor].CGColor;
    CGFloat deviceDrivenX = self.view.bounds.size.width;
    CGFloat deviceDrivenY = self.view.bounds.size.height;
    dismissButton.frame = CGRectMake(0, 0, 160.0, 40.0);
    dismissButton.center = CGPointMake(deviceDrivenX*0.5f, deviceDrivenY*0.95f);
    [self.view addSubview:dismissButton];
    
}
-(void) dismissViewAction {
    UIColor *color = [UIColor whiteColor];
    dismissButton.titleLabel.layer.shadowColor = [color CGColor];
    dismissButton.titleLabel.layer.shadowRadius = 4.0f;
    dismissButton.titleLabel.layer.shadowOpacity = .9;
    dismissButton.titleLabel.layer.shadowOffset = CGSizeZero;
    dismissButton.titleLabel.layer.masksToBounds = NO;
    dismissButton.backgroundColor = [UIColor grayColor];
    NSLog(@"Dismiss this view");
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LaunchedBefore"];
    [self dismissModalVC];
}

-(void) dismissModalVC{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void) warningLabelBackground:(UILabel *)labelView {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = labelView.layer.bounds;
    //gradient.cornerRadius = 10;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[UIColor colorWithWhite:0.0f alpha:0.4f].CGColor,
                       (id)[UIColor colorWithWhite:0.0f alpha:0.4f].CGColor,
                       (id)[UIColor colorWithWhite:1.0f alpha:0.4f].CGColor,
                       (id)[UIColor colorWithWhite:1.0f alpha:1.0f].CGColor,
                       nil];
    float height = gradient.frame.size.height;
    gradient.locations = [NSArray arrayWithObjects:
                          [NSNumber numberWithFloat:0.0f],
                          [NSNumber numberWithFloat:0.2*30/height],
                          [NSNumber numberWithFloat:1.0-0.1*30/height],
                          [NSNumber numberWithFloat:1.0f],
                          nil];
    [labelView.layer addSublayer:gradient];
    
}

@end
