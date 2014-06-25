//
//  UserResponseScrollView.h
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 6/3/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserResponseScrollView : UIScrollView <UIScrollViewDelegate>

// Frame of the drawer
@property (nonatomic) CGRect drawerRect;
@property (nonatomic,retain) UIView *circleView;

-(void) enablePendingRequestsDot:(BOOL)onOffFlag;
-(void) setPendingRequests:(NSArray *) pendingRequestsArray;
-(void) updatePendingRequests:(NSArray *) pendingRequestsArray;

@end
