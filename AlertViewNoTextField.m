//
//  AlertViewNoTextField.m
//  HealthApp
//
//  Created by David Neubauer on 5/26/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "AlertViewNoTextField.h"

@interface AlertViewNoTextField ()
{
    UIColor *eggWhite;
    UIColor *darkerGray;
    UIColor *lighterGray;
    UIColor *mint;
    
    NSString *title;
    NSString *placeHolder;
    NSString *buttonTitle;
}
@end

@implementation AlertViewNoTextField
@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        eggWhite = [UIColor colorWithRed:(218/255.0) green:(218/255.0) blue:(218/255.0) alpha:1.0];
        darkerGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:1.0];
        lighterGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.5];
        mint = [UIColor colorWithRed:(63/255.0) green:(195/255.0) blue:(128/255.0) alpha:1.0];
        
        CGRect frame = [[UIScreen mainScreen] bounds];
        [self setFrame:frame];
        [self setBackgroundColor:[UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.5]];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Blur and Dim background
    
    // Main
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake((320-248)/2.0, 100, 248, 128)];
    [mainView setBackgroundColor:eggWhite];
    [self addSubview:mainView];
    
    // Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 248, 64)];
    [titleLabel setTextColor:darkerGray];
    [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setText:title];
    [mainView addSubview:titleLabel];
    
    // Cancel Button
    UIView *cancelBackground = [[UIView alloc] initWithFrame:CGRectMake(24, 64, 200, 40)];
    [cancelBackground setBackgroundColor:mint];
    [mainView addSubview:cancelBackground];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:cancelBackground.frame];
    [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"Okay" forState:UIControlStateNormal];
    [cancelButton setTitleColor:eggWhite forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0]];
    [cancelButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [cancelButton setTag:0];
    [mainView addSubview:cancelButton];
}

- (void)cancel:(id)sender
{
    [delegate userTappedOkay:self];
}

- (void)setTitle:(NSString *)text
{
    title = text;
}

@end
