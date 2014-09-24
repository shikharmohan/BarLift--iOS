//
//  SMFriendsViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 9/22/14.
//  Copyright (c) 2014 Shikhar Mohan. All rights reserved.
//

#import "SMFriendsViewController.h"
#import "HMSegmentedControl.h"

@interface SMFriendsViewController ()
@property (strong, nonatomic) HMSegmentedControl *segmentedControl4;
@end

@implementation SMFriendsViewController

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
    self.segmentedControl4.selectedSegmentIndex = 1;
    self.segmentedControl4.backgroundColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1];
    self.segmentedControl4.textColor = [UIColor whiteColor];
    self.segmentedControl4.selectedTextColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
    self.segmentedControl4.selectionIndicatorColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
    self.segmentedControl4.selectionStyle = HMSegmentedControlSelectionStyleBox;
    self.segmentedControl4.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationUp;
    self.segmentedControl4.tag = 2;
    
    
    [self.view addSubview:self.segmentedControl4];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 210)];
    [self setApperanceForLabel:label1];
    label1.text = @"Worldwide";
    [self.segmentedControl4 addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(320, 0, 320, 210)];
    [self setApperanceForLabel:label2];
    label2.text = @"Local";
    [self.segmentedControl4 addSubview:label2];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setApperanceForLabel:(UILabel *)label {
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    label.backgroundColor = color;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:21.0f];
    label.textAlignment = NSTextAlignmentCenter;
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld (via UIControlEventValueChanged)", (long)segmentedControl.selectedSegmentIndex);
}

- (void)uisegmentedControlChangedValue:(UISegmentedControl *)segmentedControl {
    NSLog(@"Selected index %ld", (long)segmentedControl.selectedSegmentIndex);
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
