//
//  UserResponseScrollView.m
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 6/3/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "UserResponseScrollView.h"
#import <QuartzCore/QuartzCore.h>


@implementation UserResponseScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    //
    
    if (self) {
        self.frame = frame;
        [self initialize];
    }
    return self;
}
-(void)initialize {
    
//    NSLog(@"%f,%f",self.frame.size.width, self.frame.size.height);
//    CAGradientLayer *gradient = [CAGradientLayer layer];
//    gradient.frame       = self.frame;
//    UIColor *startColour = [UIColor colorWithHue:.580555 saturation:0.31 brightness:0.90 alpha:1.0];
//    UIColor *endColour   = [UIColor colorWithHue:.58333 saturation:0.50 brightness:0.62 alpha:1.0];
//    gradient.colors = [NSArray arrayWithObjects:(id)[startColour CGColor],(id)[endColour CGColor], nil];
//    //[cell.layer insertSublayer:gradient atIndex:0];
//    [self.layer insertSublayer:gradient atIndex:0];
    self.backgroundColor  = [UIColor colorWithHue:.580555 saturation:0.31 brightness:0.90 alpha:1.0];
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.delegate         = self;
    
//    self.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.layer.borderWidth = 2;
    
}
-(void) setPendingRequests:(NSArray *) pendingRequestsArray {
    UILabel *pendingReq = [[UILabel alloc] initWithFrame:CGRectZero];
    [pendingReq setText:[NSString stringWithFormat:@"Pending:%ld", [pendingRequestsArray count]]];
    [pendingReq setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:16.0]];
    [pendingReq sizeToFit];
    [pendingReq setCenter:CGPointMake(self.frame.size.width - pendingReq.frame.size.width* 0.6,
                                      pendingReq.frame.size.height *0.65)];
    [self addSubview:pendingReq];
    
}

#pragma mark -

#pragma mark UIScrollView delegate methods
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    NSLog(@"scrollViewWillBeginDecelerating ...");
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewWillBeginDragging");
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset

{
    NSLog(@"scrollViewWillEndDragging");
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidScroll");
}

/*
 
 A UIScrollView delegate callback, called when the user starts zooming.
 
 - (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
 
 {
 
 return self.tiledPDFView;
 
 }
 
 */




/*
 
 A UIScrollView delegate callback, called when the user begins zooming.
 
 When the user begins zooming, remove the old TiledPDFView and set the current TiledPDFView to be the old view so we can create a new TiledPDFView when the zooming ends.
 - (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
 
 {
 
 NSLog(@"%s scrollView.zoomScale=%f",__PRETTY_FUNCTION__,self.zoomScale);
 
 
 
 }
 */







/*
 
 A UIScrollView delegate callback, called when the user stops zooming.
 
 When the user stops zooming, create a new TiledPDFView based on the new zoom level and draw it on top of the old TiledPDFView.
 - (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
 
 {
 
 }
 
 */





@end
