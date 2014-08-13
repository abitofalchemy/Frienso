//
//  UserResponseScrollView.m
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 6/3/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "UserResponseScrollView.h"
#import <QuartzCore/QuartzCore.h>

BOOL dbg = NO;

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
    self.circleView = [[UIView alloc] initWithFrame:CGRectMake(0,0,10,10)];
    self.circleView.alpha = 0.5;
    self.circleView.layer.cornerRadius = 5;
    self.circleView.backgroundColor = [UIColor blueColor];
    [self addSubview:self.circleView];
    [self.circleView setCenter:CGPointMake(self.frame.size.width - self.circleView.center.x * 2.0 , self.frame.size.height/2.0)];
}
-(void) enablePendingRequestsDot:(BOOL)onOffFlag
{
    if (onOffFlag)
        self.circleView.backgroundColor = [UIColor blueColor];
    else
        self.circleView.backgroundColor = [UIColor grayColor];
}
-(void) setPendingRequests:(NSArray *) pendingRequestsArray {
    if (dbg) NSLog(@"setPendingRequests: %d", (int)pendingRequestsArray.count);

//    for (id subview in [self subviews]){
//        if ( [subview isKindOfClass:[UILabel class]] ) {
//            [subview removeFromSuperview];
//        }
//        
//    }
//    
//    UILabel *pendingReq = [[UILabel alloc] initWithFrame:CGRectZero];
//    [pendingReq setText:[NSString stringWithFormat:@"≡ Pending:%ld", (long)[pendingRequestsArray count]]];
//    [pendingReq setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:16.0]];
//    [pendingReq sizeToFit];
//    [pendingReq setCenter:CGPointMake(self.frame.size.width - pendingReq.frame.size.width* 0.6,
//                                      pendingReq.frame.size.height *0.65)];
//    [self addSubview:pendingReq];
    
    if ([pendingRequestsArray count] == 0)
        [self enablePendingRequestsDot:NO];
    else
        [self enablePendingRequestsDot:YES];
    
}
-(void) updatePendingRequests:(NSArray *) pendingRequestsArray {
    // warning this is updating two labels.....
//    for (id subview in [self subviews]){
//        if ( [subview isKindOfClass:[UILabel class]] ) {
//            [subview setText:[NSString stringWithFormat:@"≡ Pending:%ld", (long)[pendingRequestsArray count]]];
//        }
//        
//    }
    if ([pendingRequestsArray count] == 0)
        [self enablePendingRequestsDot:NO];
    else
        [self enablePendingRequestsDot:YES];
    
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
