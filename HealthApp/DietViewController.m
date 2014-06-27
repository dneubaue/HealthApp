//
//  DietViewController.m
//  HealthApp
//
//  Created by David Neubauer on 4/5/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "DietViewController.h"
#import "DietMainView.h"
#import "NewFoodViewController.h"
#import "AddFoodViewController.h"
#import "FoodStore.h"
#import "Food.h"
#import "NutritionCell.h"
#import "PieChart.h"
#import "NavigationButton.h"
#import "TableHeaderView.h"
#import "TableCell.h"
#import "PlusButton.h"
#import "ChooseMealViewController.h"

#define DIARY_TAG 0
#define NUTRI_TAG 1

@interface DietViewController ()
{
    UIColor *eggWhite;
    UIColor *darkerGray;
    UIColor *lighterGray;
    UIColor *mint;
    
    UIColor *fruitColor;
    UIColor *grainColor;
    UIColor *proteinColor;
    UIColor *veggieColor;
    UIColor *dairyColor;
    
    UITableView *diaryTable;
    UITableView *nutriTable;
    
    UIView *diaryView;
    UIScrollView *nutritionView;
    
    UIView *fruitLevel;
    UIView *grainLevel;
    UIView *proteinLevel;
    UIView *veggieLevel;
    UIView *dairyLevel;
    
    UILabel *amountLabel;
    UIView *waterView;
    UIImageView *newWaterGlass;
    UIButton *newWaterButton;
    
    UIPageControl *pageControl;
    
    NSArray *diaryHeaders;
    NSMutableArray *foodDiary;
    
    PieChart *pieChart;
    
    NavigationButton *navButton;
    BOOL shouldCloseNavButton;
}
@end

@implementation DietViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        eggWhite = [UIColor colorWithRed:(218/255.0) green:(218/255.0) blue:(218/255.0) alpha:1.0];
        darkerGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:1.0];
        lighterGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.7];
        mint = [UIColor colorWithRed:(63/255.0) green:(195/255.0) blue:(128/255.0) alpha:1.0];
        
        fruitColor = [UIColor colorWithRed:(224/255.0) green:(130/255.0) blue:(131/255.0) alpha:1.0];
        grainColor = [UIColor colorWithRed:(254/255.0) green:(201/255.0) blue:(86/255.0) alpha:1.0];
        proteinColor = [UIColor colorWithRed:(179/255.0) green:(136/255.0) blue:(221/255.0) alpha:1.0];
        veggieColor = [UIColor colorWithRed:(163/255.0) green:(215/255.0) blue:(112/255.0) alpha:1.0];
        dairyColor = [UIColor colorWithRed:(137/255.0) green:(196/255.0) blue:(244/255.0) alpha:1.0];
        
        diaryHeaders = [[NSArray alloc] initWithObjects:@"Breakfast", @"Lunch", @"Dinner", @"Snack", nil];
        foodDiary = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (shouldCloseNavButton) {
        [navButton toggleRotation];
        shouldCloseNavButton = NO;
    }
    
    [[FoodStore sharedStore] resetData];
    [diaryTable reloadData];
    [nutriTable reloadData];
    [waterView removeFromSuperview];
    
    // Update Pie Chart
    [pieChart removeFromSuperview];
    [self setUpPieGraph];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    
    // Main View
    CGRect frame = [[UIScreen mainScreen] bounds];
    DietMainView *view = [[DietMainView alloc] initWithFrame:frame];
    [self setView:view];
    
    // Nav Button
    navButton = [[NavigationButton alloc] init];
    [navButton addTarget:self action:@selector(showSidePanel:) forControlEvents:UIControlEventTouchUpInside];
    if (shouldCloseNavButton) {
        [navButton moveToOpen]; // Open nav, so animating to close it happens when view appears
    }
    [self.view addSubview:navButton];
    
    // Add Button
    PlusButton *addButton = [[PlusButton alloc] init];
    [addButton addTarget:self action:@selector(addFood:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addButton];
    
    // Segmented Control
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(100, 27, 120, 30)];
    [segmentedControl addTarget:self action:@selector(changeContentView:) forControlEvents:UIControlEventValueChanged];
    [segmentedControl setTintColor:darkerGray];
    [segmentedControl insertSegmentWithTitle:@"Diary" atIndex:0 animated:NO];
    [segmentedControl insertSegmentWithTitle:@"Nutrition" atIndex:1 animated:NO];
    [segmentedControl setSelectedSegmentIndex:0];
    [self.view addSubview:segmentedControl];
    
    // -- NUTRITION VIEW --
    nutritionView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64,
                                                                   self.view.frame.size.width,
                                                                   self.view.frame.size.height-64)];
    nutritionView.contentSize = CGSizeMake(self.view.frame.size.width, 504);
    [nutritionView setBackgroundColor:eggWhite];
    nutritionView.userInteractionEnabled = ((int)frame.size.height != 568);
    
    [self setUpPieGraph];
    
    UIView *topBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 268, 320, 1)];
    [topBarBackground setBackgroundColor:darkerGray];
    [self.view addSubview:topBarBackground];
    
    UIView *bottomBarBackground = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 225, 320, 1)];
    [bottomBarBackground setBackgroundColor:darkerGray];
    [self.view addSubview:bottomBarBackground];
    
    // Table
    CGRect nutriTableFrame = CGRectMake(0, nutritionView.contentSize.height - 258, nutritionView.frame.size.width, 248);
    nutriTable = [[UITableView alloc] initWithFrame:nutriTableFrame style:UITableViewStylePlain];
    [nutriTable setTag:NUTRI_TAG];
    [nutriTable setBackgroundColor:eggWhite];
    [nutriTable setSeparatorColor:[UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.25]];
    [nutriTable setUserInteractionEnabled:NO];
    [nutriTable setDelegate:self];
    [nutriTable setDataSource:self];
    [nutritionView addSubview:nutriTable];
    
    // -- Water Consumption --
//    waterView = [[UIView alloc]
//                     initWithFrame:CGRectMake(nutritionView.frame.size.width, 0,
//                                              nutritionView.frame.size.width, 248)];
//    [waterView setBackgroundColor:eggWhite];
//    [scrollView addSubview:waterView];
//    
//    // Header
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
//    [headerView setBackgroundColor:eggWhite];
//    [waterView addSubview:headerView];
//    
//    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
//    [topBar setBackgroundColor:darkerGray];
//    [waterView addSubview:topBar];
//    
//    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 1)];
//    [bottomBar setBackgroundColor:darkerGray];
//    [waterView addSubview:bottomBar];
//    
//    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 320, 44)];
//    [waterView addSubview:headerLabel];
//    [headerLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:24.0]];
//    [headerLabel setTextColor:darkerGray];
//    [headerLabel setText:@"Water Consumption"];
//    
//    // Glasses
//    [self setUpWaterGlasses];
//    
//    // Labels
//    amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(67, 122, 184, 57)];
//    int numWater = [[FoodStore sharedStore] glassesOfWater];
//    [amountLabel setText:[NSString stringWithFormat:@"%d", numWater]];
//    [amountLabel setTextAlignment:NSTextAlignmentCenter];
//    [amountLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:48.0]];
//    [amountLabel setTextColor:darkerGray];
//    [waterView addSubview:amountLabel];
//    
//    UILabel *waterLabel = [[UILabel alloc] initWithFrame:CGRectMake(67, 179, 184, 38)];
//    [waterLabel setText:@"Glasses of Water"];
//    [waterLabel setTextAlignment:NSTextAlignmentCenter];
//    [waterLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0]];
//    [waterLabel setTextColor:darkerGray];
//    [waterView addSubview:waterLabel];
    
    
    
    // -- DIARY VIEW --
    diaryView = [[UIView alloc] initWithFrame:CGRectMake(0, 64,
                                                         self.view.frame.size.width, self.view.frame.size.height-64)];
    [diaryView setBackgroundColor:eggWhite];
    [self.view addSubview:diaryView];
    
    // Table
    CGRect diaryTableFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64);
    diaryTable = [[UITableView alloc] initWithFrame:diaryTableFrame style:UITableViewStylePlain];
    [diaryView setTag:DIARY_TAG];
    [diaryTable setBackgroundColor:eggWhite];
    [diaryTable setSeparatorColor:[UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.25]];
    [diaryTable setDelegate:self];
    [diaryTable setDataSource:self];
    [diaryView addSubview:diaryTable];
}

#pragma mark -
#pragma mark UIScrollView

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset = [scrollView contentOffset];
    int page = offset.x / self.view.frame.size.width;
    [pageControl setCurrentPage:page];
}

#pragma mark -
#pragma mark UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (tableView.tag == DIARY_TAG)? 54 : 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == DIARY_TAG) {
        
        NSString *title = [diaryHeaders objectAtIndex:section];
        TableHeaderView *view = [[TableHeaderView alloc] initWithTitle:title];
        
        UIButton *button = [[UIButton alloc] init];
        CGRect frame = view.frame;
        frame.origin = CGPointMake(0, 0);
        [button setFrame:frame];
        [button addTarget:self action:@selector(addFood:) forControlEvents:UIControlEventTouchUpInside];
        [button setTag:section+1];
        [view addSubview:button];
        
        return view;
    }
    else {
//        TableHeaderView *view = [[TableHeaderView alloc] initWithTitle:@"Nutrition Data"];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        [view setBackgroundColor:eggWhite];
        
        // Title
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 320, 44)];
        [view addSubview:headerLabel];
        [headerLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:24.0]];
        [headerLabel setTextColor:darkerGray];
        [headerLabel setText:@"Nutrition Data"];
        
        // Total
        UILabel *totalLabel = [[UILabel alloc] init];
        totalLabel.frame = CGRectMake(204, 0, 56, 44);
        totalLabel.textColor = darkerGray;
        totalLabel.textAlignment = NSTextAlignmentCenter;
        totalLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
        totalLabel.text = @"Total";
        [view addSubview:totalLabel];
        
        // Goal
        UILabel *goalLabel = [[UILabel alloc] init];
        goalLabel.frame = CGRectMake(260, 0, 56, 44);
        goalLabel.textColor = darkerGray;
        goalLabel.textAlignment = NSTextAlignmentCenter;
        goalLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
        goalLabel.text = @"Goal";
        [view addSubview:goalLabel];
        
        UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
        [topBar setBackgroundColor:darkerGray];
        [view addSubview:topBar];
        
        UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 1)];
        [bottomBar setBackgroundColor:darkerGray];
        [view addSubview:bottomBar];
        
        UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(260, 15, 1, 14)];
        [divider setBackgroundColor:darkerGray];
        [view addSubview:divider];
        
        return view;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (tableView.tag == DIARY_TAG)? 4 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == DIARY_TAG) {
        int numMeals = [[FoodStore sharedStore] numberOfFoodInMeal:(int)section];
        return numMeals;
    }
    else {
        return 6;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (tableView.tag == DIARY_TAG)? 44 : 34;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == DIARY_TAG) {
        TableCell *cell = [[TableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        
        Food *f = [[FoodStore sharedStore] foodNumber:(int)indexPath.row fromMeal:(int)indexPath.section];
        [cell.textLabel setText:f.name];
        [cell setAccessoryView:[self viewForFoodGroups:f.foodGroups]];
        
        return cell;
    }
    else {
        NutritionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!cell) {
            cell = [[NutritionCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                          reuseIdentifier:@"cell"];
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell.textLabel setTextColor:darkerGray];
        [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:18.0]];
        [cell setBackgroundColor:eggWhite];
        [cell setFoodGroup:(int)indexPath.row];
        
        return cell;
    }
}

- (UIView *)viewForFoodGroups:(NSArray *)foodGroups
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 34, 40)];
    
    for (int i = 0; i < 6; i++) {
        CGFloat number = ((NSNumber *)[foodGroups objectAtIndex:i]).floatValue;
        if (number > 0) {
            UIImageView *hex = [[UIImageView alloc] init];
            switch (i) {
                case 0:
                    [hex setFrame:CGRectMake(1, 10, 16, 19)];
                    [hex setImage:[UIImage imageNamed:@"hexCell_6"]];
                    break;
                case 1:
                    [hex setFrame:CGRectMake(1, 1, 16, 19)];
                    [hex setImage:[UIImage imageNamed:@"hexCell_1"]];
                    break;
                case 2:
                    [hex setFrame:CGRectMake(17, 1, 16, 19)];
                    [hex setImage:[UIImage imageNamed:@"hexCell_2"]];
                    break;
                case 3:
                    [hex setFrame:CGRectMake(17, 10, 16, 19)];
                    [hex setImage:[UIImage imageNamed:@"hexCell_3"]];
                    break;
                case 4:
                    [hex setFrame:CGRectMake(17, 19, 16, 19)];
                    [hex setImage:[UIImage imageNamed:@"hexCell_4"]];
                    break;
                case 5:
                    [hex setFrame:CGRectMake(1, 19, 16, 19)];
                    [hex setImage:[UIImage imageNamed:@"hexCell_5"]];
                    break;
            }
            [view addSubview:hex];
        }
    }
    
    UIImageView *backgroundHex = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 34, 39)];
    [backgroundHex setImage:[UIImage imageNamed:@"hexCell_background"]];
    [view addSubview:backgroundHex];
    
    return view;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (tableView.tag == DIARY_TAG) {
            [[FoodStore sharedStore] deleteFoodNumber:(int)indexPath.row andMeal:(int)indexPath.section];

            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                 withRowAnimation:UITableViewRowAnimationRight];
        }
    }
}

#pragma mark -

- (void)setUpPieGraph
{
    // Pie Graph
    CGRect frame = CGRectMake(60, 18, 200, 200);
    pieChart = [[PieChart alloc] initWithFrame:frame];
    [nutritionView addSubview:pieChart];
}

- (void)setUpPieGraph2
{
    CGRect pieFrame = CGRectMake(67, 27, 226, 186);
    UIView *pieGraph = [[UIView alloc] initWithFrame:pieFrame];
    [pieGraph setBackgroundColor:eggWhite];
    [nutritionView addSubview:pieGraph];
    
    // Food groups outlines
    // Fruit
    CGFloat fruitPercent = [[FoodStore sharedStore] getFruitPercent] / 100.0;
    CGSize fruitLevelSize = CGSizeMake(86, 70 * fruitPercent);
    fruitLevel = [[UIView alloc] initWithFrame:CGRectMake(10, 10 + (69 - fruitLevelSize.height),
                                                                  fruitLevelSize.width - 10, fruitLevelSize.height)];
    [fruitLevel setBackgroundColor:fruitColor];
    [pieGraph addSubview:fruitLevel];
    
    UIImageView *fruit = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 86, 79)];
    [fruit setImage:[UIImage imageNamed:@"pie_fruit"]];
    [pieGraph addSubview:fruit];
    
    // Grain
    CGFloat grainPercent = [[FoodStore sharedStore] getGrainPercent] / 100.0;
    CGSize grainLevelSize = CGSizeMake(86, 85 * grainPercent);
    grainLevel = [[UIView alloc] initWithFrame:CGRectMake(101, 10 + (85 - grainLevelSize.height),
                                                                  grainLevelSize.width - 10, grainLevelSize.height)];
    [grainLevel setBackgroundColor:grainColor];
    [pieGraph addSubview:grainLevel];
    
    UIImageView *grain = [[UIImageView alloc] initWithFrame:CGRectMake(96, 5, 86, 95)];
    [grain setImage:[UIImage imageNamed:@"pie_grain"]];
    [pieGraph addSubview:grain];
    
    // Protein
    CGFloat proteinPercent = [[FoodStore sharedStore] getProteinPercent] / 100.0;
    CGSize proteinLevelSize = CGSizeMake(86, 67 * proteinPercent);
    proteinLevel = [[UIView alloc] initWithFrame:CGRectMake(100, 109 + (67 - proteinLevelSize.height),
                                                                  proteinLevelSize.width - 10, proteinLevelSize.height)];
    [proteinLevel setBackgroundColor:proteinColor];
    [pieGraph addSubview:proteinLevel];
    
    UIImageView *protein = [[UIImageView alloc] initWithFrame:CGRectMake(96, 104, 86, 77)];
    [protein setImage:[UIImage imageNamed:@"pie_protein"]];
    [pieGraph addSubview:protein];
    
    // Veggie
    CGFloat veggiePercent = [[FoodStore sharedStore] getVeggiePercent] / 100.0;
    CGSize veggieLevelSize = CGSizeMake(86, 85 * veggiePercent);
    veggieLevel = [[UIView alloc] initWithFrame:CGRectMake(10, 92 + (85 - veggieLevelSize.height),
                                                                    veggieLevelSize.width - 10, veggieLevelSize.height)];
    [veggieLevel setBackgroundColor:veggieColor];
    [pieGraph addSubview:veggieLevel];
    
    UIImageView *veggie = [[UIImageView alloc] initWithFrame:CGRectMake(5, 87, 86, 95)];
    [veggie setImage:[UIImage imageNamed:@"pie_veggie"]];
    [pieGraph addSubview:veggie];
    
    // Background
    UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 186, pieFrame.size.height)];
    [background setImage:[UIImage imageNamed:@"pie_background"]];
    [pieGraph addSubview:background];
    
    // Plate
    UIImageView *plate = [[UIImageView alloc] initWithFrame:CGRectMake(-5, -5, 196, 196)];
    [plate setImage:[UIImage imageNamed:@"plate"]];
    [pieGraph addSubview:plate];
    
    // Dairy
    CGFloat dairyPercent = [[FoodStore sharedStore] getDairyPercent] / 100.0;
    CGSize dairyLevelSize = CGSizeMake(51, 41 * dairyPercent);
    dairyLevel = [[UIView alloc] initWithFrame:CGRectMake(175, 9 + (41 - dairyLevelSize.height),
                                                           dairyLevelSize.width - 10, dairyLevelSize.height)];
    [dairyLevel setBackgroundColor:dairyColor];
    [pieGraph addSubview:dairyLevel];
    
    UIImageView *dairy = [[UIImageView alloc] initWithFrame:CGRectMake(170, 4, 51, 51)];
    [dairy setImage:[UIImage imageNamed:@"pie_dairy"]];
    [pieGraph addSubview:dairy];
    
    // Dairy - Background
    UIImageView *dairyBackground = [[UIImageView alloc] initWithFrame:CGRectMake(166, 0, 60, 60)];
    [dairyBackground setImage:[UIImage imageNamed:@"pie_dairyBackground"]];
    [pieGraph addSubview:dairyBackground];
    
    // Cup
    UIImageView *cup = [[UIImageView alloc] initWithFrame:CGRectMake(165, -1, 61, 61)];
    [cup setImage:[UIImage imageNamed:@"cup"]];
    [pieGraph addSubview:cup];
}

- (void)updatePieChart
{
    CGRect frame;
    
    // Fruit
    CGFloat fruitPercent = [[FoodStore sharedStore] getFruitPercent] / 100.0;
    fruitPercent = (fruitPercent > 1)? 1 : fruitPercent;
    CGSize fruitLevelSize = CGSizeMake(86, 70 * fruitPercent);
    frame = CGRectMake(10, 10 + (69 - fruitLevelSize.height), fruitLevelSize.width - 10, fruitLevelSize.height);
    [fruitLevel setFrame:frame];
    
    // Grain
    CGFloat grainPercent = [[FoodStore sharedStore] getGrainPercent] / 100.0;
    grainPercent = (grainPercent > 1)? 1 : grainPercent;
    CGSize grainLevelSize = CGSizeMake(86, 85 * grainPercent);
    frame = CGRectMake(101, 10 + (85 - grainLevelSize.height), grainLevelSize.width - 10, grainLevelSize.height);
    [grainLevel setFrame:frame];
    
    // Protein
    CGFloat proteinPercent = [[FoodStore sharedStore] getProteinPercent] / 100.0;
    proteinPercent = (proteinPercent > 1)? 1 : proteinPercent;
    CGSize proteinLevelSize = CGSizeMake(86, 67 * proteinPercent);
    frame = CGRectMake(100, 109 + (67 - proteinLevelSize.height), proteinLevelSize.width - 10, proteinLevelSize.height);
    [proteinLevel setFrame:frame];

    // Veggie
    CGFloat veggiePercent = [[FoodStore sharedStore] getVeggiePercent] / 100.0;
    veggiePercent = (veggiePercent > 1)? 1 : veggiePercent;
    CGSize veggieLevelSize = CGSizeMake(86, 85 * veggiePercent);
    frame = CGRectMake(10, 92 + (85 - veggieLevelSize.height), veggieLevelSize.width - 10, veggieLevelSize.height);
    [veggieLevel setFrame:frame];
    
    // Dairy
    CGFloat dairyPercent = [[FoodStore sharedStore] getDairyPercent] / 100.0;
    dairyPercent = (dairyPercent > 1)? 1 : dairyPercent;
    CGSize dairyLevelSize = CGSizeMake(51, 42 * dairyPercent);
    frame = CGRectMake(175, 9 + (41 - dairyLevelSize.height), dairyLevelSize.width - 10, dairyLevelSize.height);
    [dairyLevel setFrame:frame];
}

- (void)changeContentView:(id)sender
{
    UISegmentedControl *segControl = sender;
    if (segControl.selectedSegmentIndex == 0) {
        [diaryTable reloadData];        
        [self.view addSubview:diaryView];
        [pageControl removeFromSuperview];
        [nutritionView removeFromSuperview];
    }
    else {
        [nutriTable reloadData];
        [pieChart removeFromSuperview];
        [self setUpPieGraph];
        [self.view addSubview:nutritionView];
        [self.view addSubview:pageControl];
        [diaryView removeFromSuperview];
    }
}

#pragma mark -
#pragma mark UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        return;
    }
    
    AddFoodViewController *add_VC = [[AddFoodViewController alloc] init];
    [add_VC setMeal:(int)buttonIndex-1];
    [add_VC setParent_VC:self];
    [self.navigationController pushViewController:add_VC animated:YES];
}

#pragma mark -

- (void)addFood:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button.tag == 0) {
        ChooseMealViewController *choose_VC = [[ChooseMealViewController alloc] init];
        [choose_VC setParent_VC:self];
        [self.navigationController pushViewController:choose_VC animated:YES];
    }
    else {
        AddFoodViewController *add_VC = [[AddFoodViewController alloc] init];
        [add_VC setMeal:(int)button.tag-1];
        [add_VC setParent_VC:self];
        [self.navigationController pushViewController:add_VC animated:YES];
    }
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Add Food"
//                                                        message:@"Pick meal time"
//                                                       delegate:self
//                                              cancelButtonTitle:@"Cancel"
//                                              otherButtonTitles:@"Breakfast", @"Lunch", @"Dinner", @"Snack", nil];
//    [alertView show];
    
    
//    AddDietViewController *addDiet_VC = [[AddDietViewController alloc] init];
//    
//    [self.navigationController pushViewController:addDiet_VC animated:YES];
//    UIButton *button = sender;
//    if (![button.titleLabel.text isEqualToString:@""]) {
//        [addDiet_VC setMealName:button.titleLabel.text];
//    }
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

#pragma mark -

@end
