//
//  AlarmTimerTriggersTVC.h
//  Frienso_iOS
//
//  Created by Salvador Aguinaga on 10/28/13.
//  Copyright (c) 2013 Salvador Aguinaga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface AlarmTimerTriggersTVC : UITableViewController
{
    __strong NSTimer *eventEndDateTimer;
    __strong EKEvent *eventHolderObj;
    UIAlertView *       _alertView;
}
-(void) uploadNewEventToCloud:(EKEvent *)event;
@end
