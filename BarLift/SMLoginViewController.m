//
//  SMLoginViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 9/12/14.
//  Copyright (c) 2014 Shikhar Mohan. All rights reserved.
//

#import "SMLoginViewController.h"

@interface SMLoginViewController ()
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


@end

@implementation SMLoginViewController

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
    self.activityIndicator.hidden = YES;
    // Do any additional setup after loading the view.
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
- (IBAction)loginButtonPressed:(UIButton *)sender
{
    
    
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    NSArray *permissionsArray = @[@"public_profile", @"email", @"user_friends", @"user_location", @"user_birthday"];
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        if(!user)
        {
            if(!error)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"Facebook Login Was Cancelled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Error" message:[error description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
        else
        {
            [self updateUserInformation];
            PFUser* user = [PFUser currentUser];
            
            if(!user[@"university_name"]){
                [self performSegueWithIdentifier:@"loginToUnivSegue" sender:self];
            }
            else{
            [self performSegueWithIdentifier:@"loginToDealViewSegue" sender:self];
            }
        }
        
    }];
}


#pragma mark - Helper Methods
-(void) updateUserInformation
{
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if(!error){
            NSDictionary *userDictionary = (NSDictionary *)result;
            NSMutableDictionary *userProfile = [[NSMutableDictionary alloc] initWithCapacity:8];
            if(userDictionary[@"name"]){
                userProfile[@"name"] = userDictionary[@"name"];
            }
            if(userDictionary[@"email"]){
                PFUser *user = [PFUser currentUser];
                user[@"email"] = userDictionary[@"email"];
                
            }
            if(userDictionary[@"first_name"]){
                userProfile[@"first_name"] = userDictionary[@"first_name"];
            }
            if(userDictionary[@"location"][@"name"]){
                userProfile[@"location"] = userDictionary[@"location"][@"name"];
            }
            if(userDictionary[@"gender"]){
                userProfile[@"gender"] = userDictionary[@"gender"];
            }
            if(userDictionary[@"birthday"]){
                userProfile[@"birthday"] = userDictionary[@"birthday"];
            }
            if(userDictionary[@"id"]){
                userProfile[@"fb_id"] = userDictionary[@"id"];
            }
            [[PFUser currentUser] setObject:userProfile forKey:@"profile"];
            [[PFUser currentUser] saveInBackground];
        }
        else{
            NSLog(@"Error in Facebook Request %@", error);
        }
    }];
}


@end
