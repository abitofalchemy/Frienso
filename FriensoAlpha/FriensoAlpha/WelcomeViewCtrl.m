//
//  aBoAViewController.m
//  PageScrollView
//
//  Created by Sal Aguinaga on 1/30/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "WelcomeViewCtrl.h"

@interface WelcomeViewCtrl ()
{
    BOOL imgAdded;
}
@property (nonatomic,strong) UILabel *warningLabel;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *subTitleLabel;
@property (nonatomic,strong) UITextView *instructions;
@property (nonatomic,assign) BOOL imgAdded;
@property (nonatomic,weak)   UIImage *originalImage;
@property (nonatomic,strong) UIButton *bottomButton;

@end

@implementation WelcomeViewCtrl
@synthesize imgAdded = _imgAdded;

@synthesize myScrollView,warningLabel,pageControl,imageView,bottomButton;

-(UIImageView *) newImageViewWithImage:(UIImage *)image showInFrame:(CGRect)paramFrame{
    UIImageView *result = [[UIImageView alloc] initWithFrame:paramFrame];
    result.contentMode  = UIViewContentModeScaleAspectFit;
    result.image        = image;
    return result;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIFont *srFont = [UIFont fontWithName:@"AppleGothic" size:16];
    //UIFont *srFont = [UIFont fontWithName:@"Avenir-Light" size:16];
    //self.navigationItem.title = @"Help/Info";
    [self.navigationController setNavigationBarHidden:YES];
    
    imgAdded = NO;
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;

    //initialize and allocate your scroll view
//    CGRect scrollViewRect = CGRectMake(0, 0,
//                                       self.view.bounds.size.width,
//                                       self.view.bounds.size.height*0.85);
    CGRect scrollViewRect = self.view.bounds;

    self.myScrollView = [[UIScrollView alloc]
                         initWithFrame:scrollViewRect];
    self.myScrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
    self.myScrollView.pagingEnabled = YES;
    self.myScrollView.delegate = self;
    self.myScrollView.showsVerticalScrollIndicator=NO;
    self.myScrollView.userInteractionEnabled=YES;
    self.myScrollView.center = self.view.center;
//    self.myScrollView.layer.borderWidth = 1.0f;
//    self.myScrollView.layer.cornerRadius = 6.0f;
//    self.myScrollView.layer.borderColor = [UIColor blueColor].CGColor;
    

    //set the content size of the scroll view, we keep the height same so it will only
    //scroll horizontally
    self.myScrollView.contentSize = CGSizeMake(self.view.frame.size.width * 4,
                                               self.view.frame.size.height*0.8);

    //we set the origin to the 3rd page
    CGPoint scrollPoint = CGPointMake(self.view.frame.size.width * 0, 0);
    //change the scroll view offset the the 3rd page so it will start from there
    [myScrollView setContentOffset:scrollPoint animated:YES];
    
    // Page Control
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0,0,50.0,30.0)];
    pageControl.center = CGPointMake(self.view.center.x, self.view.frame.size.height * 0.9);
    pageControl.numberOfPages = 4;
    pageControl.currentPage = 0;
    pageControl.currentPageIndicatorTintColor = [UIColor blueColor];
    pageControl.pageIndicatorTintColor = [UIColor grayColor];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.text = @"friens◎";
    [self.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:32.0]];
    [self.titleLabel sizeToFit];
    [self.titleLabel setFont:srFont];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setTextColor:[UIColor whiteColor]];

    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    //[self.titleLabel setCenter:CGPointMake(self.view.center.x, self.view.frame.size.height*0.125)];
    [self.titleLabel setCenter:self.view.center];
    
    self.subTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.subTitleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:12]];
    [self.subTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.subTitleLabel setBackgroundColor:[UIColor clearColor]];
    [self.subTitleLabel setTextColor:[UIColor whiteColor]];
    self.subTitleLabel.numberOfLines = 3;
    [self.subTitleLabel setFrame:CGRectMake(0,0,screenSize.width * 0.8, screenSize.height * 0.25)];
    [self.subTitleLabel setCenter:CGPointMake(self.view.center.x, screenSize.height * 0.75)];
    
    CGRect helpInfoFrame = CGRectMake(0,0,self.view.bounds.size.width * 0.70,
                                      self.view.bounds.size.height*0.5);
    imageView = [UIImageView new];
    [imageView setFrame:helpInfoFrame];
    [imageView setBackgroundColor:[UIColor clearColor]];
    [self.myScrollView addSubview:imageView];
    
    [self.view addSubview:self.myScrollView];
    [self.view addSubview:self.pageControl];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.subTitleLabel];
    
    [self updatePageImage:0];// help/info content set
    
    
//    https://s.yimg.com/pw/images/sohp_2014/trees_noblur.jpg
    NSURL *imageURL = [NSURL URLWithString:@"https://s.yimg.com/pw/images/sohp_2014/trees_noblur.jpg"];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage *img = [UIImage imageWithData:imageData];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[self scaleImage:img
                                                                           toSize:self.view.bounds.size]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) animateWarningLabel:(UILabel *) label {
    //[self.myScrollView addSubview:self.warningLabel];
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         [self.titleLabel setCenter:self.view.center];
                         [self.titleLabel setCenter:CGPointMake(self.view.center.x, self.view.frame.size.height*0.125)];
                         [self.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:16]];

                     } completion:nil];
}
//
-(void) scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.myScrollView setAlpha:0.5f];
    
}
-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self.myScrollView setAlpha:1.0f];
    NSInteger pageNbr =(long)(myScrollView.contentOffset.x/self.view.bounds.size.width);
    
    if (DBG) NSLog(@"%f", myScrollView.contentOffset.x);
    switch (pageNbr) {
        case 0:
            pageControl.currentPage = 0;
            [self updatePageImage:0];
            break;
        case 1:
            pageControl.currentPage = 1;
            [self updatePageImage:1];
            break;
        case 2:
            pageControl.currentPage = 2;
            [self updatePageImage:2];
            break;
        case 3:
            pageControl.currentPage = 3;
            [self updatePageImage:3];
            [self addGetStartedButtonToView];
            break;
        /*case 4:
            pageControl.currentPage = 4;
            [self updatePageImage:4];
         
            break;
            */
        default:
            pageControl.currentPage = 0;
            [self updatePageImage:0];
            break;
    }
}

-(void) updatePageImage:(NSUInteger)currentPage
{
    pageControl.currentPage = currentPage;
    if (DBG) NSLog(@"updatePageImage: %lu",(unsigned long)currentPage);
    
    switch (currentPage) {
//        case 0:
//            self.originalImage =  [UIImage imageNamed:@"frienso-0.png"];
//            [self.subTitleLabel setText:@""];
//            break;
        case 0:
        {
            [self animateWarningLabel:self.titleLabel];
            [self.subTitleLabel setText:@"Your uSocial Safety Network for College Campus. Join the movement to help those closest to you be safe, informed, & engaged."];
            // Be part of one or more trusted circle of friends and use it for yourself and to help others.
            self.originalImage =  [UIImage imageNamed:@"frienso-0.png"];
            [imageView setCenter:CGPointMake(self.view.center.x + self.myScrollView.contentOffset.x
                                             ,self.view.bounds.size.height/2)];
            break;
        }
        case 1:
        {
            self.originalImage =  [UIImage imageNamed:@"frienso-1.png"];
            [self.subTitleLabel setText:@"Enable WatchMe when walking anywhere late at night. Frienso alerts your trusted circle of friends to be on standby."];
            [imageView setFrame:CGRectMake(imageView.frame.origin.x, self.titleLabel.frame.size.height * 1.2, imageView.frame.size.width, imageView.frame.size.height)];
            [imageView setCenter:CGPointMake(self.view.center.x + self.myScrollView.contentOffset.x
                                             ,imageView.center.y + self.titleLabel.frame.size.height * 1.1)];
            break;
        }
        case 2:
            self.originalImage =  [UIImage imageNamed:@"frienso-2.png"];
            [self.subTitleLabel setText:@"Enable HelpMeNow when you need help immediately.  Frienso notifies & sends a group SMS to your trusted circle with your location."];
            //  You may then choose to quickly dial any of your trusted friends, campus police, or 911."
            self.subTitleLabel.numberOfLines = 4;
            [imageView setFrame:CGRectMake(imageView.frame.origin.x, self.titleLabel.frame.size.height * 1.2, imageView.frame.size.width, imageView.frame.size.height)];
            [imageView setCenter:CGPointMake(self.view.center.x + self.myScrollView.contentOffset.x
                                             ,imageView.center.y + self.titleLabel.frame.size.height * 1.1)];
            break;
        case 3:
            self.originalImage =  [UIImage imageNamed:@"frienso-3.png"];
            [self.subTitleLabel setText:@"Location based emergency contacts load when you travel from one campus to another automatically!"];
            //  You may then choose to quickly dial any of your trusted friends, campus police, or 911."
            self.subTitleLabel.numberOfLines = 4;
            [imageView setFrame:CGRectMake(imageView.frame.origin.x, self.titleLabel.frame.size.height * 1.2, imageView.frame.size.width, imageView.frame.size.height)];
            [imageView setCenter:CGPointMake(self.view.center.x + self.myScrollView.contentOffset.x
                                             ,imageView.center.y + self.titleLabel.frame.size.height * 1.1)];
            break;
        default:
            break;
    }

    imageView.image = self.originalImage;
    imageView.contentMode = UIViewContentModeScaleAspectFit;

    
    
   
}
-(void) addGetStartedButtonToView{
    bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [bottomButton addTarget:self
                      action:@selector(dismissViewAction)
            forControlEvents:UIControlEventTouchDown];
    [bottomButton setTitle:@"Get Started" forState:UIControlStateNormal];
    bottomButton.backgroundColor = [UIColor blueColor];
    
    bottomButton.layer.borderWidth = 1.0f;
    bottomButton.layer.cornerRadius = 6.0f;
    bottomButton.layer.borderColor = [UIColor blueColor].CGColor;
//    CGFloat deviceDrivenX = self.view.bounds.size.width;
//    CGFloat deviceDrivenY = self.view.bounds.size.height;
    bottomButton.frame = CGRectMake(0, 0, 160.0, 40.0);
    bottomButton.center = self.pageControl.center;
    [self.view addSubview:bottomButton];
    
    // animate the button - pop out
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.duration = 0.125;
    anim.repeatCount = 1;
    anim.autoreverses = YES;
    anim.removedOnCompletion = YES;
    anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)];
    [bottomButton.layer addAnimation:anim forKey:nil];
    
    
}
-(void) dismissViewAction {
    UIColor *color = [UIColor whiteColor];
    bottomButton.titleLabel.layer.shadowColor = [color CGColor];
    bottomButton.titleLabel.layer.shadowRadius = 4.0f;
    bottomButton.titleLabel.layer.shadowOpacity = .9;
    bottomButton.titleLabel.layer.shadowOffset = CGSizeZero;
    bottomButton.titleLabel.layer.masksToBounds = NO;
    bottomButton.backgroundColor = [UIColor grayColor];
    if (DBG) NSLog(@"Dismiss this view");
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"getStartedFlag"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissModalVC];
}

-(void) dismissModalVC{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Image Actions
- (UIImage*) scaleImage:(UIImage*)image toSize:(CGSize)newSize {
    CGSize scaledSize = newSize;
    float scaleFactor = 1.0;
    if( image.size.width < image.size.height ) {
        scaleFactor = image.size.width / image.size.height;
        scaledSize.width = newSize.width;
        scaledSize.height = newSize.height / scaleFactor;
    }
    else {
        scaleFactor = image.size.height / image.size.width;
        scaledSize.height = newSize.height;
        scaledSize.width = newSize.width / scaleFactor;
    }
    
    UIGraphicsBeginImageContextWithOptions( scaledSize, NO, 0.0 );
    CGRect scaledImageRect = CGRectMake( 0.0, 0.0, scaledSize.width, scaledSize.height );
    [image drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}
/*
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
*/
@end
