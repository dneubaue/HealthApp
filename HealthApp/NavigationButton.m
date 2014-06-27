//
//  NavigationButton.m
//  HealthApp
//
//  Created by David Neubauer on 5/24/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "NavigationButton.h"

#define SLIDE_TIMING .25
#define CLOSED 0
#define OPEN 1

@interface NavigationButton ()
{
    UIImageView *imageView;
    UIButton *button;
}

@end

@implementation NavigationButton

- (id)init
{
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(0, 20, 80, 44)];
        
        // Image
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navButton"]];
        [imageView setFrame:CGRectMake(17, 0, imageView.image.size.width, 44)];
        [imageView setContentMode:UIViewContentModeLeft];
        [imageView setTag:CLOSED];
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

#pragma mark -
#pragma mark Rotation of Button

- (void)toggleRotation
{
    if (imageView.tag == 1) {
        [self rotateToNormal];
    }
    else {
        [self rotateToSide];
    }
}

- (void)rotateToSide
{   
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [imageView setTransform:CGAffineTransformMakeRotation(M_PI_2)];
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             imageView.tag = OPEN;
                         }
                     }];
}

- (void)rotateToNormal
{
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [imageView setTransform:CGAffineTransformMakeRotation(0)];
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             imageView.tag = CLOSED;
                         }
                     }];
}

- (void)moveToOpen
{
    [imageView setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    imageView.tag = OPEN;
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
