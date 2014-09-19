//
//  SMUniversityTableViewController.h
//  BarLift
//
//  Created by Shikhar Mohan on 9/12/14.
//  Copyright (c) 2014 Shikhar Mohan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMUniversityTableViewCell.h"

@interface SMUniversityTableViewController : UIViewController <UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *universityTableView;

@end
