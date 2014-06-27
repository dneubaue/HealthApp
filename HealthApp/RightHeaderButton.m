//
//  HeaderButton.m
//  HealthApp
//
//  Created by David Neubauer on 5/24/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "RightHeaderButton.h"

@implementation RightHeaderButton
@synthesize label;

- (id)init
{
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(240, 20, 80, 44)];
        
        self.label = [[UILabel alloc] init];
        [self.label setTextColor:[UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:1.0]];
        [self.label setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0]];
        [self.label setTextAlignment:NSTextAlignmentRight];
        [self.label setFrame:CGRectMake(0, 0, 63, 44)];
        [self addSubview:self.label];
    }
    return self;
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    label.text = title;
}

@end
