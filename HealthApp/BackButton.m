//
//  BackButton.m
//  HealthApp
//
//  Created by David Neubauer on 5/25/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "BackButton.h"

@interface BackButton ()
{
    UILabel *titleLabel;
}
@end

@implementation BackButton

- (id)init
{
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(17, 20, 63, 44)];
        UIImage *navImage = [UIImage imageNamed:@"arrow_backward"];
        [self setImage:navImage forState:UIControlStateNormal];
        [self setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        
        titleLabel = [[UILabel alloc] init];
        [titleLabel setFrame:CGRectMake(17, 0, 63, 44)];
        [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0]];
        [titleLabel setTextColor:[UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:1.0]];
        [titleLabel setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:titleLabel];
    }
    return self;
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    titleLabel.text = title;
}

@end
