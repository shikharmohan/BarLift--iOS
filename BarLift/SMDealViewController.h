//
//  SMDealViewController.h
//  BarLift
//
//  Created by Shikhar Mohan on 9/12/14.
//  Copyright (c) 2014 Shikhar Mohan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMDealViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIButton *declineButton;
@property (nonatomic) BOOL justDeclined;
@property (nonatomic) BOOL userElsewhere;
@property (nonatomic) BOOL userNotGoingOut;
@property (strong, nonatomic) NSMutableArray *locationsArray;

@end
