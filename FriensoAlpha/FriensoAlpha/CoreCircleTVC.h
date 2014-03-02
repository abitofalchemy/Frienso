//
//  CoreCircleTVC.h
//  ObjCTvcLoginParse
//
//  Created by Salvador Aguinaga on 8/8/13.
//  Copyright (c) 2013 Salvador Aguinaga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

@interface CoreCircleTVC : UITableViewController <ABPeoplePickerNavigationControllerDelegate>
{
    NSInteger cellNumberSelected;
    NSArray *coreCircleSections;
    NSMutableArray *coreCircleOfFriends;
    NSMutableArray *contactList;
    NSMutableArray *coreCircleContacts;
    IBOutlet UILabel *lblCoreContact0;
    IBOutlet UILabel *lblCoreContact1;
    IBOutlet UILabel *lblCoreContact2;

    
}

@property (assign) IBOutlet UILabel *lblCoreContact0;
@property (assign) IBOutlet UILabel *lblCoreContact1;
@property (assign) IBOutlet UILabel *lblCoreContact2;
@property(nonatomic, weak) NSArray *coreCircleSections;
@property(nonatomic, weak) NSMutableArray *coreCircleOfFriends;
@property(nonatomic, weak) NSMutableArray *contactList;
@property(nonatomic, weak) NSMutableArray *coreCircleContacts;
@property(nonatomic, assign) NSInteger cellNumberSelected;

- (void)showPickerForIndex:(NSInteger)indexPath;

@end
