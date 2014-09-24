//
//  SMFriendsViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 9/22/14.
//  Copyright (c) 2014 Shikhar Mohan. All rights reserved.
//

#import "SMFriendsViewController.h"
#import "HMSegmentedControl.h"
#import "SMElsewhereViewController.h"
#import "SMFriendsTableViewController.h"
#import "SMDealViewController.h"

@interface SMFriendsViewController ()
@property (strong, nonatomic) HMSegmentedControl *segmentedControl4;
@property (strong, nonatomic) NSMutableArray *helper;
@property (strong, nonatomic) PFObject *dealNow;

@end

@implementation SMFriendsViewController
@synthesize friendTableView;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGFloat yDelta;
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
        yDelta = 20.0f;
    } else {
        yDelta = 0.0f;
    }
    
    self.segmentedControl4 = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 64, 320, 50)];
    self.segmentedControl4.sectionTitles = @[@"BarLift", @"Going Elsewhere"];
    self.segmentedControl4.selectedSegmentIndex = 0;
    self.segmentedControl4.backgroundColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    self.segmentedControl4.textColor = [UIColor whiteColor];
    self.segmentedControl4.selectedTextColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
    self.segmentedControl4.selectionIndicatorColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
    self.segmentedControl4.selectionStyle = HMSegmentedControlSelectionStyleBox;
    self.segmentedControl4.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationUp;
    self.segmentedControl4.tag = 2;
    [self.segmentedControl4 addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.segmentedControl4];

    PFQuery *dealQuery = [PFQuery queryWithClassName:@"Deal"];
    NSDate *date = [NSDate date];
    [dealQuery whereKey:@"deal_start_date" lessThanOrEqualTo:date];
    [dealQuery whereKey:@"deal_end_date" greaterThanOrEqualTo:date];
    [dealQuery whereKey:@"community_name" equalTo:[PFUser currentUser][@"university_name"]];
    [dealQuery setCachePolicy:kPFCachePolicyCacheThenNetwork];
    [dealQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error) self.dealNow = object;
        [self retrieveAcceptFromParse];
    }];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    if(segmentedControl.selectedSegmentIndex == 0){
        //query for Users going
        [self retrieveAcceptFromParse];
    }
    else if (segmentedControl.selectedSegmentIndex == 1){
        //query for users not going
        [self retrieveDeclineFromParse];
        
    }
    
    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
}






- (void)uisegmentedControlChangedValue:(UISegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld", (long)segmentedControl.selectedSegmentIndex);
}

- (void) retrieveAcceptFromParse
{
    [self.dealNow refresh];
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    
    if(self.dealNow){
        [query whereKey:@"type" equalTo:@"decline"];
        [query whereKey:@"deal" equalTo:self.dealNow];
        [query selectKeys:@[@"user"]];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if(!error){
            self.helper = [[NSMutableArray alloc] initWithCapacity:2];
            for(int i = 0; i < [results count]; i++){
                if([self.helper indexOfObject:results[i][@"user"]] == NSNotFound){
                    [self.helper addObject:results[i][@"user"]];
                }
            }
        }
        else{
            NSLog(@"%@",error);
        }
        [friendTableView reloadData];
    }];
}

- (void) retrieveDeclineFromParse
{
    [self.dealNow refresh];
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    
    if(self.dealNow){
        [query whereKey:@"type" equalTo:@"decline"];
        [query whereKey:@"deal" equalTo:self.dealNow];
        [query selectKeys:@[@"user"]];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if(!error){
            self.helper = [[NSMutableArray alloc] initWithCapacity:2];
            for(int i = 0; i < [results count]; i++){
                if([self.helper indexOfObject:results[i][@"user"]] == NSNotFound){
                    [self.helper addObject:results[i][@"user"]];
                }
            }
        }
        else{
            NSLog(@"%@",error);
        }
        [friendTableView reloadData];
    }];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSLog(@"%@", [self.helper objectAtIndex:indexPath.row]);
    
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
