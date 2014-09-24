//
//  SMElsewhereViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 9/24/14.
//  Copyright (c) 2014 Shikhar Mohan. All rights reserved.
//

#import "SMElsewhereViewController.h"
#import "SMContainerViewController.h"
#import "SMDealViewController.h"
#import "SMFriendsViewController.h"

@interface SMElsewhereViewController ()
@end

@implementation SMElsewhereViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom the table
        
        // The className to query on
        self.parseClassName = @"Activity";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

#pragma mark - Parse


// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.



// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell
    PFObject *obj = [object objectForKey:@"user"];
    PFObject *profile = [obj objectForKey:@"profile"];
    cell.textLabel.text = [profile objectForKey:@"first_name"];
    
    return cell;
}


@end
