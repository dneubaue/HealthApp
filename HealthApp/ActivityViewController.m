//
//  ActivityViewController.m
//  HealthApp
//
//  Created by David Neubauer on 4/2/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "ActivityViewController.h"
#import "ActivityMainView.h"
#import "AddActivityViewController.h"
#import "ActivityStore.h"
#import "TitleLabel.h"
#import "NavigationButton.h"
#import "RightHeaderButton.h"
#import "TableCell.h"
#import "TableHeaderView.h"

#define GRAPH_HEIGHT 183

@interface ActivityViewController ()
{
    // Colors
    UIColor *eggWhite;
    UIColor *disabledGray;
    UIColor *darkerGray;
    UIColor *lighterGray;
    UIColor *mint;
    
    NSArray *headerTitles;
    NSArray *dayInitials;
    NSArray *cellStrings;
    NSMutableArray *earlierActs;
    UITableView *activityTable;
    UIView *graphBackground;
    BOOL noActitiesToday;
    BOOL shouldCloseNavButton;
    NavigationButton *navButton;
}
@end

@implementation ActivityViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        eggWhite = [UIColor colorWithRed:(218/255.0) green:(218/255.0) blue:(218/255.0) alpha:1.0];
        disabledGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.1];
        darkerGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:1.0];
        lighterGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.7];
        mint = [UIColor colorWithRed:(63/255.0) green:(195/255.0) blue:(128/255.0) alpha:1.0];
        
        headerTitles = [[NSArray alloc] initWithObjects:@"Today's Activites", @"Earlier", nil];
        dayInitials = [[NSArray alloc] initWithObjects:@"S", @"M", @"T", @"W", @"T", @"F", @"S", nil];
        cellStrings = [NSArray arrayWithObjects:@"Everyday", @"Aerobic Exercise", @"Recreational Activity",
                                                @"Strength Training", @"Flexibility Training", nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (shouldCloseNavButton) {
        [navButton toggleRotation];
        shouldCloseNavButton = NO;
    }
    
    [[ActivityStore sharedStore] reset];
    
    [self resetGraph];
    [activityTable reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    
    // Main View
    CGRect frame = [[UIScreen mainScreen] bounds];
    ActivityMainView *view = [[ActivityMainView alloc] initWithFrame:frame];
    [self setView:view];
    
    // Nav Button
    navButton = [[NavigationButton alloc] init];
    [navButton addTarget:self action:@selector(showSidePanel:) forControlEvents:UIControlEventTouchUpInside];
    if (shouldCloseNavButton) {
        [navButton moveToOpen]; // Open nav, so animating to close it happens when view appears
    }
    [self.view addSubview:navButton];
    
    // Add Button
    RightHeaderButton *addButton = [[RightHeaderButton alloc] init];
    [addButton setTitle:@"Edit" forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addActivity:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addButton];
    
    // Title
    TitleLabel *title = [[TitleLabel alloc] init];
    [title setText:@"Activity"];
    [self.view addSubview:title];
    
    // Table
    CGRect tableFrame = CGRectMake(0, 64, 320, frame.size.height-GRAPH_HEIGHT-64);
    activityTable = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    [activityTable setBackgroundColor:eggWhite];
    [activityTable setSeparatorColor:[UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.25]];
    [activityTable setDelegate:self];
    [activityTable setDataSource:self];
    [self.view addSubview:activityTable];
    
    // Bottom Graph
    [self buildGraph];
}

#pragma mark -
#pragma mark UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 54;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = [headerTitles objectAtIndex:section];
    TableHeaderView *headerView = [[TableHeaderView alloc] initWithTitle:title];
    
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; // Today and Earlier
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        int today = (int)[[[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:[NSDate date]] weekday];
        int todayActs = [[ActivityStore sharedStore] getActivitiesForDay:today-1];
        int numberOfRows = [[ActivityStore sharedStore] getNumberOfActivitesForActs:todayActs];
        if (numberOfRows == 0) {
            numberOfRows = 1;
            noActitiesToday = YES;
        }
        else {
            noActitiesToday = NO;
        }
        return numberOfRows;
    }
    earlierActs = [[ActivityStore sharedStore] getEarlierActivites];
    return [[ActivityStore sharedStore] getNumberOfEarlierActivites:earlierActs];
        
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableCell *cell = [[TableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    if (indexPath.section == 0) {
        if (noActitiesToday) {
            [cell.textLabel setText:@"Tap \"Edit\" to add activity"];
            [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
            [cell.textLabel setTextColor:lighterGray];
        }
        else {
            int actIndex = [[ActivityStore sharedStore] getTodayActNumber:(int)indexPath.row];
            [cell.textLabel setText:[cellStrings objectAtIndex:actIndex]];
        }
    }
    else {
        int actIndex = [[ActivityStore sharedStore] getEarlierAct:earlierActs Number:(int)indexPath.row];
        [cell.textLabel setText:[cellStrings objectAtIndex:actIndex]];
    }
    
    return cell;
}

#pragma mark -

- (void)buildGraph
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    CGRect graphFrame = CGRectMake(0, frame.size.height-GRAPH_HEIGHT, 320, GRAPH_HEIGHT);
    
    // Background
    graphBackground = [[UIView alloc] initWithFrame:graphFrame];
    [graphBackground setBackgroundColor:mint];
    
    
    // Label Days of the week
    int x = 3;
    for (int i = 0; i < 7; i++) {
        UILabel *day = [[UILabel alloc] initWithFrame:CGRectMake(x, 124, 44, 40)];
        [day setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:24.0]];
        [day setTextAlignment:NSTextAlignmentCenter];
        int today = (int)[[[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:[NSDate date]] weekday];
        if (i == today-1) {
            // Draw circle behind text
            UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(x+6, 128, 32, 32)];
            [circle.layer setCornerRadius: 16];
            [circle setBackgroundColor:eggWhite];
            [graphBackground addSubview:circle];
            
            [day setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:24.0]];
            [day setTextColor:mint];
        }
        else {
            [day setTextColor:eggWhite];
        }
        
        NSString *initial = [dayInitials objectAtIndex:i];
        [day setText:initial];
        
        [graphBackground addSubview:day];
        x += 44;
    }
    
    // Bars for days of week
    x = 15;
    for (int i = 0; i < 7; i++) {
        int numActivities = [[ActivityStore sharedStore] tallyActivityPoints:i];
        int height = numActivities * 10;
        height = (height <= 0)? 1 : height;
        int y = 32 + 92 - height;
        UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(x, y, 20, height)];
        [bar setBackgroundColor:eggWhite];
        [graphBackground addSubview:bar];
        
        x += 44;
    }
    
    
    [self.view addSubview:graphBackground];
}

- (void)resetGraph
{
    [graphBackground removeFromSuperview];
    [self buildGraph];
}


- (void)addActivity:(id)sender
{
    AddActivityViewController *addAct_VC = [[AddActivityViewController alloc] init];
    [self.navigationController pushViewController:addAct_VC animated:YES];
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
    shouldCloseNavButton = YES;
}

@end
