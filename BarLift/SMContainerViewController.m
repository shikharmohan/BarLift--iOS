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
@interface SMContainerViewController ()
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *muteButtonItem;

@end

@implementation SMContainerViewController

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
    [self addChildViewController:deal];
    [self.scrollView addSubview:deal.view];
    [deal didMoveToParentViewController:self];
    
    CGRect adminFrame = deal.view.frame;
    adminFrame.origin.x = adminFrame.size.width;
    friend.view.frame = adminFrame;
    
    [self.scrollView setContentSize:CGSizeMake(2*self.view.frame.size.width, self.view.frame.size.height)];
    
    
    
    // Do any additional setup after loading the view.
}




- (void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if(self.scrollView.contentOffset.x > 5)
    {
        if([self.navigationItem.title  isEqual: @"Today's Deal"]) self.navigationItem.title = @"Who's Going";
        else if ([self.navigationItem.title isEqual:@"Who's Going"]) self.navigationItem.title = @"Today's Deal";
    }
    else{
        self.navigationItem.title = @"Today's Deal";
    }

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)muteButtonPressed:(UIBarButtonItem *)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hot Deal Notification ON" message:@"You will be notified when this deal becomes popular" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    [self.muteButtonItem setTintColor:[UIColor redColor]];
}

@end
