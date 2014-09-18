//
//  SMPopUpViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 9/17/14.
//  Copyright (c) 2014 Shikhar Mohan. All rights reserved.
//

#import "SMPopUpViewController.h"
#import "SMDealViewController.h"
@interface SMPopUpViewController ()

@end

@implementation SMPopUpViewController
@synthesize currentDealID;

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
    //add background image
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"deal_background.png"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];

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
    

    // Do any additional setup after loading the view.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //disable Decline Button
    SMDealViewController *dealController = segue.destinationViewController;
    dealController.justDeclined = YES;
    if([segue.identifier isEqualToString:@"notGoingOutToDealSegue"]){
        dealController.userNotGoingOut = YES;
        dealController.userElsewhere = NO;
    }
    else if([segue.identifier isEqualToString:@"elsewhereToDealSegue"]){
        dealController.userNotGoingOut = NO;
        dealController.userElsewhere = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - IBActions
- (IBAction)notGoingOutButtonPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"notGoingOutToDealSegue" sender:self];
    
}

- (IBAction)elsewhereButtonPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"elsewhereToDealSegue" sender:self];
}


@end
