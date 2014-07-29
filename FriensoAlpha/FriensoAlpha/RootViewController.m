//
//  RootViewController.m
//  
//
//  Created by Salvador Aguinaga on 7/28/14.
//
//

#import "RootViewController.h"
#import "ProfileSneakPeekView.h"
#import "FRStringImage.h"


@interface RootViewController ()
@property (nonatomic,strong) ProfileSneakPeekView *profileView;

-(void)navigationCtrlrSingleTap;

@end

@implementation RootViewController

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
    
    UIView *newTitleView = [[UIView alloc] initWithFrame:self.navigationItem.titleView.frame];
    UIGestureRecognizer *navGestures = [[UIGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(navigationCtrlrSingleTap)];
    [navGestures setDelegate:self];
    
    UIImage *image = [UIImage imageNamed:@"avatar.png"];
    UIImage *scaledimage = [[[FRStringImage alloc] init] scaleImage:image toSize:CGSizeMake(38.0, 38.0)];
    UIImageView *imgView = [self newImageViewWithImage:scaledimage
                                           showInFrame:CGRectMake(0, 0, 38.0f, 38.0f)];
    imgView.contentMode  = UIViewContentModeScaleAspectFill;
    imgView.layer.cornerRadius = imgView.frame.size.height/2.0f;
    imgView.layer.borderWidth  = 1.0;
    imgView.layer.borderColor  = [UIColor whiteColor].CGColor;
    imgView.layer.masksToBounds = YES;
    [imgView setImage:image];
    [imgView setCenter:self.navigationItem.titleView.center];
    [newTitleView addSubview:imgView];
    //isolate tap to only the navigation bar
    [newTitleView addGestureRecognizer:navGestures];
    self.navigationItem.titleView  = newTitleView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Gesture Actions

-(void)navigationCtrlrSingleTap {
    NSLog(@"Tapped: %.2f", self.navigationController.navigationBar.frame.size.height);
    self.profileView = [[ProfileSneakPeekView alloc] initWithFrame:self.navigationController.navigationBar.frame];
    [self.profileView setUserEmailString:@"saguinag" withPhoneNumber:@"5743394087"];
    [self.view addSubview:self.profileView];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Helper Methods
-(UIImageView *) newImageViewWithImage:(UIImage *)image showInFrame:(CGRect)paramFrame{
    UIImageView *result = [[UIImageView alloc] initWithFrame:paramFrame];
    result.contentMode  = UIViewContentModeScaleAspectFit;
    result.image        = image;
    return result;
}
- (NSString *) stripStringOfUnwantedChars:(NSString *)phoneNumber {
    NSString *cleanedString = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    return cleanedString;
}

@end
