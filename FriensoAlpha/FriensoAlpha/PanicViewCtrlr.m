//
//  PanicViewCtrlr.m
//  Frienso_iOS
//
//  Created by Sal Aguinaga on 2/16/14.
//  Copyright (c) 2014 Salvador Aguinaga. All rights reserved.
//

#import "PanicViewCtrlr.h"
#import "FriensoEvent.h"
#import <Parse/Parse.h>
#import "FriensoAppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>

@interface PanicViewCtrlr ()
{
    int time;
    bool overrideTimer;
}
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *lowerLabel;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel* timerLabel;
@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic, strong) NSFetchedResultsController *frc;

@end

@implementation PanicViewCtrlr

#pragma mark - Core Data access
- (void) createNewEvent:(NSString *) eventTitleStr{
    
    FriensoAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *managedObjectContext =
    appDelegate.managedObjectContext;
    
    FriensoEvent *newEvent =
    [NSEntityDescription insertNewObjectForEntityForName:@"FriensoEvent"
                                  inManagedObjectContext:managedObjectContext];
    
    if (newEvent != nil){
        
        newEvent.eventTitle = eventTitleStr;
        newEvent.eventSubtitle = @"Panic alarm timed out and alerts were sent";
        //TODO: Need to figure out core location
        newEvent.eventLocation  = @"Here";
        newEvent.eventContact   = [[NSUserDefaults standardUserDefaults] objectForKey:@"adminID"];
        newEvent.eventCreated   = [NSDate date];
        newEvent.eventModified  = [NSDate date];
        
        NSError *savingError = nil;
        
        if ([managedObjectContext save:&savingError]){
            NSLog(@"Successfully saved event.");
        } else {
            NSLog(@"Failed to save the managed object context.");
        }
        
    } else {
        NSLog(@"Failed to create the new person object.");
    }
    
}
#pragma mark - PanicViewCtrl
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSLog(@"Hello Panic");
    [self setupCancelButton];
    [self setupTopLabel];
    [self setupLowerLabel];
    
    [self setupNavigationBarImage];

    [self initializeTimer];
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSAttributedString *) attributedText{
    
    NSString *string = @"We will email and text\n"
                        "everyone in your\n"
                        "Core Circle of Friends";
    
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc]
                                         initWithString:string];
    
//    NSDictionary *attributesForFirstWord = @{
//                                             NSFontAttributeName : [UIFont boldSystemFontOfSize:48.0f],
//                                             NSForegroundColorAttributeName : [UIColor redColor],
//                                             NSBackgroundColorAttributeName : [UIColor blackColor]
//                                             };
//    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor darkGrayColor];
    shadow.shadowOffset = CGSizeMake(1.5f, 1.5f);
    
    UIFont *myFont = [ UIFont fontWithName: @"HelveticaNeue-Medium" size: 20.0 ];
    NSDictionary *attributesForSecondWord = @{
                                              NSFontAttributeName : myFont,
                                              NSForegroundColorAttributeName : [UIColor redColor],
                                              NSBackgroundColorAttributeName : [UIColor clearColor],
                                              NSShadowAttributeName : shadow
                                              };
    
//    /* Find the string "iOS" in the whole string and sets its attribute */
//    [result setAttributes:attributesForFirstWord
//                    range:[string rangeOfString:@"iOS"]];
    
    /* Do the same thing for the string "SDK" */
    [result setAttributes:attributesForSecondWord
                    range:[string rangeOfString:string]];
    
    return [[NSAttributedString alloc] initWithAttributedString:result];
    
}


-(void) setupNavigationBarImage{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,100.f,40.0f)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *image = [UIImage imageNamed:@"frienso-dashboard-bar.png"];
    [imageView setImage:image];
    
    self.navigationItem.titleView = imageView;
}
-(void) setupTopLabel{
    self.label = [[UILabel alloc] init];
    self.label.backgroundColor = [UIColor clearColor];
    self.label.text = @"HelpNow!!";
    self.label.font = [UIFont boldSystemFontOfSize:48.0f];
    self.label.textColor = [UIColor blackColor];
    self.label.shadowColor = [UIColor lightGrayColor];
    self.label.shadowOffset = CGSizeMake(2.0f, 2.0f);
    [self.label sizeToFit];
    
    self.label.center = CGPointMake(self.view.center.x,self.view.bounds.size.height*0.1);
    [self.view addSubview:self.label];
}
-(void) setupLowerLabel{
    self.lowerLabel = [[UILabel alloc] init];
    self.lowerLabel.backgroundColor = [UIColor clearColor];
    self.lowerLabel.attributedText = [self attributedText];
    self.lowerLabel.numberOfLines = 3;
    self.lowerLabel.textAlignment = NSTextAlignmentCenter;
    [self.lowerLabel sizeToFit];
    
    self.lowerLabel.center = CGPointMake(self.view.center.x,
                                         self.button.frame.origin.y*0.9 );
    [self.view addSubview:self.lowerLabel];
}

-(void) cancelPanicMethod:(id) sender {
    if ( self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    NSLog(@"[ HelpNow!ing Cancelled ]");
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
// Update our timer label
- (void) timerUpdate {
    time -= 1;
    self.timerLabel.text = [NSString stringWithFormat:@":%2ds", time];
    if (time <= 0)
        [self performSelector:@selector(sendHelpNowNotification)
                   withObject:nil afterDelay:0.];
}
-(void) initializeTimer{
    
    // ring background
    UIImage *bgRingImg     = [UIImage imageNamed:@"alert-ring-bg.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:bgRingImg];
    //NSLog(@"%f,%f", bgRingImg.size.width, bgRingImg.size.height);
    imageView.frame = CGRectMake(0, 0, 168, 168);
    imageView.center = self.view.center;
    [self.view addSubview:imageView];
    [UIView animateWithDuration:0.9 animations:^{
        imageView.layer.affineTransform = CGAffineTransformMakeScale(10.0, 10.0); // To make a view larger:
        //self.view.layer.affineTransform = CGAffineTransformMakeScale(0.0, 0.0); // to make a view smaller
    }];
    // To reset views back to their initial size after changing their sizes:
    [UIView animateWithDuration:0.9 animations:^{
        imageView.layer.affineTransform = CGAffineTransformIdentity;
        //otherView.layer.affineTransform = CGAffineTransformIdentity;
    }];
    // Initialize our timer and label
    time = 7;
    overrideTimer = NO;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(timerUpdate)
                                                userInfo:nil
                                                 repeats:YES];
    
    self.timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x, 10, 120, 40)];
    self.timerLabel.backgroundColor = [UIColor clearColor];
    self.timerLabel.font = [UIFont fontWithName:@"AppleSDGothicNeo-SemiBold" size:60.];
    self.timerLabel.text = @":07s";
    [self.timerLabel sizeToFit];
    [self.view addSubview:self.timerLabel];

    self.timerLabel.center = self.view.center;
}
-(void) setupCancelButton {
    //
    
    self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.button addTarget:self
                    action:@selector(cancelPanicMethod:)
          forControlEvents:UIControlEventTouchDown];
    [self.button setTitle:@"Cancel" forState:UIControlStateNormal];
    self.button.frame = CGRectMake(0, 0, 160.0, 40.0);
    [self.button setCenter:CGPointMake(self.view.bounds.size.width/2.0f, self.view.bounds.size.height*0.9f)];
    self.button.layer.cornerRadius = 8.0f;
    _button.layer.borderWidth = 1.2f;
    _button.layer.borderColor = [UIColor blueColor].CGColor;
    UIFont *myFont = [ UIFont fontWithName: @"AppleSDGothicNeo-SemiBold" size: 14.0 ];
    _button.titleLabel.font = myFont;
    
    [self.view addSubview:_button];
}
-(void) sendHelpNowNotification {
    NSLog(@"[ sending notifications to core friends ]");
    if ( self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    //Code to send HelpNow!s to all friends with your location information
    
    /**************PUSH NOTIFICATIONS: HELP ME NOW!!!! *****************/
    
    //Query Parse to know who your "accepted" core friends are and send them each a notification
    
    PFQuery *query = [PFQuery queryWithClassName:@"CoreFriendRequest"];
    [query whereKey:@"status" equalTo:@"accept"];
    [query whereKey:@"sender" equalTo:[PFUser currentUser]];
    [query includeKey:@"recipient"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            //NSLog(@"Successfully retrieved %d scores.", objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                NSString *myString = @"Ph";
                NSString *personalizedChannelNumber = [myString stringByAppendingString:object[@"recipient"][@"phoneNumber"]];
                NSLog(@"Phone Number for this friend is: %@", personalizedChannelNumber);
                
                PFPush *push = [[PFPush alloc] init];
                
                // Be sure to use the plural 'setChannels' if you are sending to more than one channel.
                [push setChannel:personalizedChannelNumber];
                NSString *coreRqstHeader = @"HELP REQUEST FROM: ";
                NSString *coreFrndMsg = [coreRqstHeader stringByAppendingString:[[PFUser currentUser] objectForKey:@"username"]];
                
                [push setMessage:coreFrndMsg];
                [push sendPushInBackground];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    /**************END OF PUSH NOTIFICATIONS: HELP ME NOW!!!! *****************/
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self createNewEvent:@"Sent HelpNow! Notification"];
    [[[UIAlertView alloc] initWithTitle: @"Notifications Sent"
                                message: @"Your core circle has been notified!"
                               delegate: nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}
@end
