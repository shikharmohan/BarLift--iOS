//
//  SMUniversityTableViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 9/12/14.
//  Copyright (c) 2014 Shikhar Mohan. All rights reserved.
//

#import "SMUniversityTableViewController.h"
#import "SMContainerViewController.h"
@interface SMUniversityTableViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *firstName;
@property (weak, nonatomic) IBOutlet UIView *profileView;
@property (strong, nonatomic) NSMutableArray *helper;


@end

@implementation SMUniversityTableViewController
@synthesize universityTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES];
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        // iOS 6.1 or earlier
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    } else {
        // iOS 7.0 or later
        self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
        self.navigationController.navigationBar.translucent = YES;
    }
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"BarLiftBG6.jpg"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.profileView.backgroundColor = [UIColor colorWithPatternImage:image];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    //make profile pic uiimageview circle shaped
    self.profileImage.layer.cornerRadius = self.profileImage.frame.size.height/2;
    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.layer.borderWidth = NO;
    
    //get fb profile pic
    PFQuery *query = [PFQuery queryWithClassName:kSMPhotoClassKey];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if([objects count] > 0)
        {
            PFObject *photo = objects[0];
            PFFile *pictureFile = photo[@"profile_image"];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                self.profileImage.image = [UIImage imageWithData:data];
            }];
        }
    }];
    
    //set fb name
    self.firstName.text = [PFUser currentUser][@"profile"][@"name"];
    //get list of universities
    [self performSelector:@selector(retrieveFromParse)];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    
}

- (void) retrieveFromParse
{
    PFQuery *query = [PFQuery queryWithClassName:@"Deal"];
    [query selectKeys:@[@"community_name"]];
    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if(!error){
            self.helper = [[NSMutableArray alloc] initWithCapacity:2];
            for(int i = 0; i < [results count]; i++){
                if([self.helper indexOfObject:results[i][@"community_name"]] == NSNotFound){
                    [self.helper addObject:results[i][@"community_name"]];
                }
            }
        }
        else{
            NSLog(@"%@",error);
        }
        [universityTableView reloadData];
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.helper count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"Cell";
    SMUniversityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSLog(@"%@", [self.helper objectAtIndex:indexPath.row]);
    cell.cellTitle.text = [self.helper objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath   *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    PFUser *user = [PFUser currentUser];
    [user setObject:[self.helper objectAtIndex:indexPath.row] forKey:@"university_name"];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setObject:@[@"global",[self.helper objectAtIndex:indexPath.row]] forKey:@"channels"];
    [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
    [currentInstallation saveInBackground];
    [user saveInBackground];
    [self performSegueWithIdentifier:@"universityToDealSegue" sender:self];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"HEPER %@", self.helper);
    if([segue.identifier isEqualToString:@"universityToDealSegue"])
    {
        SMContainerViewController *vc = [segue destinationViewController];
        //send deal info
        [vc performSelector:@selector(setLocationsArray:)
                 withObject:self.helper];
    }
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
