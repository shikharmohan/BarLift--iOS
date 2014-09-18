//
//  SMSettingsViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 9/18/14.
//  Copyright (c) 2014 Shikhar Mohan. All rights reserved.
//

#import "SMSettingsViewController.h"

@interface SMSettingsViewController ()
@property (strong, nonatomic) NSArray *days;
@property (strong, nonatomic) NSMutableArray *push;
@end

@implementation SMSettingsViewController

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
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.days = @[@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday"];
    self.push = [[NSMutableArray alloc] initWithObjects:[PFUser currentUser][@"Monday"],[PFUser currentUser][@"Tuesday"],[PFUser currentUser][@"Wednesday"],[PFUser currentUser][@"Thursday"],[PFUser currentUser][@"Friday"],[PFUser currentUser][@"Saturday"],[PFUser currentUser][@"Sunday"],nil];
    NSLog(@"%@", self.push);
    // Do any additional setup after loading the view.
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
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - Table View Functions
    
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
    NSLog(@"%@",self.push[indexPath.row]);
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    UITableViewCell *theCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (theCell.accessoryType == UITableViewCellAccessoryNone) {
        theCell.accessoryType = UITableViewCellAccessoryCheckmark;
        [PFUser currentUser][self.days[indexPath.row]] = @YES;
    }
    
    else if (theCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        theCell.accessoryType = UITableViewCellAccessoryNone;
        [PFUser currentUser][self.days[indexPath.row]] = @NO;
    }

}

@end
