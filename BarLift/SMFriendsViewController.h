//
//  SMFriendsViewController.h
//  BarLift
//
//  Created by Shikhar Mohan on 9/22/14.
//  Copyright (c) 2014 Shikhar Mohan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMFriendsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *friendTableView;

@end
