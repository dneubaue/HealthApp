//
//  SwipeableCell.m
//  HealthApp
//
//  Created by David Neubauer on 5/6/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "SwipeableCell.h"

#define X_CELL_NORMAL 0
#define BUTTON_WIDTH 44
#define X_CELL_SWIPED -2 * BUTTON_WIDTH
#define CELL_HEIGHT 44

#define TITLE_TAG 2

@interface SwipeableCell ()
{
    UIView *topView;
    UIView *bottomView;
    
    UIColor *eggWhite;
    UIColor *darkerGray;
    UIColor *lighterGray;
    UIColor *mint;
    
    CGRect cellFrame;
}
@end

@implementation SwipeableCell
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        cellFrame = CGRectMake(0, 0, 320, CELL_HEIGHT);
        
        eggWhite = [UIColor colorWithRed:(218/255.0) green:(218/255.0) blue:(218/255.0) alpha:1.0];
        darkerGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:1.0];
        lighterGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.7];
        mint = [UIColor colorWithRed:(63/255.0) green:(195/255.0) blue:(128/255.0) alpha:1.0];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self setBackgroundColor:eggWhite];
        [self.textLabel setTextColor:darkerGray];
        [self.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:22.0]];
        
        [self.detailTextLabel setTextColor:darkerGray];
        [self.detailTextLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:18.0]];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    topView = [self cellView];
    bottomView = [self buttonView];
    [self addSubview:bottomView];
    [self addSubview:topView];
    
    // Text Labels
    [topView addSubview:self.detailTextLabel];
    [topView addSubview:self.textLabel];
}

- (UIView *)cellView
{
    UIView *view = [[UIView alloc] initWithFrame:cellFrame];
    [view setBackgroundColor:eggWhite];
    
    UISwipeGestureRecognizer *gr_left = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(showOptions:)];
    [gr_left setDirection:UISwipeGestureRecognizerDirectionLeft];
    UISwipeGestureRecognizer *gr_right = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(hideOptions:)];
    [gr_right setDirection:UISwipeGestureRecognizerDirectionRight];
    
    [view setGestureRecognizers:[NSArray arrayWithObjects:gr_left, gr_right, nil]];
    
    return view;
}

- (UIView *)buttonView
{
    UIView *background = [[UIView alloc] initWithFrame:cellFrame];
    [background setBackgroundColor:mint];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(232, 0, BUTTON_WIDTH*2, CELL_HEIGHT)];
    [imageView setImage:[UIImage imageNamed:@"cellOptions"]];
    [background addSubview:imageView];
    
    CGRect buttonFrame = CGRectMake(self.bounds.size.width-BUTTON_WIDTH, 0,
                                    BUTTON_WIDTH, CELL_HEIGHT);
    
    // Completed
    UIButton *completedButton = [[UIButton alloc] initWithFrame:buttonFrame];
    [completedButton addTarget:self action:@selector(completeTask:) forControlEvents:UIControlEventTouchUpInside];
    [background addSubview:completedButton];
    
    // Completed
    buttonFrame.origin.x = self.bounds.size.width-BUTTON_WIDTH*2;
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:buttonFrame];
    [deleteButton addTarget:self action:@selector(deleteTask:) forControlEvents:UIControlEventTouchUpInside];
    [background addSubview:deleteButton];
    
    return background;
}

- (void)showOptions:(id)sender
{
    CGRect frame = topView.frame;
    if (frame.origin.x != X_CELL_NORMAL) {
        return;
    }
    
    [self.detailTextLabel setHidden:YES];
    
    frame.origin.x = X_CELL_SWIPED;
    [UIView animateWithDuration:0.20
                     animations:^{
                         [topView setFrame:frame];
                     }
                     completion:^(BOOL finished) {
                     }
     ];
}

- (void)hideOptions:(id)sender
{
    CGRect frame = topView.frame;
    if (frame.origin.x != X_CELL_SWIPED) {
        return;
    }
    
    frame.origin.x = X_CELL_NORMAL;
    [UIView animateWithDuration:0.20
                     animations:^{
                         [topView setFrame:frame];
                     }
                     completion:^(BOOL finished) {
                         [self.detailTextLabel setHidden:NO];
                     }
     ];
}

- (void)completeTask:(id)sender
{
    [self hideOptions:nil];
    [delegate taskCompleted:self];
}

- (void)deleteTask:(id)sender
{
    [self hideOptions:nil];
    [delegate deleteTask:self];
}

@end
