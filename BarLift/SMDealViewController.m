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
#import "SMProgressView.h"
#import "Reachability.h"
#import "SMSettingsViewController.h"

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
@property (strong, nonatomic) PFObject *currentDeal;
@property (strong, nonatomic) PFObject *todaysDate;


@property (nonatomic) BOOL isAcceptedByCurrentUser;
@property (nonatomic) BOOL isDeclinedByCurrentUser;
@property (nonatomic) SMProgressView* progressView;
@property (nonatomic) NSTimer* timer;
//toolbar
@property (strong, nonatomic) IBOutlet UIToolbar *dealToolbar;
@property (strong, nonatomic) IBOutlet UIButton *acceptButton;
//decline button is public

@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsBarButtonItem;
@property (strong, nonatomic) IBOutlet UIButton *hotButton;
@property (nonatomic) BOOL isHot;

@end

@implementation SMDealViewController

@synthesize declineButton; //make it public
@synthesize userElsewhere;
@synthesize userNotGoingOut;
@synthesize locationsArray;

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
    self.progressView = [[SMProgressView alloc] initWithFrame:self.friendInfoView.bounds];
    NSLog(@"%@", self.currentDeal);
    [self testInternetConnection];
    [self setBarInformation];
    NSLog(@"%@", self.currentDeal);
   //self.dealToolbar.centerButtonFeatureEnabled = YES;
    //[self addCenterButton];
    [self getRandomDealImage];
    if(!self.currentDeal){
        self.acceptButton.enabled = YES;
        self.declineButton.enabled = YES;
    }
    [self getFacebookFriends];
    
    
    // Do any additional setup after loading the view.
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(setBarInformation) name: @"UpdateUINotification" object: nil];
    NSLog(@"%@", [PFUser currentUser]);
    if(!self.currentDeal){
        self.acceptButton.enabled = YES;
        self.declineButton.enabled = YES;
    }
    if([[PFUser currentUser] isDirty]) [[PFUser currentUser] saveInBackground];
    if(!self.currentDeal && ([self.currentDeal isDirty] || [self.currentDeal isDataAvailable])){
        [self.currentDeal refresh];
        [self.currentDeal saveInBackground];
    }
    NSLog(@"View DEAL did appear called");
}

- (void) setUpView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    
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
    if([segue.identifier isEqualToString:@"dealToSettings"])
    {
        SMSettingsViewController *vc = [segue destinationViewController];
        //send deal info
        [vc performSelector:@selector(setDeal:)
                 withObject:self.currentDeal];
        [vc performSelector:@selector(setLocationSettingsArray:)
                 withObject:locationsArray];
    }


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
    if(self.currentDeal){
        [self.currentDeal refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            NSLog(@"Updating deal before accepting deal");
            [self checkAccept];
        }];
    }    self.acceptButton.enabled = NO;
    self.declineButton.enabled = YES;

}

- (IBAction)declineButtonPressed:(UIButton *)sender
{
    if(self.activities == nil)
    {
        self.activities = [[NSMutableArray alloc] initWithCapacity:1];
    }
    if(self.currentDeal){
        [self.currentDeal refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            NSLog(@"Updating deal before declining deal");
            [self checkDecline];
        }];
    }
    
    self.acceptButton.enabled = YES;
    self.declineButton.enabled = NO;
}







#pragma mark - View Helper Methods
- (void) setBarInformation
{
    PFQuery *query = [PFQuery queryWithClassName:@"Deal"];
    NSDate *date = [NSDate date];
    NSLog(@"%@",date);
    [query whereKey:@"deal_start_date" lessThanOrEqualTo:date];
    [query whereKey:@"deal_end_date" greaterThanOrEqualTo:date];
    [query whereKey:@"community_name" equalTo:[PFUser currentUser][@"university_name"]];
    [query whereKey:@"deal_qty" greaterThan:@0];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            self.currentDeal = object;
            self.barNameLabel.text = object[@"location_name"];
            self.barAddressLabel.text = object[@"address"];
            self.dealNameLabel.text = object[@"name"];
            self.dealDescriptionLabel.text = [object objectForKey:@"description"];
            [self.activities addObject:object];

            if(userElsewhere){
                [self.currentDeal incrementKey:@"num_elsewhere" byAmount:@1];
                [self.currentDeal saveInBackground];
            }
            else if(userNotGoingOut){
                [self.currentDeal incrementKey:@"num_not_going_out" byAmount:@1];
                [self.currentDeal saveInBackground];
            }
            [self createProgressBar];
        }
        else{
            self.dealNameLabel.text = @"Sorry No Deal Today";
            self.descriptionLabel.text = @"";
            self.dealDescriptionLabel.text = @"";
            self.currentDeal = (PFObject *) [NSNull null];
            self.acceptButton.enabled = NO;
            self.declineButton.enabled = NO;
            self.goingOutLabel.text = @"0";
            NSLog(@"Parse query for bars didnt work, %@", error);
        }
    }];
}

- (void) getRandomDealImage
{
    if(!self.currentDeal){
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
    PFObject *acceptActivity = [PFObject objectWithClassName:@"Activity"];
    [acceptActivity setObject:@"accept" forKey:@"type"];
    [acceptActivity setObject:[PFUser currentUser] forKey:@"user"];
    [acceptActivity setObject:self.currentDeal forKey:@"deal"];
    [acceptActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(self.isDeclinedByCurrentUser) [self.currentDeal incrementKey:@"num_declined" byAmount:@-1];
            self.isAcceptedByCurrentUser = YES;
            self.isDeclinedByCurrentUser = NO;
        [self.activities addObject:acceptActivity];
        if(self.currentDeal[@"deal_qty"] > 0) [self.currentDeal incrementKey:@"deal_qty" byAmount:@-1];
        [self.currentDeal incrementKey:@"num_accepted" byAmount:@1];
        
        [self.currentDeal saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self createProgressBar]; //update progress bar
        }];
    }];

}

- (void) saveDecline
{
    PFObject *declineActivity = [PFObject objectWithClassName:@"Activity"];
    [declineActivity setObject:@"decline" forKey:@"type"];
    [declineActivity setObject:[PFUser currentUser] forKey:@"user"];
    [declineActivity setObject:self.currentDeal forKey:@"deal"];
    [declineActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(self.isAcceptedByCurrentUser){
            [self.currentDeal incrementKey:@"num_accepted" byAmount:@-1];
            [self.currentDeal incrementKey:@"deal_qty" byAmount:@1];
        }
        self.isAcceptedByCurrentUser = NO;
        self.isDeclinedByCurrentUser = YES;
        [self.activities addObject:declineActivity];
        [self.currentDeal incrementKey:@"num_declined" byAmount:@1];
        [self.currentDeal saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self createProgressBar];
        }];
        NSLog(@"bool updated %@", self.activities);
    }];

}

- (void) checkAccept
{
    if(self.isAcceptedByCurrentUser){
        return;
    }
    else if(self.isDeclinedByCurrentUser){
        for(PFObject *activity in self.activities){
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
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
        for(PFObject *activity in self.activities){
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
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
//    [ElsewhereActivity setObject:self.currentDeal forKey:@"deal"];
//    [self.currentDeal incrementKey:@"num_Elsewhere" byAmount:@1];
//    [self.currentDeal saveInBackground];
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



#pragma mark - Hot Deal Button
- (IBAction)hotButtonPressed:(UIButton *)sender {
    if(!self.isHot){
        self.isHot = YES;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hot Deal Notification ON" message:@"You will be notified when this deal becomes popular" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [self.hotButton setBackgroundColor:[UIColor redColor]];
    }
    else if (self.isHot)
    {
        self.isHot = NO;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hot Deal Notification OFF" message:@"You will not be notified when this deal becomes popular" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        [self.hotButton setBackgroundColor:[UIColor clearColor]];
    }
    
}


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
    NSNumber *accepted = [self.currentDeal objectForKey:@"num_accepted"];
    NSNumber *dealsLeft = [self.currentDeal objectForKey:@"deal_qty"];
    float totalDeals = [accepted floatValue] + [dealsLeft floatValue];
    NSLog(@"%f", totalDeals);
    float percent = 0.1;
    float used = [accepted floatValue]/totalDeals;
    NSLog(@"used %f", used);
    if(used < percent)
    {
        self.acceptedLabel.text = [NSString stringWithFormat:@"%d Accepted", 10];
        self.dealsLeftLabel.text = [NSString stringWithFormat:@"%d Deals Left", 100];
        [self.dealsProgressView setProgress:percent animated:YES];
    }
    else
    {
        self.acceptedLabel.text = [NSString stringWithFormat:@"%d Accepted", [accepted integerValue]];
        self.dealsLeftLabel.text = [NSString stringWithFormat:@"%d Deals Left", [dealsLeft integerValue]];
        [self.dealsProgressView setProgress:used animated:YES];
    }
    
    //Update people going out tonight
   // NSNumber *elsewhere = [self.currentDeal objectForKey:@"num_elsewhere"];
    NSNumber *elsewhere = @21;
    int totalGoingOut = [accepted integerValue] + [elsewhere integerValue];
    self.goingOutLabel.text = [NSString stringWithFormat:@"%d", totalGoingOut];
    
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
                    NSURL *url = [NSURL URLWithString:[PFUser currentUser][@"profile"][@"pictureURL"]];
                    NSData *data = [NSData dataWithContentsOfURL:url];
                    UIImage *img = [[UIImage alloc] initWithData:data];
                    UIImageView *iv = [[UIImageView alloc] initWithImage:img];
                    iv.frame = CGRectMake(20,35, 50, 50);
                    iv.layer.cornerRadius = iv.frame.size.height/2;
                    iv.layer.masksToBounds = YES;
                    iv.layer.borderWidth = NO;
                    
                    [self.fbFriendsView addSubview:iv];
                }
            }];
            
        }
    }];


}



@end
