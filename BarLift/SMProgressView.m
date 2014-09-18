//
//  SMProgressView.m
//  BarLift
//
//  Created by Shikhar Mohan on 9/18/14.
//  Copyright (c) 2014 Shikhar Mohan. All rights reserved.
//

#import "SMProgressView.h"
@interface SMProgressView () {
    CGFloat startAngle;
    CGFloat endAngle;
}

@end
@implementation SMProgressView
@synthesize percent;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        
        // Determine our start and stop angles for the arc (in radians)
        startAngle = M_PI * 1.5;
        endAngle = startAngle + (M_PI * 2);
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Display our percentage as a string
    NSString* textContent = [NSString stringWithFormat:@"%d%%", self.percent];
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    
    // Create our arc, with the correct angles
    [bezierPath addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
                          radius:60
                      startAngle:startAngle
                        endAngle:(endAngle - startAngle) * (self.percent / 100.0) + startAngle
                       clockwise:YES];
    
    // Set the display for the path, and stroke it
    bezierPath.lineWidth = 5;
    [[UIColor redColor] setStroke];
    [bezierPath stroke];
    
    // Text Drawing
    CGRect textRect = CGRectMake((rect.size.width / 2.0) - 71/2.0, (rect.size.height / 2.0) - 45/2.0, 71, 45);
    [[UIColor blackColor] setFill];
    [textContent drawInRect: textRect withFont: [UIFont fontWithName: @"Helvetica-Bold" size: 30] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
}
@end
