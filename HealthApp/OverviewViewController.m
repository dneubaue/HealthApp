//
//  OverviewViewController.m
//  HealthApp
//
//  Created by David Neubauer on 5/4/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "OverviewViewController.h"
#import "OverviewMainView.h"
#import "MonitorBackgroundView.h"
#import "MonitorForegroundView.h"
#import "GraphBackground.h"
#import "GraphPlot.h"
#import "ActivityStore.h"
#import "FoodStore.h"
#import "TaskStore.h"
#import "UserDataStore.h"
#import "TitleLabel.h"
#import "NavigationButton.h"

#define MAX_STARS 4
#define NUM_LEVELS 25

@interface OverviewViewController ()
{
    UIColor *eggWhite;
    UIColor *darkerGray;
    UIColor *lighterGray;
    UIColor *mint;
    
    UIScrollView *scrollView;
    
    MonitorForegroundView *pointsMonitor;
    UILabel *levelLabel;
//    int totalPoints;
    
    UILabel *totalPointsLabel;
    UILabel *neededPointsLabel;
    
    GraphPlot *plot;
    
    UIView *starView;
    
    NavigationButton *navButton;
    BOOL shouldCloseNavButton;
}
@end

@implementation OverviewViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        eggWhite = [UIColor colorWithRed:(218/255.0) green:(218/255.0) blue:(218/255.0) alpha:1.0];
        darkerGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:1.0];
        lighterGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.7];
        mint = [UIColor colorWithRed:(63/255.0) green:(195/255.0) blue:(128/255.0) alpha:1.0];
        
        pointsMonitor = nil;
//        totalPoints = 0;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (shouldCloseNavButton) {
        [navButton toggleRotation];
        shouldCloseNavButton = NO;
    }
    
    [[UserDataStore sharedStore] reset];
    
    int totalPoints = [[UserDataStore sharedStore] getUserPoints];
    int level = [[UserDataStore sharedStore] getUserLevel] + 1;
    int pointsLeft = [[UserDataStore sharedStore] pointsRemaining];
    
    // Monitor
    CGRect backgroundFrame = CGRectMake((320 - 184)/2.0, 11, 184, 184);
    [pointsMonitor removeFromSuperview];
    pointsMonitor = [[MonitorForegroundView alloc] initWithFrame:backgroundFrame
                                                      andPercent:(totalPoints / ((double)totalPoints + pointsLeft))];
    [scrollView addSubview:pointsMonitor];
    [levelLabel setText:[NSString stringWithFormat:@"%d", level]];
    
    // Info Bar
    [totalPointsLabel setText:[NSString stringWithFormat:@"%d", totalPoints]];
    [neededPointsLabel setText:[NSString stringWithFormat:@"%d", pointsLeft]];
    
    // Graph
    CGRect plotFrame = CGRectMake(56, 323, 224, 135);
    [plot removeFromSuperview];
    plot = [[GraphPlot alloc] initWithFrame:plotFrame];
    [scrollView addSubview:plot];
    
    // Stars
    [starView removeFromSuperview];
    [self buildStars];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    
    // Main View
    CGRect frame = [[UIScreen mainScreen] bounds];
    OverviewMainView *view = [[OverviewMainView alloc] initWithFrame:frame];
    [self setView:view];
    
    // Nav Button
    navButton = [[NavigationButton alloc] init];
    [navButton addTarget:self action:@selector(showSidePanel:) forControlEvents:UIControlEventTouchUpInside];
    if (shouldCloseNavButton) {
        [navButton moveToOpen]; // Open nav, so animating to close it happens when view appears
    }
    [self.view addSubview:navButton];
    
    // Title
    TitleLabel *title = [[TitleLabel alloc] init];
    [title setText:@"Overview"];
    [self.view addSubview:title];
    
    // ScrollView
    CGRect scrollFrame = frame;
    scrollFrame.origin.y += 64;
    scrollFrame.size.height -= 64;
    scrollView = [[UIScrollView alloc] init];
    scrollView.frame = scrollFrame;
    scrollView.contentSize = CGSizeMake(320, 504);
    scrollView.scrollEnabled = ((int)frame.size.height != 568);
    [self.view addSubview:scrollView];
    [self.view sendSubviewToBack:scrollView];
    
    // Monitor
    [self buildMonitor];
    
    // Stars
    [self buildStars];
    
    // Info Bar
    [self buildInfoBar];
    
    // Graph
    [self buildGraph];
}

- (void)buildMonitor
{
    CGRect backgroundFrame = CGRectMake(68, 11, 184, 184);
    UIView *backgroundView = [[UIView alloc] initWithFrame:backgroundFrame];
    [scrollView addSubview:backgroundView];
    
    // Circles
    MonitorBackgroundView *monitorBackView = [[MonitorBackgroundView alloc] initWithFrame:backgroundFrame];
    [scrollView addSubview:monitorBackView];
    
    // Labels
    CGRect titleLabelFrame = CGRectMake(39, 35, 106, 40);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:24.0]];
    [titleLabel setTextColor:darkerGray];
    [titleLabel setText:@"Level"];
    [backgroundView addSubview:titleLabel];
    
    CGRect levelLabelFrame = CGRectMake(0, 55, 184, 99);
    levelLabel = [[UILabel alloc] initWithFrame:levelLabelFrame];
    [levelLabel setTextAlignment:NSTextAlignmentCenter];
    [levelLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:72.0]];
    [levelLabel setTextColor:darkerGray];
    [backgroundView addSubview:levelLabel];
}

- (void)buildStars
{
    CGRect backgroundFrame = CGRectMake(100, 221, 120, 24);
    starView = [[UIView alloc] initWithFrame:backgroundFrame];
    [scrollView addSubview:starView];
    
    for (int i = 0; i < 4; i++) {
        CGRect imageFrame = CGRectMake(100 + 32*i, 221, 24, 24);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
        [imageView setImage:[UIImage imageNamed:@"star_outline"]];
        [scrollView addSubview:imageView];
    }
    
    int stars = [[UserDataStore sharedStore] getUserStars];
    for (int i = 0; i < stars; i++) {
        CGRect imageFrame = CGRectMake(100 + 32*i, 221, 24, 24);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
        [imageView setImage:[UIImage imageNamed:@"star"]];
        [scrollView addSubview:imageView];
    }
}

- (void)buildInfoBar
{
    // Background
    CGRect backgroundFrame = CGRectMake(36, 256, 248, 56);
    UIView *backgroundView = [[UIView alloc] initWithFrame:backgroundFrame];
//    [backgroundView setBackgroundColor:mint];
    [scrollView addSubview:backgroundView];
    
    // Labels
    CGRect label1LFrame = CGRectMake(36, 256, 120, 19);
    UILabel *label1L = [[UILabel alloc] initWithFrame:label1LFrame];
    [label1L setTextAlignment:NSTextAlignmentCenter];
    [label1L setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:14.0]];
    [label1L setTextColor:darkerGray];
    [label1L setText:@"Total Points"];
    
    CGRect label1RFrame = CGRectMake(164, 256, 120, 19);
    UILabel *label1R = [[UILabel alloc] initWithFrame:label1RFrame];
    [label1R setTextAlignment:NSTextAlignmentCenter];
    [label1R setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:14.0]];
    [label1R setTextColor:darkerGray];
    [label1R setText:@"Points Needed"];
    [scrollView addSubview:label1L];
    [scrollView addSubview:label1R];
    
    CGRect frame = CGRectMake(36, 275, 120, 37);
    totalPointsLabel = [[UILabel alloc] initWithFrame:frame];
    [totalPointsLabel setTextAlignment:NSTextAlignmentCenter];
    [totalPointsLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:24.0]];
    [totalPointsLabel setTextColor:darkerGray];
    [scrollView addSubview:totalPointsLabel];
    
    frame = CGRectMake(164, 275, 120, 37);
    neededPointsLabel = [[UILabel alloc] initWithFrame:frame];
    [neededPointsLabel setTextAlignment:NSTextAlignmentCenter];
    [neededPointsLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:24.0]];
    [neededPointsLabel setTextColor:darkerGray];
    [scrollView addSubview:neededPointsLabel];
    
    // Divider
    CGRect dividerFrame = CGRectMake(159, 256, 1, 56);
    UIView *divider = [[UIView alloc] initWithFrame:dividerFrame];
    [divider setBackgroundColor:darkerGray];
    [scrollView addSubview:divider];
}

- (void)buildGraph
{
    CGRect backgroundFrame = CGRectMake(0, 323, 320, scrollView.contentSize.height-387);
    UIView *backgroundView = [[UIView alloc] initWithFrame:backgroundFrame];
    [scrollView addSubview:backgroundView];
    
    // Labels Y
    int levelPoints = [[UserDataStore sharedStore] pointsAtCurrentLevel];
    int labelText = levelPoints;
    for (int i = 0; i < 6; i++) {
        CGRect frame = CGRectMake(29, 24*i, 24, 22);
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]];
        [label setTextColor:darkerGray];
        if (labelText < 10) {
            [label setText:[NSString stringWithFormat:@"  %d", labelText]];
        } else {
            [label setText:[NSString stringWithFormat:@"%d", labelText]];
        }
        
        labelText -= (levelPoints/5.0);
        [backgroundView addSubview:label];
    }
    // Labels X
    NSArray *days = [[NSArray alloc] initWithObjects:@"S",@"M",@"T",@"W",@"T",@"F",@"S", nil];
    for (int i = 0; i < 7; i++) {
        CGRect frame = CGRectMake(56 + 32*i, 132, 24, 22);
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]];
        [label setTextColor:darkerGray];
        [label setText:[days objectAtIndex:i]];
        [backgroundView addSubview:label];
    }
    
    // Background
    CGRect graphFrame = CGRectMake(56, 0, 220, 131);
    GraphBackground *background = [[GraphBackground alloc] initWithFrame:graphFrame];
    [backgroundView addSubview:background];
}

- (void)showSidePanel:(id)sender
{
    [delegate movePanel];
    [navButton toggleRotation];
}

#pragma mark -
#pragma mark MainViewControllerDelegate

- (void)userChoseOtherViewController
{
    [navButton toggleRotation];
}

- (void)userChoseThisViewController
{
//    [navButton moveToOpen];
    shouldCloseNavButton = YES;
}

@end
