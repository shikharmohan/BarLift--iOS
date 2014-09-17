//
//  SMDealViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 9/12/14.
//  Copyright (c) 2014 Shikhar Mohan. All rights reserved.
//

#import "SMDealViewController.h"
#import "SMBarInfoTranslucentView.h"
@interface SMDealViewController ()
@property (strong, nonatomic) IBOutlet SMBarInfoTranslucentView *barInfoView;
@property (weak, nonatomic) IBOutlet UIView *dealInfoView;
@property (weak, nonatomic) IBOutlet UIView *friendInfoView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *barAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *barNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *barLogoImageView;

@property (weak, nonatomic) IBOutlet UIImageView *dealImageView;
@property (weak, nonatomic) IBOutlet UILabel *dealNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dealDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (strong,nonatomic) NSMutableArray *activities;
@property (strong, nonatomic) PFObject *currentDeal;

@property (nonatomic) BOOL isAcceptedByCurrentUser;
@property (nonatomic) BOOL isHotByCurrentUser;
@property (nonatomic) BOOL isDeclinedByCurrentUser;

//toolbar

@end

@implementation SMDealViewController

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
    [self setBarInformation];

    
  
    
    // Do any additional setup after loading the view.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(setBarInformation) name: @"UpdateUINotification" object: nil];
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
        self.navigationController.navigationBar.tintColor = [UIColor redColor];
    } else {
        // iOS 7.0 or later
        self.navigationController.navigationBar.barTintColor = [UIColor redColor];
        self.navigationController.navigationBar.translucent = YES;
    }
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    
    //bar info view set up
    self.barLogoImageView.layer.cornerRadius = self.barLogoImageView.frame.size.height/2;
    self.barLogoImageView.layer.masksToBounds = YES;
    self.barLogoImageView.layer.borderWidth = NO;
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
- (void) setBarInformation
{
    PFQuery *query = [PFQuery queryWithClassName:@"Deal"];
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'"]; // Set date and time styles
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *dateString = [dateFormatter stringFromDate:date];
    [query whereKey:@"deal_date" equalTo:dateString];
    [query whereKey:@"community_name" equalTo:[PFUser currentUser][@"university_name"]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            self.currentDeal = object;
            NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: object[@"image_url"]]];
            UIImageView *imView = [[UIImageView alloc] initWithImage:[UIImage imageWithData: imageData]];
            NSLog(@"%@", [object objectForKey:@"name"]);
            self.barLogoImageView.image = imView.image;
            self.barNameLabel.text = object[@"location_name"];
            self.barAddressLabel.text = object[@"address"];
            self.dealNameLabel.text = object[@"name"];
            self.dealDescriptionLabel.text = [object objectForKey:@"description"];
            [self getRandomDealImage];
            
            //Calculate the expected size based on the font and linebreak mode of your label
            // FLT_MAX here simply means no constraint in height
        }
        else{
            self.dealNameLabel.text = @"Sorry No Deal Today";
            self.descriptionLabel.text = @"";
            self.dealDescriptionLabel.text = @"";
            self.currentDeal = NULL;
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

- (void) saveAccept
{
    PFObject *acceptActivity = [PFObject objectWithClassName:@"Activity"];
    [acceptActivity setObject:@"accept" forKey:@"type"];
    [acceptActivity setObject:[PFUser currentUser] forKey:@"user"];
    [acceptActivity setObject:self.currentDeal forKey:@"deal"];
    [self.currentDeal incrementKey:@"deal_qty" byAmount:@-1];
    [self.currentDeal incrementKey:@"num_accepted" byAmount:@1];
    [self.currentDeal saveInBackground];
    [acceptActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            self.isAcceptedByCurrentUser = YES;
            self.isDeclinedByCurrentUser = NO;
            self.isHotByCurrentUser = NO;
            [self.activities addObject:acceptActivity];
        }
        else{
         NSLog(@"Could not save accept activity %@", error);
        }
    }];
}

- (void) saveDecline
{
    PFObject *declineActivity = [PFObject objectWithClassName:@"Activity"];
    [declineActivity setObject:@"decline" forKey:@"type"];
    [declineActivity setObject:[PFUser currentUser] forKey:@"user"];
    [declineActivity setObject:self.currentDeal forKey:@"deal"];
    [self.currentDeal incrementKey:@"num_declined" byAmount:@1];
    [self.currentDeal saveInBackground];
    [declineActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            self.isAcceptedByCurrentUser = NO;
            self.isDeclinedByCurrentUser = YES;
            self.isHotByCurrentUser = NO;
            [self.activities addObject:declineActivity];
        }
        else{
            NSLog(@"Could not save decline activity %@", error);
        }

    }];
}

- (void) saveHot
{
    PFObject *hotActivity = [PFObject objectWithClassName:@"Activity"];
    [hotActivity setObject:@"hot" forKey:@"type"];
    [hotActivity setObject:[PFUser currentUser] forKey:@"user"];
    [hotActivity setObject:self.currentDeal forKey:@"deal"];
    [self.currentDeal incrementKey:@"num_hot" byAmount:@1];
    [self.currentDeal saveInBackground];
    [hotActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            self.isAcceptedByCurrentUser = NO;
            self.isDeclinedByCurrentUser = NO;
            self.isHotByCurrentUser = YES;
            [self.activities addObject:hotActivity];
        }
        else{
            NSLog(@"Could not save decline activity %@", error);
        }
        
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
    else if(self.isHotByCurrentUser){
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
    else if(self.isHotByCurrentUser){
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
- (void) checkHot
{
    if(self.isHotByCurrentUser){
        return;
    }
    else if(self.isAcceptedByCurrentUser){
        for(PFObject *activity in self.activities){
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveHot];
    }
    else if(self.isDeclinedByCurrentUser){
        for(PFObject *activity in self.activities){
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveHot];
    }
    else
    {
        [self saveHot];
    }
}

@end
