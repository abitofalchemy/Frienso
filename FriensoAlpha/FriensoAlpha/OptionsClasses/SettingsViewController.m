//
//  SettingsViewController.m
//  FriensoAlpha
//
//  Created by Sal Aguinaga on 3/3/14.
//  Copyright (c) 2014 ABitOfAlchemy. All rights reserved.
//

#import "SettingsViewController.h"
#import "aBoAViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SettingsViewController ()
@property (nonatomic,strong) UITextField *editAlarmTimer;
@property(nonatomic) CGRect buttonFrame;
@end

@implementation SettingsViewController

- (void) setText:(NSString *)paramText{
    self.title = paramText;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)loadView{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    UIView *contentView = [[UIView alloc] initWithFrame:applicationFrame];
    contentView.backgroundColor = UIColorFromRGB(0xecf0f1);
    self.view = contentView;
    
    self.buttonFrame = CGRectMake(0, 0, self.view.frame.size.width/2, 40);
    /*  Tell others about Frienso
     *  Help Center
     *  ? Activity Log
     *  Terms & Policies
     *  Report a Problem
     *  Log Out      
     ********************/
    // Share Frienso
    [self setupShareFrienso];
    
    // Help Center
    [self setupHelpCenter];
    
    // Report a Problem
    [self setupReportProblem];
    
    // Logout Button
    UIButton *logoutBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    [logoutBtn setTitle:@"Logout" forState:UIControlStateNormal];
    
    [logoutBtn addTarget:self
                  action:@selector(logoutAction:)
        forControlEvents:UIControlEventTouchUpInside];
    [logoutBtn.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:16.0]];
    logoutBtn.layer.cornerRadius = 4.0f;
    logoutBtn.layer.borderWidth = 0.75f;
    logoutBtn.layer.borderColor = [UIColor blackColor].CGColor;
    //    logoutBtn.layer.backgroundColor = [UIColor colorWithRed:250/255.00f green:244/250.00f
    //                                                       blue:250/255.00f alpha:0.7f].CGColor;
    [logoutBtn setCenter:CGPointMake(self.view.center.x, self.view.center.y)];
    [logoutBtn.titleLabel setTextColor:[UIColor blackColor]];
    [self.view addSubview:logoutBtn];
    
    // Timer length
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText:@"Alarm Time Duration:"];
    [label setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:14.0]];
    [label sizeToFit];
    label.center = CGPointMake(self.view.center.x * 0.05 + label.frame.size.width/2,
                               self.view.bounds.size.height*0.48);
    [self.view addSubview:label];
    
    self.editAlarmTimer = [[UITextField alloc] initWithFrame:self.buttonFrame];
    [self.editAlarmTimer setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:16.0]];
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"AlarmDuration"]);
    NSString *duration = [NSString stringWithFormat:@"00:00:%@", ([[NSUserDefaults standardUserDefaults] objectForKey:@"AlarmDuration"] == NULL) ? @"10" : [[NSUserDefaults standardUserDefaults] objectForKey:@"AlarmDuration"]];
    self.editAlarmTimer.placeholder = duration;
    self.editAlarmTimer.textAlignment = NSTextAlignmentCenter;
    self.editAlarmTimer.keyboardType = UIKeyboardTypeNumberPad;
    self.editAlarmTimer.delegate = self;
    self.editAlarmTimer.layer.cornerRadius = 6.0f;
    self.editAlarmTimer.layer.borderWidth = 0.5f;
    self.editAlarmTimer.layer.borderColor = [UIColor blackColor].CGColor;
    self.editAlarmTimer.layer.backgroundColor = [UIColor colorWithRed:250/255.00f green:244/250.00f
                                                         blue:250/255.00f alpha:0.7f].CGColor;
    [self.editAlarmTimer setCenter:CGPointMake(self.view.bounds.size.width - 12 - self.editAlarmTimer.frame.size.width/2, self.view.center.y)];
    [self.view addSubview:self.editAlarmTimer];
    
    [UIView animateWithDuration:0.8 animations:^{
        //[editAlarmTimer setCenter:CGPointMake(self.view.center.x, self.view.bounds.size.height*0.5)];
        [logoutBtn setCenter:CGPointMake(self.view.center.x, self.view.bounds.size.height*0.8)];
    }];
    
    /** gestures **/
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:nil usingBlock:^(NSNotification *notification) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [self.view addGestureRecognizer:tap];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *notification) {
        [self.view removeGestureRecognizer:[self.view.gestureRecognizers lastObject]];
    }];
    /** end gestures dismisses the keyboard nicely **/
}

//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//	// Do any additional setup after loading the view.
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setup UI
- (void) setupShareFrienso {
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectZero];
    [label1 setTextAlignment:NSTextAlignmentCenter];
    [label1 setText:@"Tell Others About Frienso:"];
    [label1 setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:14.0]];
    [label1 sizeToFit];
    CGFloat vwidth =self.view.bounds.size.width;
    CGFloat vheight=self.view.bounds.size.height;
    label1.frame = CGRectMake(vwidth *0.05, vheight *0.13,
                              label1.frame.size.width, label1.frame.size.height);
    [self.view addSubview:label1];
    
    UIButton *button = [[UIButton alloc] initWithFrame:self.buttonFrame];
    [button setTitle:@"Share Frienso" forState:UIControlStateNormal];

    [button addTarget:self
                         action:@selector(shareFriensoAction:)
               forControlEvents:UIControlEventTouchUpInside];
    [button.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:16.0]];
    button.layer.cornerRadius = 6.0f;
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    //    button.layer.backgroundColor = [UIColor colorWithRed:250/255.00f green:244/250.00f
    //                                                       blue:250/255.00f alpha:0.7f].CGColor;
    [button setCenter:CGPointMake(self.view.bounds.size.width - 12 - button.frame.size.width/2,
                                            self.view.bounds.size.height*0.2)];
    [button.titleLabel setTextColor:UIColorFromRGB(0x2c3e50)];
    [self.view addSubview:button];
}
- (void) setupHelpCenter{
    // Timer length
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectZero];
    [label1 setTextAlignment:NSTextAlignmentCenter];
    [label1 setText:@"Help Center:"];
    [label1 setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:14.0]];
    [label1 sizeToFit];
    label1.center = CGPointMake(self.view.center.x * 0.1 + label1.frame.size.width/2,
                                self.view.bounds.size.height*0.25);
    [self.view addSubview:label1];
    
    UIButton *button = [[UIButton alloc] initWithFrame:self.buttonFrame];
    [button setTitle:@"About Frienso" forState:UIControlStateNormal];

    [button addTarget:self
                         action:@selector(helpInfoAction:)
               forControlEvents:UIControlEventTouchUpInside];
    [button.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:16.0]];
    button.layer.cornerRadius = 6.0f;
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    //    button.layer.backgroundColor = [UIColor colorWithRed:250/255.00f green:244/250.00f
    //                                                       blue:250/255.00f alpha:0.7f].CGColor;
    [button setCenter:CGPointMake(self.view.bounds.size.width - 12 - button.frame.size.width/2, self.view.bounds.size.height*0.3)];
    [button.titleLabel setTextColor:UIColorFromRGB(0x2c3e50)];
    [self.view addSubview:button];
}
- (void) setupReportProblem{
    // Timer length
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectZero];
    [label1 setTextAlignment:NSTextAlignmentCenter];
    [label1 setText:@"Report a Problem:"];
    [label1 setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:14.0]];
    [label1 sizeToFit];
    label1.center = CGPointMake(self.view.center.x * 0.1 + label1.frame.size.width/2,
                               self.view.bounds.size.height*0.35);
    [self.view addSubview:label1];
    
    UIButton *button = [[UIButton alloc] initWithFrame:self.buttonFrame];
    [button setTitle:@"Send us email" forState:UIControlStateNormal];
    [button addTarget:self
                         action:@selector(reportProblemAction:)
               forControlEvents:UIControlEventTouchUpInside];
    [button.titleLabel setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Medium" size:16.0]];
    button.layer.cornerRadius = 6.0f;
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    //    button.layer.backgroundColor = [UIColor colorWithRed:250/255.00f green:244/250.00f
    //                                                       blue:250/255.00f alpha:0.7f].CGColor;
    [button setCenter:CGPointMake(self.view.bounds.size.width - 12 - button.frame.size.width/2, self.view.bounds.size.height*0.4)];
    [button.titleLabel setTextColor:UIColorFromRGB(0x2c3e50)];
    [self.view addSubview:button];
}

#pragma mark - Actions or selectors
-(void) helpInfoAction:(id) sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"  bundle:nil];
    aBoAViewController  *rtvc = (aBoAViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"helpInfoVC"];
    [self.navigationController pushViewController:rtvc animated:YES];
}
-(void) logoutAction:(id) sender {
    [sender setEnabled:YES];
    NSLog(@"[ logout ]");
//TODO: logout in full
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void) shareFriensoAction:(id) sender {
    NSArray *recipientsArray = [NSArray arrayWithObject:@"frienso@gmail.com"];
    [self sendEmailTo:recipientsArray
          withSubject:@"Frienso: The safety app for colleges and university campuses"
       withBodyHeader:@"-- Learn about what Frienso is and "
                       "how you can benefit from using it!\n"
                       "---------------------------------------\n"];
}
-(void) reportProblemAction:(id) sender {
    NSLog(@"[ reporting a problem  ]");
    NSArray *recipientsArray = [NSArray arrayWithObject:@"frienso@gmail.com"];
    [self sendEmailTo:recipientsArray withSubject:@"Reporting a problem" withBodyHeader:@"-- FRIENSO Problem Report -- "];
}

-(void) sendEmailTo:(NSArray *)toRecipients withSubject:(NSString *)subject withBodyHeader:(NSString *)bodyHeader {
    if ([MFMailComposeViewController canSendMail]) {
        
//        // Set up the text for the email body.
//        NSDateFormatter *df = [[NSDateFormatter alloc] init];
//        [df setDateFormat:@"HH:mm:ss 'on' EEEE MMMM d, YYYY"];
//        NSString* dateString = [df stringFromDate:[NSDate date]];
        
//        NSString *emailBody = [NSString stringWithFormat:
//                               @"-- FRIENSO Problem Report -- "];
        
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        
        [picker setSubject:subject];
        
        // Set up recipients
        [picker setToRecipients:toRecipients];
        
//        // Attach an image to the email
//        UIImage* img = [UIImage imageWithContentsOfFile:self.testResult.image];
//        NSData *imgData = UIImagePNGRepresentation(img);
//        [picker addAttachmentData:imgData mimeType:@"image/png" fileName:@"Results.png"];
        
        [picker setMessageBody:bodyHeader isHTML:NO];
        
        [self presentViewController:picker animated:YES completion:nil];
        
    } else {
        UIAlertView* noMailAlert = [[UIAlertView alloc] initWithTitle:@"Cannot send e-mail" message:@"Make sure you are connected to the internet and that a mail account is set up on this device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [noMailAlert show];
    }
    

}
// Dismisses the email composition interface when users tap Cancel or Send.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)mailResult error:(NSError*)error
{
    // Dismiss the mail composer view controller
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (mailResult == MFMailComposeResultSaved || mailResult == MFMailComposeResultSent) {
        NSLog(@"Email sent ...");
    } else if ( mailResult == MFMailComposeResultCancelled ) {
        // User cancelled. sniff
    } else {
        UIAlertView* badReportView = [[UIAlertView alloc] initWithTitle:@"Report not sent"
                                                                message:@"Could not send the report. Please try again later."
                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [badReportView show];
    }
    
}
#pragma mark - TextField delegate
-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField{
    NSLog(@"_ began editing _");
    return YES;
}
-(void) textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"_ textFieldDidBeginEditing _");
}
-(void) textFieldDidEndEditing:(UITextField *)textField {
    //NSLog(@"_ end editing _");
    //NSLog(@"%lu", (unsigned long)[textField.text length]);
    switch ([textField.text length]) {
        case 0:
            break;
        case 1:
            
            if ( [textField.text integerValue] < 5){
                [[[UIAlertView alloc] initWithTitle:@"Alarm Duration Range" message:@"We recommend a duration between 5 and up to 59 seconds" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show ];
            }
            [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:@"AlarmDuration"];
            [self.editAlarmTimer setText:[NSString stringWithFormat:@"00:00:0%@", textField.text]];
            break;
        case 2:
            [[NSUserDefaults standardUserDefaults] setObject:textField.text forKey:@"AlarmDuration"];
            [self.editAlarmTimer setText:[NSString stringWithFormat:@"00:00:%@", textField.text]];
            break;
        case 3:
        {
            
            [[[UIAlertView alloc] initWithTitle:@"Alarm Duration Range" message:@"We recommend a duration between 5 and up to 59 seconds" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil] show ];
            
            
            break;
        }
        default:
            NSLog(@"%@",[textField.text substringFromIndex:[textField.text length]-2]);
            [[NSUserDefaults standardUserDefaults] setObject:[textField.text substringFromIndex:[textField.text length]-2] forKey:@"AlarmDuration"];
            break;
            
    };
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)dismissKeyboard:(UIGestureRecognizer *)gesture
{
    [self.view endEditing:NO];
}

@end
