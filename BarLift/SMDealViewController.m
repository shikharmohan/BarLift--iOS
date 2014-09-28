//
//  SMDealViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 9/12/14.
//  Copyright (c) 2014 Shikhar Mohan. All rights reserved.
//

#import "SMDealViewController.h"
#import "SMBarInfoTranslucentView.h"
#import "UIToolbar+EEToolbarCenterButton.h"
#import "Reachability.h"
#import "SMSettingsViewController.h"
#import "SMContainerViewController.h"

@interface SMDealViewController ()

@property (strong, nonatomic) Reachability *internetReachableFoo;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIView *friendInfoView;
@property (strong, nonatomic) IBOutlet UILabel *acceptedLabel;
@property (strong, nonatomic) IBOutlet UILabel *dealsLeftLabel;
@property (strong, nonatomic) IBOutlet UIProgressView *dealsProgressView;
@property (strong, nonatomic) IBOutlet UILabel *goingOutLabel;
@property (strong, nonatomic) IBOutlet UIView *fbFriendsView;

@property (strong, nonatomic) IBOutlet SMBarInfoTranslucentView *barInfoView;
@property (weak, nonatomic) IBOutlet UILabel *barAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *barNameLabel;

@property (weak, nonatomic) IBOutlet UIView *dealInfoView;
@property (weak, nonatomic) IBOutlet UIImageView *dealImageView;
@property (weak, nonatomic) IBOutlet UILabel *dealNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dealDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (strong, nonatomic) NSMutableArray *activities;
@property (strong, nonatomic) PFObject *todaysDate;


@property (nonatomic) BOOL isAcceptedByCurrentUser;
@property (nonatomic) BOOL isDeclinedByCurrentUser;
@property (nonatomic) NSTimer* timer;
//toolbar
@property (strong, nonatomic) IBOutlet UIView *dealToolbarView;
@property (strong, nonatomic) IBOutlet UIButton *acceptButton;

@property (strong, nonatomic) UIView *acceptedView;
@property (strong, nonatomic) UIView *declinedView;



//decline button is public

@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsBarButtonItem;

@end

@implementation SMDealViewController

@synthesize declineButton; //make it public
@synthesize userElsewhere;
@synthesize userNotGoingOut;
@synthesize currentDeal;
@synthesize loc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpView];
    NSLog(@"%@", currentDeal);
    [self testInternetConnection];
    
    NSTimer *t = [NSTimer scheduledTimerWithTimeInterval: 15.0
                                                  target: self
                                                selector:@selector(setBarInformation)
                                                userInfo: nil repeats:YES];
    
    //get bar information every minute
    [t fire];

    
   //self.dealToolbar.centerButtonFeatureEnabled = YES;
    //[self addCenterButton];
    [self getRandomDealImage];
    if(currentDeal){
        self.acceptButton.enabled = YES;
        self.declineButton.enabled = YES;
    }
    else{
        self.acceptButton.enabled = NO;
        self.declineButton.enabled = NO;
        [self.acceptButton setBackgroundColor:[UIColor grayColor]];
        [self.declineButton setBackgroundColor:[UIColor grayColor]];
    }
    
    self.acceptedView = [[UIView alloc] initWithFrame:(CGRectMake(350, 195, 320, 75))];
    [self.acceptedView setBackgroundColor:[UIColor orangeColor]];
    [self.view addSubview:self.acceptedView];
    self.declinedView = [[UIView alloc] initWithFrame:(CGRectMake(-350, 195, 320, 75))];
    [self.declinedView setBackgroundColor:[UIColor colorWithRed:79.0/255.0 green:119.0/255.0 blue:179.0/255.0 alpha:1]];
    [self.view addSubview:self.declinedView];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40, 15, 250, 45)];
    [label setText:@"DEAL ACCEPTED!"];
    [label setFont:[UIFont fontWithName:@"STHeitiTC-Light" size:28.0f]];
    [label setTextColor:[UIColor whiteColor]];
    [self.acceptedView addSubview:label];

    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(30, 15, 300, 45)];
    [label2 setText:@"GOING ELSEWHERE"];
    [label2 setFont:[UIFont fontWithName:@"STHeitiTC-Light" size:28.0f]];
    [label2 setTextColor:[UIColor whiteColor]];
    [self.declinedView addSubview:label2];

    
    
    if(!self.isAcceptedByCurrentUser && !self.isDeclinedByCurrentUser)
    {
        self.acceptedView.hidden = YES;
        self.declinedView.hidden = YES;
    
    }
    else if (self.isAcceptedByCurrentUser)
    {
        self.acceptedView.hidden = NO;
    }
    else if(self.isDeclinedByCurrentUser)
    {
        self.declinedView.hidden = NO;
    }
    
    // Do any additional setup after loading the view.
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(setBarInformation) name: @"UpdateUINotification" object: nil];
    NSLog(@"Current deal before updating %@", currentDeal);
    NSLog(@"Current user before updating %@", [PFUser currentUser]);

    if([[PFUser currentUser] isDirty])
    {
        [[PFUser currentUser] saveInBackground];
        NSLog(@"Came back from settings and updated user info.");
    }
    if(!currentDeal && ([currentDeal isDirty] || [currentDeal isDataAvailable])){
        [currentDeal refresh];
        [currentDeal saveInBackground];
        NSLog(@"Came back from settings and updated deal info.");

    }
    [self setBarInformation];
    
    NSLog(@"View DEAL did appear called");
}

- (void) setUpView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //add background image
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"BarLiftBG4.jpg"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
        
    //bar info view set up

    self.barInfoView.translucentAlpha = 1;
    self.barInfoView.translucentStyle = UIBarStyleBlackTranslucent;
    self.barInfoView.translucentTintColor = [UIColor clearColor];
    self.barInfoView.backgroundColor = [UIColor clearColor];
    
    //deal/friend info border
    NSInteger borderThickness = 1;
    UIView *bottomBorder = [UIView new];
    bottomBorder.backgroundColor = [UIColor grayColor];
    bottomBorder.frame = CGRectMake(0, self.dealInfoView.frame.size.height - borderThickness, self.dealInfoView.frame.size.width, borderThickness);
    [self.dealInfoView addSubview:bottomBorder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{



}



#pragma mark - Button Actions
//- (void) didTapCenterButton
//{
//    NSLog(@"Center button tapped");
//}
//



//- (void) addCenterButton
//{
//    UIImage *centerButtonImage = [UIImage imageNamed:@"verify4.png"];
//    UIImage *centerButtonImageHighlighted = [UIImage imageNamed:@"checkmark16.png"];
//    EEToolbarCenterButtonItem *centerButtonItem = [[EEToolbarCenterButtonItem alloc]
//                                                   initWithImage:centerButtonImage
//                                                   highlightedImage:centerButtonImageHighlighted
//                                                   disabledImage:centerButtonImageHighlighted
//                                                   target:self
//                                                   action:@selector(didTapCenterButton)];
//
//    self.dealToolbar.centerButtonOverlay.buttonItem = centerButtonItem;
//
//}

- (IBAction)acceptButtonPressed:(UIButton *)sender
{
    if(self.activities == nil)
    {
        self.activities = [[NSMutableArray alloc] initWithCapacity:1];
    }
    if(currentDeal){
        [currentDeal refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            NSLog(@"Updating deal before accepting deal");
            [self checkAccept];
        }];
    }

    //View Flys in
    if(self.isDeclinedByCurrentUser){
        CGRect uiFrame = self.declinedView.frame;
        uiFrame.origin.x -= 350;
        self.acceptedView.hidden = NO;
        CGRect uiFrame1 = self.acceptedView.frame;
        uiFrame1.origin.x -= 350;
        [UIView animateWithDuration:1.5f animations:^{
            [self.declinedView setFrame:uiFrame];
            [self.acceptedView setFrame:uiFrame1];
        }];
    }
    else if(self.acceptedView.hidden)
    {
        self.acceptedView.hidden = NO;
        CGRect uiFrame1 = self.acceptedView.frame;
        uiFrame1.origin.x -= 350;
        [UIView animateWithDuration:1.5f animations:^{
            [self.acceptedView setFrame:uiFrame1];
        }];
    }
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 1.0;
    [self.declinedView.layer addAnimation:animation forKey:nil];
    
    self.declinedView.hidden = YES;

    self.acceptButton.enabled = NO;
    self.declineButton.enabled = YES;
    [self.acceptButton setBackgroundColor:[UIColor grayColor]];
    [self.declineButton setBackgroundColor:[UIColor colorWithRed:79.0/255.0 green:119.0/255.0 blue:179.0/255.0 alpha:1]];
    
}

- (IBAction)declineButtonPressed:(UIButton *)sender
{
    if(self.activities == nil)
    {
        self.activities = [[NSMutableArray alloc] initWithCapacity:1];
    }
    if(currentDeal){
        [currentDeal refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            NSLog(@"Updating deal before declining deal");
            [self checkDecline];
        }];
    }
    
    if(self.isAcceptedByCurrentUser){
        CGRect uiFrame = self.acceptedView.frame;
        uiFrame.origin.x += 350;
        self.declinedView.hidden = NO;
        CGRect uiFrame1 = self.declinedView.frame;
        uiFrame1.origin.x += 350;
        [UIView animateWithDuration:1.5f animations:^{
            [self.acceptedView setFrame:uiFrame];
            [self.declinedView setFrame:uiFrame1];
        }];
        self.acceptedView.hidden = YES;
    }
    else if(self.declinedView.hidden)
    {
        self.declinedView.hidden = NO;
        CGRect uiFrame1 = self.declinedView.frame;
        uiFrame1.origin.x += 350;
        [UIView animateWithDuration:1.5f animations:^{
            [self.declinedView setFrame:uiFrame1];
        }];
        self.acceptedView.hidden = YES;
    }
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 1.0;
    [self.acceptedView.layer addAnimation:animation forKey:nil];
    
    self.acceptedView.hidden = YES;

    self.acceptButton.enabled = YES;
    self.declineButton.enabled = NO;
    [self.acceptButton setBackgroundColor:[UIColor orangeColor]];
    [self.declineButton setBackgroundColor:[UIColor grayColor]];


}


#pragma mark - View Helper Methods
- (void) setBarInformation
{
    if(!currentDeal)
    {
        self.acceptedView.hidden = YES;
        self.declinedView.hidden = YES;
        self.isAcceptedByCurrentUser = NO;
        self.isDeclinedByCurrentUser = NO;
    }
    if(currentDeal && !self.isAcceptedByCurrentUser && !self.isDeclinedByCurrentUser)
    {
        self.acceptButton.enabled = YES;
        [self.acceptButton setBackgroundColor:[UIColor orangeColor]];
        [self.declineButton setBackgroundColor:[UIColor colorWithRed:79.0/255.0 green:119.0/255.0 blue:179.0/255.0 alpha:1]];
        self.declineButton.enabled = YES;    
    }
    PFQuery *query = [PFQuery queryWithClassName:@"Deal"];
    NSDate *date = [NSDate date];
    [query whereKey:@"deal_start_date" lessThanOrEqualTo:date];
    [query whereKey:@"deal_end_date" greaterThanOrEqualTo:date];
    [query whereKey:@"community_name" equalTo:[PFUser currentUser][@"university_name"]];
    [query setCachePolicy:kPFCachePolicyCacheElseNetwork];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            currentDeal = object;
                self.barNameLabel.text = object[@"location_name"];
                self.barAddressLabel.text = object[@"address"];
                self.dealNameLabel.text = object[@"name"];
                self.dealDescriptionLabel.text = [object objectForKey:@"description"];
            [self.activities addObject:object];
            [currentDeal saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [self createProgressBar];
                if(currentDeal[@"deal_qty"] > 0 && (!self.isAcceptedByCurrentUser && !self.isDeclinedByCurrentUser))
                {
                    self.acceptButton.enabled = YES;
                    [self.acceptButton setBackgroundColor:[UIColor orangeColor]];
                    [self.declineButton setBackgroundColor:[UIColor colorWithRed:79.0/255.0 green:119.0/255.0 blue:179.0/255.0 alpha:1]];
                    self.declineButton.enabled = YES;
                }
            }];
        }
        else if (error){
            self.dealNameLabel.text = @"Sorry No Deal Right Now \n Check Back Later";
            self.descriptionLabel.text = @"";
            self.dealDescriptionLabel.text = @"";
            currentDeal = nil;
            self.acceptButton.enabled = NO;
            self.declineButton.enabled = NO;
            [self.acceptButton setBackgroundColor:[UIColor grayColor]];
            [self.declineButton setBackgroundColor:[UIColor grayColor]];
            self.barNameLabel.text = @"";
            self.barAddressLabel.text = @"";
            self.goingOutLabel.text = @"0";
            [self createProgressBar];
            NSLog(@"Parse query for bars didnt work, %@", error);
        }
    }];
}

- (void) getRandomDealImage
{
    if(!currentDeal){
        [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
            if(!error){
                NSArray *dealPictureIDs = config[@"deal_pic_names"];
                NSUInteger randomIndex = arc4random() % [dealPictureIDs count];
                PFFile *picture = config[dealPictureIDs[randomIndex]];
                [picture getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    self.dealImageView.image = [UIImage imageWithData:data];
                }];
            }
            else{
                NSLog(@"could not load random image %@", error);
                self.dealImageView.image = [UIImage imageNamed:@"barlift-logo.png"];
            }
        }];
    }

}


#pragma mark - Accept/Decline Functions


- (void) saveAccept
{
    
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query whereKey:@"deal" equalTo:currentDeal];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * object, NSError *error) {
        if (!error) {
            [object setObject:@"accept" forKey:@"type"];
            [object saveInBackground];
            if(self.isDeclinedByCurrentUser) [currentDeal incrementKey:@"num_declined" byAmount:@-1];
            self.isAcceptedByCurrentUser = YES;
            self.isDeclinedByCurrentUser = NO;
            if(currentDeal[@"deal_qty"] > 0) [currentDeal incrementKey:@"deal_qty" byAmount:@-1];
            [currentDeal incrementKey:@"num_accepted" byAmount:@1];
            
            [currentDeal saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self createProgressBar]; //update progress bar
            }];
        }
        else if([[error userInfo][@"code"] isEqualToValue:@101])
        {
            PFObject *acceptActivity = [PFObject objectWithClassName:@"Activity"];
            [acceptActivity setObject:@"accept" forKey:@"type"];
            [acceptActivity setObject:[PFUser currentUser] forKey:@"user"];
            [acceptActivity setObject:currentDeal forKey:@"deal"];
            [acceptActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(self.isDeclinedByCurrentUser) [currentDeal incrementKey:@"num_declined" byAmount:@-1];
                self.isAcceptedByCurrentUser = YES;
                self.isDeclinedByCurrentUser = NO;
                if(currentDeal[@"deal_qty"] > 0) [currentDeal incrementKey:@"deal_qty" byAmount:@-1];
                [currentDeal incrementKey:@"num_accepted" byAmount:@1];
                
                [currentDeal saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [self createProgressBar]; //update progress bar
                }];
            }];
            NSLog(@"Error: %@", error);
        }
        else{
            NSLog(@"Error: %@", error);
        }
    }];


}

- (void) saveDecline
{
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query whereKey:@"deal" equalTo:currentDeal];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * object, NSError *error) {
        if (!error) {
            [object setObject:@"decline" forKey:@"type"];
            [object saveInBackground];
            if(self.isAcceptedByCurrentUser){
                [currentDeal incrementKey:@"num_accepted" byAmount:@-1];
                [currentDeal incrementKey:@"deal_qty" byAmount:@1];
            }
            self.isAcceptedByCurrentUser = NO;
            self.isDeclinedByCurrentUser = YES;
            [currentDeal incrementKey:@"num_declined" byAmount:@1];
            [currentDeal saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self createProgressBar];
            }];
        }
        else if([[error userInfo][@"code"] isEqualToValue:@101])
        {
            PFObject *declineActivity = [PFObject objectWithClassName:@"Activity"];
            [declineActivity setObject:@"decline" forKey:@"type"];
            [declineActivity setObject:[PFUser currentUser] forKey:@"user"];
            [declineActivity setObject:currentDeal forKey:@"deal"];
            [declineActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(self.isAcceptedByCurrentUser){
                    [currentDeal incrementKey:@"num_accepted" byAmount:@-1];
                    [currentDeal incrementKey:@"deal_qty" byAmount:@1];
                }
                self.isAcceptedByCurrentUser = NO;
                self.isDeclinedByCurrentUser = YES;
                [self.activities addObject:declineActivity];
                [currentDeal incrementKey:@"num_declined" byAmount:@1];
                [currentDeal saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [self createProgressBar];
                }];
                NSLog(@"bool updated %@", self.activities);
            }];
            NSLog(@"Error: %@", error);
        }
        else{
            NSLog(@"Error: %@", error);
        }
    }];
}

- (void) checkAccept
{
    if(self.isAcceptedByCurrentUser){
        return;
    }
    else if(self.isDeclinedByCurrentUser){
        [self saveAccept];
    }
    else
    {
        [self saveAccept];
    }
}

- (void) checkDecline
{
    if(self.isDeclinedByCurrentUser){
        return;
    }
    else if(self.isAcceptedByCurrentUser){
        [self saveDecline];
    }
    else
    {
        [self saveDecline];
    }
}

//- (void) saveElsewhere
//{
//    PFObject *ElsewhereActivity = [PFObject objectWithClassName:@"Activity"];
//    [ElsewhereActivity setObject:@"Elsewhere" forKey:@"type"];
//    [ElsewhereActivity setObject:[PFUser currentUser] forKey:@"user"];
//    [ElsewhereActivity setObject:currentDeal forKey:@"deal"];
//    [currentDeal incrementKey:@"num_Elsewhere" byAmount:@1];
//    [currentDeal saveInBackground];
//    [ElsewhereActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if(succeeded){
//            self.isAcceptedByCurrentUser = NO;
//            self.isDeclinedByCurrentUser = NO;
//            self.isElsewhereByCurrentUser = YES;
//            [self.activities addObject:ElsewhereActivity];
//        }
//        else{
//            NSLog(@"Could not save decline activity %@", error);
//        }
//        
//    }];
//}

//- (void) checkElsewhere
//{
//    if(self.isElsewhereByCurrentUser){
//        return;
//    }
//    else if(self.isAcceptedByCurrentUser){
//        for(PFObject *activity in self.activities){
//            [activity deleteInBackground];
//        }
//        [self.activities removeLastObject];
//        [self saveElsewhere];
//    }
//    else if(self.isDeclinedByCurrentUser){
//        for(PFObject *activity in self.activities){
//            [activity deleteInBackground];
//        }
//        [self.activities removeLastObject];
//        [self saveElsewhere];
//    }
//    else
//    {
//        [self saveElsewhere];
//    }
//}




#pragma mark - Reachability
// Checks if we have an internet connection or not
- (void)testInternetConnection
{
    self.internetReachableFoo = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is reachable
    self.internetReachableFoo.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Yayyy, we have the interwebs!");
        });
    };
    
    // Internet is not reachable
    self.internetReachableFoo.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Connection Issue" message:@"Please check your connection and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            NSLog(@"Someone broke the internet :(");
        });
    };
    
    [self.internetReachableFoo startNotifier];
}


#pragma mark - Progress View

- (void) createProgressBar
{
    if(currentDeal){
        NSNumber *accepted = [currentDeal objectForKey:@"num_accepted"];
        NSNumber *dealsLeft = [currentDeal objectForKey:@"deal_qty"];
        float totalDeals = [accepted floatValue] + [dealsLeft floatValue];
        NSLog(@"%f", totalDeals);
        float percent = 0.1;
        float used = [accepted floatValue]/totalDeals;
        NSLog(@"used %f", used);
        //    if(used < percent)
        //    {
        //        self.acceptedLabel.text = [NSString stringWithFormat:@"%d Accepted", 10];
        //        self.dealsLeftLabel.text = [NSString stringWithFormat:@"%d Deals Left", 100];
        //        [self.dealsProgressView setProgress:percent animated:YES];
        //    }
        //    else
        
        self.acceptedLabel.text = [NSString stringWithFormat:@"%d Accepted", [accepted integerValue]];
        self.dealsLeftLabel.text = [NSString stringWithFormat:@"%d Deals Left", [dealsLeft integerValue]];
        [self.dealsProgressView setProgress:used animated:YES];
        
        
        //Update people going out tonight
        // NSNumber *elsewhere = [currentDeal objectForKey:@"num_elsewhere"];
        NSNumber *elsewhere = @21;
        int totalGoingOut = [accepted integerValue] + [elsewhere integerValue];
        self.goingOutLabel.text = [NSString stringWithFormat:@"%d", totalGoingOut];
    }
    else{
        self.acceptedLabel.text = [NSString stringWithFormat:@"%d Accepted", 0];
        self.dealsLeftLabel.text = [NSString stringWithFormat:@"%d Deals Left", 0];
        [self.dealsProgressView setProgress:0 animated:YES];
    }
    
}

#pragma mark - Facebook Friends View

- (void) getFacebookFriends
{
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSLog(@"%@", result);
            // result will contain an array with your user's friends in the "data" key
            NSArray *friendObjects = [result objectForKey:@"data"];
            NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
            // Create a list of friends' Facebook IDs
            for (NSDictionary *friendObject in friendObjects) {
                [friendIds addObject:[friendObject objectForKey:@"id"]];
            }
            
            // Construct a PFUser query that will find friends whose facebook ids
            // are contained in the current user's friend list.
            PFQuery *friendQuery = [PFUser query];
            [friendQuery whereKey:@"fb_id" containedIn:friendIds];
            
            // findObjects will return a list of PFUsers that are friends
            // with the current user
            [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if(!error)
                {
                    NSArray *friendUsers = objects;
                    for(int i = 0; i < [friendUsers count]; i++){
                        PFObject *currentFriend = friendUsers[i];
                        NSURL *url = [NSURL URLWithString:currentFriend[@"profile"][@"pictureURL"]];
                        NSData *data = [NSData dataWithContentsOfURL:url];
                        UIImage *img = [[UIImage alloc] initWithData:data];
                        UIImageView *iv = [[UIImageView alloc] initWithImage:img];
                        iv.layer.cornerRadius = iv.frame.size.height/2;
                        iv.layer.masksToBounds = YES;
                        iv.layer.borderWidth = NO;
                        
                        [self.fbFriendsView addSubview:iv];

                    }
                }
            }];
            
        }
    }];


}



@end
