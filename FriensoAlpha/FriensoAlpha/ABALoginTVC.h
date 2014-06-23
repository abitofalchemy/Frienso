//
//  ABALoginTVC.h
//  ABALoginView
//
//  Created by Salvador Aguinaga on 5/30/13.
//  Copyright (c) 2013 Salvador Aguinaga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/NSFetchedResultsController.h>
#import <CoreLocation/CoreLocation.h>


@interface ABALoginTVC : UITableViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, NSURLConnectionDelegate, UIAlertViewDelegate,NSFetchedResultsControllerDelegate,CLLocationManagerDelegate>
{
    NSArray *loginSections;
    NSArray *loginFields;
    NSMutableArray *loginBtnLabel;
    UITextField *username;
    UITextField *password;
    UITextField *phoneNumber;
    UILabel     *loginLabel;
    BOOL        retVal;
    UISwitch *keepMeLoggedin;
    
}
@property(nonatomic, weak) NSArray *loginSections;
@property(nonatomic, weak) NSArray *loginFields;
@property(nonatomic, weak) NSMutableArray *loginBtnLabel;
@property(nonatomic, weak) UITextField *username;
@property(nonatomic, weak) UITextField *password;
@property(nonatomic, weak) UITextField *phoneNumber;
@property(nonatomic, weak) IBOutlet UILabel *loginLabel;
@property(nonatomic, assign) BOOL retVal;
@property(nonatomic, retain) IBOutlet UISwitch *keepMeLoggedin;
@property (nonatomic, retain) CLLocationManager *locationManager;


- (void) reloadSection:(NSInteger)section withRowAnimation:(UITableViewRowAnimation)rowAnimation;
- (NSString *)stringFromDict:(NSDictionary *)dict;

@end
