//
//  TableHeaderView.m
//  HealthApp
//
//  Created by David Neubauer on 5/24/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "TableHeaderView.h"

@implementation TableHeaderView
@synthesize label;

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(0, 0, 320, 54)];
        [self setBackgroundColor:[UIColor colorWithRed:(218/255.0) green:(218/255.0) blue:(218/255.0) alpha:0.95]];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 320, 54)];
        [label setText:title];
        [label setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:24]];
        [label setTextColor:[UIColor colorWithRed:(63/255.0) green:(195/255.0) blue:(128/255.0) alpha:1.0]];
        
        [self addSubview:label];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
}
*/

@end
