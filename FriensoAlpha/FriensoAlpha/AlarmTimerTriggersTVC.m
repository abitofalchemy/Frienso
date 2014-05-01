//
//  AlarmTimerTriggersTVC.m
//  Frienso_iOS
//
//  Created by Salvador Aguinaga on 10/28/13.
//  Copyright (c) 2013 Salvador Aguinaga. All rights reserved.
//  http://www.appcoda.com/customize-table-view-cells-for-uitableview/

/** Notes
 ** EKEventViewController does not get displayed when one selects the 
 ** row.  Might have to copy try to implement this on something else.
 ** -- The problem and fix for this class is listed under: 
 **    http://stackoverflow.com/questions/19697477/segue-to-bring-up-ios-ekeventviewcontroller-isnt-working
 **
 **/
//static BOOL CUSTOM_EVENT_VIEWCONTROLLER = YES;

//#if CUSTOM_EVENT_VIEWCONTROLLER
//#else
//#import "FriensoEventAlarms.h"
//#endif

#import "AlarmTimerTriggersTVC.h"
#import "FriensoEvent.h"
#import "FriensoAppDelegate.h"


@interface AlarmTimerTriggersTVC () <EKEventEditViewDelegate, UIAlertViewDelegate>
// private properties
//@property (nonatomic, retain, readwrite) UIAlertView *      alertView;
@property (nonatomic, strong) UIAlertView *      alertView;

@property (nonatomic, strong) EKEventStore *eventStore;

// Default calendar associated with the above event store
@property (nonatomic, strong) EKCalendar *defaultCalendar;

// Array of all events happening within the next 24 hours
@property (nonatomic, strong) NSMutableArray *eventsList;

// Used to add events to Calendar
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

//@property (nonatomic, retain) EKEventViewController *detailViewController;

@end

@implementation AlarmTimerTriggersTVC
#pragma mark - CoreData helper methods
-(void) actionAddFriensoEven:(EKEvent *)calEvent
{
    NSLog(@"[ Adding a FriensoEvent ]");
    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *managedObjectContext =
    appDelegate.managedObjectContext;
    
    FriensoEvent *firstFriensoEvent = [NSEntityDescription insertNewObjectForEntityForName:@"FriensoEvent"
                                                                    inManagedObjectContext:managedObjectContext];
    
    if (firstFriensoEvent != nil){
        NSString *loginFriensoEvent = @"";
        firstFriensoEvent.eventTitle     = [loginFriensoEvent stringByAppendingString:calEvent.title];
        firstFriensoEvent.eventSubtitle  = [NSString stringWithFormat:@"%@ \u00B7 %@", calEvent.location, calEvent.startDate];
        NSLog(@"%@", [NSString stringWithFormat:@"%@ \u00B7 %@", calEvent.location, calEvent.startDate]);
        firstFriensoEvent.eventCategory  = @"calendar";
        firstFriensoEvent.eventLocation  = @"Right here";
        firstFriensoEvent.eventContact   = @"me";
        firstFriensoEvent.eventCreated   = [NSDate date];
        firstFriensoEvent.eventModified  = [NSDate date];
        
        NSError *savingError = nil;
        if([managedObjectContext save:&savingError]) {
            NSLog(@"Successfully saved the context");
        } else { NSLog(@"Failed to save the context. Error = %@", savingError); }
    } else {
        NSLog(@"Failed to create a new event.");
    }
}

-(void) actionAddFriensoEven:(NSString *)message andSubtitle:(NSString *)subTitle {
    
    NSLog(@"[ Adding a FriensoEvent ]");
    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *managedObjectContext =
    appDelegate.managedObjectContext;
    
    FriensoEvent *firstFriensoEvent = [NSEntityDescription insertNewObjectForEntityForName:@"FriensoEvent"
                                                                    inManagedObjectContext:managedObjectContext];
    
    if (firstFriensoEvent != nil){
        NSString *loginFriensoEvent = @"";
        firstFriensoEvent.eventTitle     = [loginFriensoEvent stringByAppendingString:message];
        firstFriensoEvent.eventSubtitle  = subTitle;
        firstFriensoEvent.eventCategory  = @"calendar";
        firstFriensoEvent.eventLocation  = @"Right here";
        firstFriensoEvent.eventContact   = @"me";
        firstFriensoEvent.eventCreated   = [NSDate date];
        firstFriensoEvent.eventModified  = [NSDate date];
        
        NSError *savingError = nil;
        if([managedObjectContext save:&savingError]) {
            NSLog(@"Successfully saved the context");
        } else { NSLog(@"Failed to save the context. Error = %@", savingError); }
    } else {
        NSLog(@"Failed to create a new event.");
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    [self.navigationController.navigationBar setHidden:NO];
    self.navigationItem.title = @"Alarms";
    
    [self.navigationController setToolbarHidden:YES];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.addButton;
    // Initialize the event store
    self.eventStore = [[EKEventStore alloc] init];
    // Initialize the events list
    self.eventsList = [[NSMutableArray alloc] initWithCapacity:0];
    // The Add button is initially disabled
    self.addButton.enabled = NO;
    
    //eventHolderObj = [[EKEvent alloc] init];
    // Announce this tvc
    NSLog(@"[ AlarmTimerTriggersTVC ]");
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // Check whether we are authorized to access Calendar
    [self checkEventStoreAccessForCalendar];
}

-(void)dealloc {
    //[super dealloc];
    NSLog(@"Problems ahead.");
    [self.alertView setDelegate:nil]; // this prevents the crash in the event that the alertview is still showing.
    self.alertView = nil; // release it
    
}

// This method is called when the user selects an event in the table view.
// It configures the destination event view controller with this event.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showEventViewController"])
    {
        // Configure the destination event view controller
        EKEventViewController* eventViewController = (EKEventViewController *)[segue destinationViewController];
        // Fetch the index path associated with the selected event
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        // Set the view controller to display the selected event
        eventViewController.event = [self.eventsList objectAtIndex:indexPath.row];
        
        // Allow event editing
        eventViewController.allowsEditing = YES;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

// Should default to 1
 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return self.eventsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"eventCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Get the event at the row selected and display its title
    cell.textLabel.text = [[self.eventsList objectAtIndex:indexPath.row] title];
    
    // ToDo:
    EKEvent *thisEvent = [self.eventsList objectAtIndex:indexPath.row];
    NSMutableArray *eventMinDetails  = [[NSMutableArray alloc] initWithObjects:thisEvent.location,
                                        thisEvent.startDate, thisEvent.endDate, nil];

    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    NSString *startTimeString = [dateFormatter stringFromDate:eventMinDetails[1]];
    NSString *endTimeString   = [dateFormatter stringFromDate:eventMinDetails[2]];
    
    //[weekday setLocale:NSLocale];
    [eventMinDetails replaceObjectAtIndex:1 withObject:startTimeString];
    [eventMinDetails replaceObjectAtIndex:2 withObject:  endTimeString];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"📍 %@ ⌚ %@-%@",
                                 [eventMinDetails objectAtIndex:0],
                                 [eventMinDetails objectAtIndex:1],
                                 [eventMinDetails objectAtIndex:2]]; //[eventMinDetails componentsJoinedByString:@"\u2194"];
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
}

/*

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/** +++++++++++++++++++++++++++++++++++++++++++++++++++
 ** Need to be able to edit when the event is selected 
 ** 
 
 */


//#pragma mark - Table view delegate
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Navigation logic may go here. Create and push another view controller.
//    /*
//     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
//     // ...
//     // Pass the selected object to the new view controller.
//     [self.navigationController pushViewController:detailViewController animated:YES];
//     */
//}

#pragma mark -
#pragma mark Access Calendar

// Check the authorization status of our application for Calendar
-(void)checkEventStoreAccessForCalendar
{
    //NSLog(@"[ checking events ]");
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    switch (status)
    {
            // Update our UI if the user has granted access to their Calendar
        case EKAuthorizationStatusAuthorized: [self accessGrantedForCalendar];
            break;
            // Prompt the user for access to Calendar if there is no definitive answer
        case EKAuthorizationStatusNotDetermined: [self requestCalendarAccess];
            break;
            // Display a message if the user has denied or restricted access to Calendar
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Privacy Warning" message:@"Permission was not granted for Calendar"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
            break;
        default:
            break;
    }
}


// Prompt the user for access to their Calendar
-(void)requestCalendarAccess
{
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             AlarmTimerTriggersTVC * __weak weakSelf = self;
             // Let's ensure that our code will be executed from the main queue
             dispatch_async(dispatch_get_main_queue(), ^{
                 // The user has granted access to their Calendar; let's populate our UI with all events occuring in the next 24 hours.
                 [weakSelf accessGrantedForCalendar];
             });
         }
     }];
}



// This method is called when the user has granted permission to Calendar
-(void)accessGrantedForCalendar
{
    // Let's get the default calendar associated with our event store
    self.defaultCalendar = self.eventStore.defaultCalendarForNewEvents;
    // Enable the Add button
    self.addButton.enabled = YES;
    // Fetch all events happening in the next 24 hours and put them into eventsList
    self.eventsList = [self fetchEvents];
    // Update the UI with the above events
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Fetch events

// Fetch all events happening in the next 24 hours
- (NSMutableArray *)fetchEvents
{
    NSDate *startDate = [NSDate date];
    
    
    //Create the end date components
    NSDateComponents *tomorrowDateComponents = [[NSDateComponents alloc] init];
    tomorrowDateComponents.day = 1;
	
    NSDate *endDate = [[NSCalendar currentCalendar] dateByAddingComponents:tomorrowDateComponents
                                                                    toDate:startDate
                                                                   options:0];
    
    
	// We will only search the default calendar for our events
	NSArray *calendarArray = [NSArray arrayWithObject:self.defaultCalendar];
    
    // Create the predicate
	NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:startDate
                                                                      endDate:endDate
                                                                    calendars:calendarArray];
	
	// Fetch all events that match the predicate
	NSMutableArray *events = [NSMutableArray arrayWithArray:[self.eventStore eventsMatchingPredicate:predicate]];
    
	return events;
}

#pragma mark -
#pragma mark Add a new event

// Display an event edit view controller when the user taps the "+" button.
// A new event is added to Calendar when the user taps the "Done" button in the above view controller.
- (IBAction)addEvent:(id)sender
{
	// Create an instance of EKEventEditViewController
	EKEventEditViewController *addController = [[EKEventEditViewController alloc] init];
	
	// Set addController's event store to the current event store
	addController.eventStore = self.eventStore;
    addController.editViewDelegate = self;
    [self presentViewController:addController animated:YES completion:nil];
}


#pragma mark -
#pragma mark EKEventEditViewDelegate

// Overriding EKEventEditViewDelegate method to update event store according to user actions.
- (void)eventEditViewController:(EKEventEditViewController *)controller
		  didCompleteWithAction:(EKEventEditViewAction)action
{
    AlarmTimerTriggersTVC * __weak weakSelf = self;
    
	// Dismiss the modal view controller
    [self dismissViewControllerAnimated:YES completion:^
    {
         if (action != EKEventEditViewActionCanceled)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 // Re-fetch all events happening in the next 24 hours
                 weakSelf.eventsList = [self fetchEvents];
                 // Update the UI with the above events
                 [weakSelf.tableView reloadData];
                 
                 EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:controller.event.endDate];
                 controller.event.alarms = [NSArray arrayWithObject:alarm];
                 NSError* error = nil;
                 
                 // Save the event again[1]
                 [controller.eventStore saveEvent: controller.event
                                  span: EKSpanThisEvent
                                 error: &error];
                 
                 [self setNSTimerAlarmAt:controller.event.endDate]; // instantiate a timer
                 
                 /* register for notifications
                 [[NSNotificationCenter defaultCenter] addObserver:self
                                                          selector:@selector(storeChanged:)
                                                              name:EKEventStoreChangedNotification
                                                            object:self.eventStore];
                 
                 */
                 // Upload event to Cloud
                 [self uploadNewEventToCloud:controller.event];
                 [self actionAddFriensoEven:controller.event.title andSubtitle:controller.event.location];
                 
                 /** Not sure how to handle this yet .........
                 // Schedule Notification at endDate
                 // On UILocalNotification [2]
                 UILocalNotification* localNotification = [[UILocalNotification alloc] init];
                 localNotification.fireDate = controller.event.endDate;
                 localNotification.alertBody = @"Event Finished";
                 localNotification.alertAction = @"Show me the item";
                 localNotification.timeZone = [NSTimeZone defaultTimeZone];
                 localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
                 
                 [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                 ***/
                 
                 // Schedule an alarm to do something at endDate
                 //[self setNSTimerAlarmAt:controller.event.endDate];
                 
                 /*
                 EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:controller.event.startDate];
                 [controller.event setAlarms:[NSArray arrayWithObject:alarm]];
                 
                 ** http://stackoverflow.com/questions/15237014/failing-to-save-ekreminder-in-ios-6
                 EKReminder *reminder = [EKReminder reminderWithEventStore:weakSelf.eventStore];
                 reminder.title = @"Time out";
                 reminder.calendar = self.defaultCalendar;//[self.eventStore defaultCalendarForNewReminders];
                 [reminder addAlarm:alarm];
                 NSError *error = nil;
                 [weakSelf.eventStore saveReminder:reminder commit:YES error:&error];
                 if(error)
                     NSLog(@"unable to Reminder!: Error= %@", error);
                 */
                 
             });
         }
         /*NSError *error = nil;
         switch (action) {
            case EKEventEditViewActionCanceled:
                 // Edit action canceled, do nothing.
                 break;
             case EKEventEditViewActionSaved:
                 [controller.eventStore saveEvent:controller.event span:EKSpanThisEvent error:&error];
                 NSLog(@"[ EKEventEditViewActionSaved ]");
                     // Re-fetch all events happening in the next 24 hours
                 weakSelf.eventsList = [self fetchEvents];
                     // Update the UI with the above events
                 [weakSelf.tableView reloadData];
                 NSLog(@"startDate:%@",controller.event.endDate);
                 
                 break;
             case EKEventEditViewActionDeleted:
                 // When deleting an event, remove the event from the event store,
                 // and reload table view.
                 // If deleting an event from the currenly default calendar, then update its
                 // eventsList.
                 break;
                 
             default:
                 break;
         }*/
     }];
}

//+ (EKReminder *)reminderWithEventStore:(EKEventStore *)eventStore{
//    
//};

// Set the calendar edited by EKEventEditViewController to our chosen calendar - the default calendar.
- (EKCalendar *)eventEditViewControllerDefaultCalendarForNewEvents:(EKEventEditViewController *)controller
{
	return self.defaultCalendar;
}

-(void) storeChanged:(NSNotification*)notification {
    // Should refetch all EKEvent and EKReminder objects you have accessed,
    // as they are considered stale.
    
    NSLog(@"[ event changed ]");
    
    NSArray *eventsList = [[NSArray alloc] initWithArray:[self fetchEvents]];
    
    for (EKEvent *fetchedEvent in eventsList){
        //  ... timer cannot be stopped if no timer has been instantiated something wrong here
        if (self->eventEndDateTimer != nil){
            [self->eventEndDateTimer setFireDate:fetchedEvent.endDate];
        } else
            [self setNSTimerAlarmAt:fetchedEvent.endDate]; // instantiate a timer
        
    }//ends for loop
    
}

-(void) uploadNewEventToCloud:(EKEvent *)calEvent {
    NSLog(@"[ uploadNewEventToCloud ]");
    
}

-(void) setNSTimerAlarmAt:(NSDate *)fireDate {
    // We need to play a sound at least every 10 seconds to keep the iPhone awake.
    // We create a new repeating timer, that begins firing now and then every ten seconds.
    // Every time it fires, it calls -playPreventSleepSound
    NSLog(@"[ fire alarm at: %@ ]",fireDate);
    self->eventEndDateTimer = [[NSTimer alloc] initWithFireDate:fireDate
                                                      interval:40.0
                                                        target:self
                                                      selector:@selector(sendSMStoCoreFriends)
                                                      userInfo:nil
                                                       repeats:NO];
    // We add this timer to the current run loop
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:self->eventEndDateTimer forMode:NSDefaultRunLoopMode];
}
- (void)stopAlarmTimer {
    NSLog(@"[ stopping endDate alarm ]");
    [self->eventEndDateTimer invalidate];
    self->eventEndDateTimer = nil;
}

-(void) sendSMStoCoreFriends {
    [self showAlert];
}

-(void) showAlert {
    if (self.alertView) {
        // if for some reason the code can trigger more alertviews before
        // the user has dismissed prior alerts, make sure we only let one of
        // them actually keep us as a delegate just to keep things simple
        // and manageable. if you really need to be able to issue multiple
        // alert views and be able to handle their delegate callbacks,
        // you'll have to keep them in an array!
        [self.alertView setDelegate:nil];
        self.alertView = nil;
    }
    
    
//    assert(self.alertView == nil);
//    AlarmTimerTriggersTVC * __weak weakSelf = self;
    self.alertView = [[UIAlertView alloc] initWithTitle:@"Frienso"
                                                message:@"Frienso Alarm:\n Send SMS to CoreFriends"
                                               delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:@"Yes", nil];
                      
//    assert(self.alertView != nil);
    [self.alertView show];
    
}

#pragma mark
#pragma mark - AlertView Delegate
- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    return YES;
}
-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"[ will dismiss ]");
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.alertView = nil; // release it
    
    NSLog(@"[ didDismiss ]");
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    NSLog(@"%@",title);

}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"[ 1 ]");
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    NSLog(@"%@",title);
    
//    if([title isEqualToString:@"Okay"])
//    {
//        /**
//        // Schedule Notification at endDate
//        // On UILocalNotification [2]
//        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
//        for(EKEvent *event in [self fetchEvents]) {
//            localNotification.fireDate = event.endDate; // if more
//        }
//        
//        localNotification.alertBody = @"Event Finished";
//        localNotification.alertAction = @"Show me the item";
//        localNotification.timeZone = [NSTimeZone defaultTimeZone];
//        localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
//        
//        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
//        **/
//        
//        // url: [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://kevinyavno.com"]];
//        NSLog(@"[Okay] Send SMS to: ");
//        [self stopAlarmTimer];
//        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
//    }else if ([title isEqualToString:@"Stop"]){
//        NSLog(@"[Stop Alarm]");
//        [self stopAlarmTimer];
//        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
//    }else {
//        NSLog(@"Do nothing ...");
//    }
}



//MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
//picker.messageComposeDelegate = delegate;
//
//NSString *phoneNumber = @"123456789";
//picker.recipients =[NSArray arrayWithObject: phoneNumber];
//picker.body =smsTxt;
//
//[delegate presentModalViewController:picker animated:YES];
@end

/** REFERENCES:
 1  http://stackoverflow.com/questions/14775954/set-ekalarm-in-iphone-app
 2  http://stackoverflow.com/questions/17803945/how-can-i-mark-an-ekevent-as-complete
 
 
 **/
