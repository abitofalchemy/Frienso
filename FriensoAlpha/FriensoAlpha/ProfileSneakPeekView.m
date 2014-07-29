//
//  ProfileSneakPeekView.m
//  LoginScreenTutorial
//
//  Created by Salvador Aguinaga on 7/27/14.
//  Copyright (c) 2014 Dipin Krishna. All rights reserved.
//

#import "ProfileSneakPeekView.h"
//#import "UserProfileViewController.h"

@implementation ProfileSneakPeekView
{
    UILabel *title;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height * 3.0)];
        
        // Initialization code
        title = [[UILabel alloc] initWithFrame:CGRectZero];
        self.tapCounter = 0;
//        self.userPhoneString = userPhoneNumber;
        [self initViewObjects];
        
    }
    return self;
}

- (void) setUserEmailString:(NSString *)userEmailString withPhoneNumber:(NSString*)userPhoneString
{
    NSLog(@"%@,%@", userEmailString, userPhoneString);
    self.userEmailString = userEmailString;
    self.userPhoneString = userPhoneString;
    NSString *formattedPhStr = [self formatPlainPhoneString:self.userPhoneString];
    NSString *profileString = [NSString stringWithFormat:@"%@\n%@",self.userEmailString,
                               formattedPhStr];
    [title setTextColor:[UIColor whiteColor]];
    [title setNumberOfLines:2];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setText:profileString];
    [title sizeToFit];
    [UIView animateWithDuration:0.5 animations:^{
        [self addSubview:title];
        [title setCenter:CGPointMake(self.center.x, self.frame.size.height/2.0 + title.center.y)];
    }];
}
- (void) initViewObjects {
    self.userEmailString = nil;
    self.userPhoneString = nil;
    
    self.backgroundColor = [UIColor colorWithHue:.58333 saturation:0.50 brightness:0.62 alpha:0.8];
    
    
    
    // button
    self.settingsGearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [self scaleImage:[UIImage imageNamed:@"setting-ic-2x29.png"]
                               toSize:CGSizeMake(24, 24)];//[ scaleImage: toSize:CGSizeMake(29, 29)];
    [self.settingsGearBtn setImage:image
                          forState:UIControlStateNormal];
    
    [self.settingsGearBtn.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:24.0]];
    [self.settingsGearBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.settingsGearBtn addTarget:self
//                             action:@selector(dismissSegueToSettingsView:)
//                   forControlEvents:UIControlEventTouchUpInside];
    [self.settingsGearBtn sizeToFit];

    self.closeProfileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeProfileBtn setTitle:@"×" forState:UIControlStateNormal];
    [self.closeProfileBtn.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:24.0]];
    [self.closeProfileBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.closeProfileBtn addTarget:self
                             action:@selector(dismissProfileSneakPeekView:)
                   forControlEvents:UIControlEventTouchUpInside];
    [self.closeProfileBtn sizeToFit];

    [self addSubview:self.settingsGearBtn];
    [self addSubview:self.closeProfileBtn];
    
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.closeProfileBtn setCenter:CGPointMake(self.frame.size.width - self.closeProfileBtn.frame.size.width * 1.5, self.frame.size.height*0.75)];
        [self.settingsGearBtn setCenter:CGPointMake(15.0f + self.settingsGearBtn.center.x,
                                                    self.frame.size.height*0.75)];
    }];
}

- (NSString*) formatPlainPhoneString:(NSString*)phone_str_arg {
    NSString* formattedString = nil;
    if (phone_str_arg.length <10 )
        return nil;
    NSRange range = NSMakeRange(4, 3);
    formattedString = [NSString stringWithFormat:@"(%@) %@-%@",
                       [phone_str_arg substringToIndex:3],
                       [phone_str_arg substringWithRange:range],
                       [phone_str_arg substringFromIndex:6]];
    return formattedString;
}

- (UIImage*) scaleImage:(UIImage*)image toSize:(CGSize)newSize {
    CGSize scaledSize = newSize;
    float scaleFactor = 1.0;
    if( image.size.width > image.size.height ) {
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
#pragma mark - Actions Methods
//- (void) presentProfileSettingsView:(id) sender
//{
//    
//}
- (void) dismissProfileSneakPeekView:(id)sender
{
    self.tapCounter = 0;
    NSParameterAssert(sender == self.closeProfileBtn);
	if (sender == self.closeProfileBtn) {
		//UIButton *button = self.closeProfileBtn;
        [self animateThisButton:(UIButton*)sender];
        [UIView animateWithDuration:0.3 animations:^{
            [self setFrame:CGRectMake(0, 0, self.frame.size.width, 0)];
        }];
        [self performSelector:@selector(dismissThisView) withObject:self afterDelay:0.3];
    }
}
- (void) dismissThisView
{
    [self removeFromSuperview];
}
#pragma mark - Animations
-(void) animateThisButton:(UIButton *)button {
    // animate the button
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.duration = 0.125;
    anim.repeatCount = 1;
    anim.autoreverses = YES;
    anim.removedOnCompletion = YES;
    anim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.5, 1.5, 1.0)];
    [button.layer addAnimation:anim forKey:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
