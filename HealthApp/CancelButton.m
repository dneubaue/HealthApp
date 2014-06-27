//
//  cancelButton.m
//  HealthApp
//
//  Created by David Neubauer on 5/25/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "CancelButton.h"

@interface CancelButton ()
{
    UIButton *button;
}
@end

@implementation CancelButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setFrame:CGRectMake(0, 20, 80, 44)];
        
        // Image
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"X"]];
        [imageView setFrame:CGRectMake(17, 0, 63, 44)];
        [imageView setContentMode:UIViewContentModeLeft];
        [self addSubview:imageView];
        
        // Button
        button = [[UIButton alloc] init];
        [button setFrame:CGRectMake(0, 0, 80, 44)];
        [self addSubview:button];
    }
    return self;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [button addTarget:target action:action forControlEvents:controlEvents];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
