//
//  SMLoginViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 9/12/14.
//  Copyright (c) 2014 Shikhar Mohan. All rights reserved.
//

#import "SMLoginViewController.h"
#import "Reachability.h"
@interface SMLoginViewController ()
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSMutableData *imageData;
@property (weak, nonatomic) IBOutlet UINavigationItem *loginNavigationItem;
@property (strong, nonatomic) Reachability *internetReachableFoo;

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
    //add background image
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"BarLiftBG4.jpg"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];

    self.activityIndicator.hidden = YES;
    [self testInternetConnection];
    // Do any additional setup after loading the view.
}

- (void) viewDidAppear:(BOOL)animated
{
    NSLog(@"LoginView did appear called %@", [PFUser currentUser]);
    if([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
    {
        [self updateUserInformation];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear: (BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewDidDisappear:animated];
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
    NSArray *permissionsArray = @[@"public_profile", @"email", @"user_friends"];
    
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
            //create URL
            NSString *facebookID = userDictionary[@"id"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal&return_ssl_resources=1", facebookID]];
            
            
            
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
            if([pictureURL absoluteString]){
                userProfile[@"pictureURL"] = [pictureURL absoluteString];
            }
            if([[PFUser currentUser] isNew]){
                [[PFUser currentUser] setObject:@YES forKey:@"Monday"];
                [[PFUser currentUser] setObject:@YES forKey:@"Tuesday"];
                [[PFUser currentUser] setObject:@YES forKey:@"Wednesday"];
                [[PFUser currentUser] setObject:@YES forKey:@"Thursday"];
                [[PFUser currentUser] setObject:@YES forKey:@"Friday"];
                [[PFUser currentUser] setObject:@YES forKey:@"Saturday"];
                [[PFUser currentUser] setObject:@YES forKey:@"Sunday"];
                [[PFUser currentUser] setObject:@NO forKey:@"barlift_rep"];
            }
            [[PFUser currentUser] setObject:userProfile[@"fb_id"] forKey:@"fb_id"];

            [[PFUser currentUser] setObject:userProfile forKey:@"profile"];
            PFACL *acl = [PFACL ACLWithUser:[PFUser currentUser]];
            [acl setPublicReadAccess:YES];
            [[PFUser currentUser] setObject:acl forKey:@"ACL"];
            
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(succeeded){
                    NSLog(@"User saved successfully");
                }
                else{
                    NSLog(@"User not saved%@", error);
                }
            }];
            
            [self requestImage];
        }
        else{
            NSLog(@"Error in Facebook Request %@", error);
        }
    }];
}

-(void)uploadPFFileToParse:(UIImage *)image
{
    NSLog(@"upload called");
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    if(!imageData){
        NSLog(@"Image Data not found");
        return;
    }
    PFFile *photoFile = [PFFile fileWithData:imageData];
    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            PFObject *photo = [PFObject objectWithClassName:kSMPhotoClassKey];
            [photo setObject:[PFUser currentUser] forKey:kSMPhotoUserKey];
            [photo setObject:photoFile forKey:kSMPhotoPictureKey];
            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(succeeded){
                    NSLog(@"Profile picture was saved successfully");
                }
                else{
                    NSLog(@"Picture not saved: %@", error);
                }
            }];
        }
    }];
    
}

- (void) requestImage
{
    PFQuery *query = [PFQuery queryWithClassName:kSMPhotoClassKey];
    [query whereKey:kSMPhotoUserKey equalTo:[PFUser currentUser]];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if(number  == 0)
        {
            PFUser *user =[PFUser currentUser];
            self.imageData = [[NSMutableData alloc] init];
            NSURL *profilePictureURL = [NSURL URLWithString:user[@"profile"][@"pictureURL"]];
            NSURLRequest *urlRequest= [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
            NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            if(!urlConnection){
                NSLog(@"failed to download picture");
            }
        }
    }];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.imageData appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    UIImage *profileImage = [UIImage imageWithData:self.imageData];
    [self uploadPFFileToParse:profileImage];
    
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


@end
