//
//  SMContainerViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 9/22/14.
//  Copyright (c) 2014 Shikhar Mohan. All rights reserved.
//

#import "SMContainerViewController.h"
#import "SMDealViewController.h"
#import "SMFriendsViewController.h"
#import "SMSettingsViewController.h"

@interface SMContainerViewController ()
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *muteButtonItem;
@property (nonatomic) BOOL muteOn;
@property (strong, nonatomic) SMDealViewController *dealController;
@property (nonatomic) CGFloat lastContentOffset;
@end

@implementation SMContainerViewController
@synthesize locationsArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //navigation bar set up
    [self.navigationItem setHidesBackButton:YES];
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // iOS 6.1 or earlier
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    } else {
        // iOS 7.0 or later
        self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
        self.navigationController.navigationBar.translucent = YES;
    }
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
        NSString * storyboardName = @"Main";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    
        UIViewController * friend = [storyboard instantiateViewControllerWithIdentifier:@"friendsViewController"];
        [self addChildViewController:friend];
        [self.scrollView addSubview:friend.view];
        [friend didMoveToParentViewController:self];
        
    
        UIViewController * deal = [storyboard instantiateViewControllerWithIdentifier:@"dealViewController"];
        self.dealController = (SMDealViewController *) deal;
        if(!self.dealController.currentDeal) self.muteButtonItem.enabled = NO;
        [self addChildViewController:deal];
        [self.scrollView addSubview:deal.view];
        [deal didMoveToParentViewController:self];
    
        CGRect adminFrame = deal.view.frame;
        adminFrame.origin.x = adminFrame.size.width;
        friend.view.frame = adminFrame;
    
        [self.scrollView setContentSize:CGSizeMake(2*self.view.frame.size.width, self.view.frame.size.height)];
    // Do any additional setup after loading the view.
}

- (void) viewDidAppear:(BOOL)animated
{
    if(self.dealController.currentDeal) self.muteButtonItem.enabled = YES;
}


- (void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (self.lastContentOffset > scrollView.contentOffset.x)
    {
        self.navigationItem.title = @"Today's Deal";
    }
    else if (self.lastContentOffset < scrollView.contentOffset.x)
    {
        self.navigationItem.title = @"Who's Going";
    }
    self.lastContentOffset = scrollView.contentOffset.x;

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    if([segue.identifier isEqualToString:@"containerToSettingsSegue"])
    {
        SMSettingsViewController *vc = [segue destinationViewController];
        //send deal info
        [vc performSelector:@selector(setDeal:)
                 withObject:self.dealController.currentDeal];
        [vc performSelector:@selector(setLocationSettingsArray:)
                 withObject:locationsArray];
    }
}

- (IBAction)muteButtonPressed:(UIBarButtonItem *)sender {
    if(!self.muteOn){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Mute ON" message:@"You will not receive notifications for tonight" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [self.muteButtonItem setTintColor:[UIColor redColor]];
        self.muteOn = YES;
    }
    else{
        [self.muteButtonItem setTintColor:[UIColor whiteColor]];
        self.muteOn = NO;
    }

}

@end
