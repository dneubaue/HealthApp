//
//  ChooseMealViewController.m
//  HealthApp
//
//  Created by David Neubauer on 5/26/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "ChooseMealViewController.h"
#import "ChooseMealView.h"
#import "AddFoodViewController.h"

#import "TitleLabel.h"
#import "CancelButton.h"
#import "TableHeaderView.h"
#import "TableCell.h"

@interface ChooseMealViewController ()
{
    UIColor *eggWhite;
    UIColor *darkerGray;
    UIColor *lighterGray;
    UIColor *mint;
    
    NSArray *mealTimes;
}
@end

@implementation ChooseMealViewController
@synthesize parent_VC;

- (id)init
{
    self = [super init];
    if (self) {
        eggWhite = [UIColor colorWithRed:(218/255.0) green:(218/255.0) blue:(218/255.0) alpha:1.0];
        darkerGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:1.0];
        lighterGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.7];
        mint = [UIColor colorWithRed:(63/255.0) green:(195/255.0) blue:(128/255.0) alpha:1.0];
        
        mealTimes = [[NSArray alloc] initWithObjects:@"Breakfast", @"Lunch", @"Dinner", @"Snack", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Main View
    CGRect frame = [[UIScreen mainScreen] bounds];
    ChooseMealView *view = [[ChooseMealView alloc] initWithFrame:frame];
    [self setView:view];
    
    // Close Button
    CancelButton *closeButton = [[CancelButton alloc] init];
    [closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    // Title
    TitleLabel *title = [[TitleLabel alloc] init];
    [title setText:@"Meal"];
    [self.view addSubview:title];
    
    // Table
    CGRect mealTableFrame = CGRectMake(0, 100, 320, 230);
    UITableView *mealTable = [[UITableView alloc] initWithFrame:mealTableFrame style:UITableViewStylePlain];
    [mealTable setBackgroundColor:eggWhite];
    [mealTable setSeparatorColor:[UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.25]];
    [mealTable setDelegate:self];
    [mealTable setDataSource:self];
    [self.view addSubview:mealTable];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 54.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TableHeaderView *header = [[TableHeaderView alloc] initWithTitle:@"Choose Meal Time"];
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableCell *cell = [[TableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    NSString *title = [mealTimes objectAtIndex:indexPath.row];
    [cell.textLabel setText:title];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddFoodViewController *add_VC = [[AddFoodViewController alloc] init];
    [add_VC setMeal:(int)indexPath.row];
    [add_VC setParent_VC:parent_VC];
    [self.navigationController pushViewController:add_VC animated:YES];
}

#pragma mark -

- (void)close:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
