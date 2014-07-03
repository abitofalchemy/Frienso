//
//  WelcomeViewCtrl
//  PageScrollView
//
//  Created by Sal Aguinaga on 1/30/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WelcomeViewCtrl : UIViewController<UIScrollViewDelegate>

@property(nonatomic, strong) UIScrollView    *myScrollView;
@property(strong, nonatomic) UIPageControl   *pageControl;
@property(strong, nonatomic) UILabel         *infoTopLabel;
@property(retain, nonatomic) UIImageView     *imageView;
//-(void)changePage:(UIPageControl *)sender;

@end
