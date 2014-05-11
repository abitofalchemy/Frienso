//
//  tstWatchingViewController.h
//  FriensoAlpha
//
//  Created by Sal Aguinaga on 3/6/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MessageUI/MessageUI.h> 

@interface tstWatchingViewController : UITableViewController<MFMessageComposeViewControllerDelegate>
- (void) setText:(NSString *)paramText;

@end
