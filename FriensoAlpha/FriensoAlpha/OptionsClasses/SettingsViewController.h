//
//  ProfileViewController.h
//  FriensoAlpha
//
//  Created by Sal Aguinaga on 3/3/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface SettingsViewController : UIViewController <MFMailComposeViewControllerDelegate,UITextFieldDelegate>

@property (nonatomic,strong) UITextField *editAlarmTimer;
@property(nonatomic) CGRect buttonFrame;
- (void) setText:(NSString *)paramText;

@end
