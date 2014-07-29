//
//  ProfileSneakPeekView.h
//  LoginScreenTutorial
//
//  Created by Salvador Aguinaga on 7/27/14.
//  Copyright (c) 2014 Dipin Krishna. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileSneakPeekView : UIView

@property (nonatomic) BOOL tapCounter;
@property (nonatomic,strong) NSString *userEmailString;
@property (nonatomic,strong) NSString *userPhoneString;
@property (nonatomic,strong) UIButton *closeProfileBtn;
@property (nonatomic,strong) UIButton *settingsGearBtn;

- (void) setUserEmailString:(NSString*)userEmailString
            withPhoneNumber:(NSString*)userPhoneString;

@end
