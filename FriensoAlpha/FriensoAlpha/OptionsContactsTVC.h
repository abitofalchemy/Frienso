//
//  OptionsContactsTVC.h
//  FriensoAlpha
//
//  Created by Salvador Aguinaga on 8/27/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/NSFetchedResultsController.h>
#import <MessageUI/MessageUI.h>

@interface OptionsContactsTVC : UITableViewController <NSFetchedResultsControllerDelegate,
UITableViewDelegate,UITableViewDataSource,MFMessageComposeViewControllerDelegate,UIAlertViewDelegate>

- (void)showSMSPicker:(id)sender;

@end
