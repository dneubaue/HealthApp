//
//  AlertView.m
//  HealthApp
//
//  Created by David Neubauer on 5/25/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "AlertView.h"

@interface AlertView ()
{
    UIColor *eggWhite;
    UIColor *darkerGray;
    UIColor *lighterGray;
    UIColor *mint;
    
    NSString *title;
    NSString *placeHolder;
    NSString *buttonTitle;
    
    UIKeyboardType keyboardType;
}
@end

@implementation AlertView
@synthesize textField, delegate;

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
        
        keyboardType = UIKeyboardTypeDefault;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Blur and Dim background
    
    // Main
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake((320-248)/2.0, 100, 248, 166)];
    [mainView setBackgroundColor:eggWhite];
    [self addSubview:mainView];
    
    // Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 248, 64)];
    [titleLabel setTextColor:darkerGray];
    [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setText:title];
    [mainView addSubview:titleLabel];
    
    // Textfield
    UIView *textFieldBackground = [[UIView alloc] initWithFrame:CGRectMake(24, 64, 200, 32)];
    [textFieldBackground setBackgroundColor:[UIColor whiteColor]];
    [mainView addSubview:textFieldBackground];
    
    textField = [[UITextField alloc] initWithFrame:CGRectMake(28, 66, 192, 28)];
    [textField becomeFirstResponder];
    [textField setTextColor:darkerGray];
    [textField setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0]];
    [textField setTextAlignment:NSTextAlignmentLeft];
    [textField setPlaceholder:placeHolder];
    [textField setKeyboardType:keyboardType];
    [textField setTintColor:mint]; // Cursor Color
    [mainView addSubview:textField];
    
    // Cancel Button
    UIView *cancelBackground = [[UIView alloc] initWithFrame:CGRectMake(24, 112, 96, 40)];
    [cancelBackground setBackgroundColor:lighterGray];
    [mainView addSubview:cancelBackground];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:cancelBackground.frame];
    [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:eggWhite forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0]];
    [cancelButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [cancelButton setTag:0];
    [mainView addSubview:cancelButton];
    
    // Add Button
    UIView *addBackground = [[UIView alloc] initWithFrame:CGRectMake(128, 112, 96, 40)];
    [addBackground setBackgroundColor:mint];
    [mainView addSubview:addBackground];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:addBackground.frame];
    [addButton addTarget:self action:@selector(other:) forControlEvents:UIControlEventTouchUpInside];
    [addButton setTitle:buttonTitle forState:UIControlStateNormal];
    [addButton setTitleColor:eggWhite forState:UIControlStateNormal];
    [addButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0]];
    [addButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [addButton setTag:1];
    [mainView addSubview:addButton];
}

- (void)cancel:(id)sender
{
    [textField resignFirstResponder];
    [delegate userTappedCancel:self];
}

- (void)other:(id)sender
{
    [textField resignFirstResponder];
    [delegate userTappedOther:self];
}

- (void)setTitle:(NSString *)text
{
    title = text;
}

- (void)setPlaceholder:(NSString *)text
{
    placeHolder = text;
}

- (void)setOtherButtonTitle:(NSString *)text
{
    buttonTitle = text;
}

- (void)setKeyboardType:(UIKeyboardType)type
{
    keyboardType = type;
}

@end
