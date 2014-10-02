//
//  SMSettingsViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 9/18/14.
//  Copyright (c) 2014 Shikhar Mohan. All rights reserved.
//

#import "SMSettingsViewController.h"
#import "Reachability.h"

@interface SMSettingsViewController ()
@property (strong, nonatomic) Reachability *internetReachableFoo;


@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UIButton *poppinButton;
@property (strong, nonatomic) IBOutlet UIPickerView *locationPicker;


//data
@property (strong, nonatomic) NSArray *days;
@property (strong, nonatomic) NSMutableArray *push;
@property (strong, nonatomic) NSString *todaysDate;

@end

@implementation SMSettingsViewController
@synthesize deal;
@synthesize locationSettingsArray;

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
    [self testInternetConnection];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.days = @[@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday"];
    self.push = [[NSMutableArray alloc] initWithObjects:[PFUser currentUser][@"Monday"],[PFUser currentUser][@"Tuesday"],[PFUser currentUser][@"Wednesday"],[PFUser currentUser][@"Thursday"],[PFUser currentUser][@"Friday"],[PFUser currentUser][@"Saturday"],[PFUser currentUser][@"Sunday"],nil];
    [self getDate];
    //keyboard listeners
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    if((deal != nil) && [[PFUser currentUser][@"barlift_rep"] isEqualToValue:@YES])
    {
        self.poppinButton.hidden = NO;
    }
    else
    {
        self.poppinButton.hidden = YES;
    }
    // Do any additional setup after loading the view.
    if(!locationSettingsArray)
    {
        [self retrieveFromParse];
    
    }
    
    
    if([PFUser currentUser]){
        NSLog(@"Locations array %@", locationSettingsArray);
        NSInteger index = [locationSettingsArray indexOfObject:[PFUser currentUser][@"university_name"]];
        if(index != NSNotFound) [self.locationPicker selectRow:index inComponent:0 animated:YES];
        
        self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
    
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

#pragma mark - Push Settings
    
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.days count];

}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingsCell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"settingsCell"];
    }
    cell.textLabel.text = self.days[indexPath.row];
    if([self.push[indexPath.row]  isEqual: @YES])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath   *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
    UITableViewCell *theCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (theCell.accessoryType == UITableViewCellAccessoryNone) {
        theCell.accessoryType = UITableViewCellAccessoryCheckmark;
        [PFUser currentUser][self.days[indexPath.row]] = @YES;
        [PFPush subscribeToChannelInBackground:self.days[indexPath.row]];
    }
    
    else if (theCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        theCell.accessoryType = UITableViewCellAccessoryNone;
        [PFUser currentUser][self.days[indexPath.row]] = @NO;
        [PFPush unsubscribeFromChannelInBackground:self.days[indexPath.row]];
    }

}

#pragma mark - BarLift Reps
- (void)keyboardWasShown:(NSNotification *)notification
{
    
    // Step 1: Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    
    // Step 2: Adjust the bottom content inset of your scroll view by the keyboard height.
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    
    // Step 3: Scroll the target text field into view.
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardSize.height;
    if (!CGRectContainsPoint(aRect, self.textField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self.textField.frame.origin.y - (keyboardSize.height-15));
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}
- (void) keyboardWillHide:(NSNotification *)notification {
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.textField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.textField = nil;
}

- (IBAction)dismissKeyboard:(UITextField *)sender
{
    [self checkBarliftRep];
    [self resignFirstResponder];

}

- (IBAction)submitButtonPressed:(UIButton *)sender
{
    [self checkBarliftRep];
    [self resignFirstResponder];
}

- (void) checkBarliftRep
{
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        if(!error)
        {
            NSString *key = config[@"barlift_rep_key"];
            if([key isEqualToString:self.textField.text])
            {
                [PFUser currentUser][@"barlift_rep"] = @YES;
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Welcome BarLift Rep!" message:@"You now get access to the It's Poppin' button!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
                [[PFUser currentUser] saveInBackground];
                self.poppinButton.hidden = NO;
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Incorrect Rep Code" message:@"Please try again or contact BarLift." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];

            }
        
        }
    }];

}
- (IBAction)loginButtonPressed:(UIButton *)sender {
        if ([PFUser currentUser]) {
            [[PFFacebookUtils session] closeAndClearTokenInformation];
            [PFUser logOut];
        } else {
            NSLog(@"currentUser: %@", [PFUser currentUser]);
        }

    [self.navigationController popToRootViewControllerAnimated:YES];

}



- (IBAction)poppinButtonPressed:(UIButton *)sender {
    if([PFUser currentUser][@"university_name"] && deal){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE"];
        NSString *dayName = [dateFormatter stringFromDate:[NSDate date]];
        
        PFPush *push = [[PFPush alloc] init];
        PFQuery *query = [PFInstallation query];
        [query whereKey:@"channels" containedIn:@[[PFUser currentUser][@"university_name"]]];
        [query whereKey:@"channels" containedIn:@[dayName]];
        [query whereKey:@"channels" notContainedIn:@[@"Mute"]];
        
        NSString *barName = deal[@"location_name"];
        NSString *dealName = deal[@"name"];
        NSString *message = [NSString stringWithFormat:@"It's Poppin! Come on down to %@! %@", barName, dealName];
        [push setMessage:message];
        [push sendPushInBackground];
        
        
    }
    else
    {
        self.poppinButton.hidden = YES;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Deal Currently" message:@"Check back later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    [self.poppinButton setBackgroundColor:[UIColor grayColor]];
}


- (void) getDate
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'"]; // Set date and time styles
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    self.todaysDate = [dateFormatter stringFromDate:date];
    
}


#pragma mark - Location Settings


- (void) retrieveFromParse
{
    PFQuery *query = [PFQuery queryWithClassName:@"Deal"];
    [query selectKeys:@[@"community_name"]];
    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if(!error){
            locationSettingsArray = [[NSMutableArray alloc] initWithCapacity:2];
            for(int i = 0; i < [results count]; i++){
                if([locationSettingsArray indexOfObject:results[i][@"community_name"]] == NSNotFound){
                    [locationSettingsArray addObject:results[i][@"community_name"]];
                }
            }
        }
        else{
            NSLog(@"%@",error);
        }
        [self.locationPicker reloadAllComponents];
    }];
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{

    return [locationSettingsArray count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component
{
    return [locationSettingsArray objectAtIndex:row];
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component
{
    NSLog(@"Selected Row %d", row);
    [PFUser currentUser][@"university_name"] = locationSettingsArray[row];
    [[PFUser currentUser] saveInBackground];

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
