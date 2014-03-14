//
//  NewCoreCircleTVC.h
//  FriensoAlpha
//
//  Created by Sal Aguinaga on 3/10/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>


@interface NewCoreCircleTVC : UIViewController <UITableViewDelegate,UITableViewDataSource, ABPeoplePickerNavigationControllerDelegate>
@property(nonatomic, strong) NSArray *coreCircleSections;
@property(nonatomic, strong) NSMutableArray *contactList;

@end
