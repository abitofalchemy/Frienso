//
//  aBoAViewController.h
//  PageScrollView
//
//  Created by Sal Aguinaga on 1/30/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface aBoAViewController : UIViewController<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *myScrollView;
@property (strong, nonatomic) UIPageControl   *pageControl;
@property (strong, nonatomic) UILabel         *helpInfoLabel;
@property (retain, nonatomic) UIImageView     *imageView;
@property (strong, nonatomic) UIButton *dismissButton;
@end
