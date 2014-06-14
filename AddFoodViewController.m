//
//  AddFoodViewController.m
//  HealthApp
//
//  Created by David Neubauer on 5/11/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "AddFoodViewController.h"
#import "AddFoodView.h"
#import "NewFoodViewController.h"
#import "FoodStore.h"
#import "Food.h"

#import "TitleLabel.h"
#import "CancelButton.h"
#import "RightHeaderButton.h"
#import "TableHeaderView.h"
#import "TableCell.h"
#import "AlertView.h"

#define KEYBOARD_OFFSET 215

@interface AddFoodViewController () <AlertViewDelegate>
{
    UIColor *eggWhite;
    UIColor *disabledEggWhite;
    UIColor *darkerGray;
    UIColor *lighterGray;
    UIColor *mint;
    
    UITableView *foodTable;
    
    UIView *searchBackground;
    UISearchBar *searchField;
    UIButton *cancelButton;
    
    NSArray *alphabet;
    NSArray *sectionIndexes;
    
    NSString *meal;
    
    NSArray *catalog;
    
}
@end

@implementation AddFoodViewController
@synthesize parent_VC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        eggWhite = [UIColor colorWithRed:(218/255.0) green:(218/255.0) blue:(218/255.0) alpha:1.0];
        disabledEggWhite = [UIColor colorWithRed:(218/255.0) green:(218/255.0) blue:(218/255.0) alpha:0.5];
        darkerGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:1.0];
        lighterGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.5];
        mint = [UIColor colorWithRed:(63/255.0) green:(195/255.0) blue:(128/255.0) alpha:1.0];
        
        alphabet = [[NSArray alloc] initWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I",
                                                    @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R",
                                                    @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [foodTable reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    
    // Main View
    CGRect frame = [[UIScreen mainScreen] bounds];
    AddFoodView *view = [[AddFoodView alloc] initWithFrame:frame];
    [self setView:view];
    
    // Close Button
    CancelButton *closeButton = [[CancelButton alloc] init];
    [closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    
    // New Button
    RightHeaderButton *newButton = [[RightHeaderButton alloc] init];
    [newButton addTarget:self action:@selector(newFood:) forControlEvents:UIControlEventTouchUpInside];
    [newButton setTitle:@"New" forState:UIControlStateNormal];
    [self.view addSubview:newButton];
    
    // Title
    TitleLabel *title = [[TitleLabel alloc] init];
    [title setText:@"Food Catalog"];
    [self.view addSubview:title];
    
    /* Search Bar */
    // Background
    CGRect barFrame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
    searchBackground = [[UIView alloc] initWithFrame:barFrame];
    [searchBackground setBackgroundColor:darkerGray];
    [self.view addSubview:searchBackground];
    
    // Cancel Button
    CGRect cancelFrame = CGRectMake(barFrame.size.width - 80, 0, 75, 44);
    cancelButton = [[UIButton alloc] initWithFrame:cancelFrame];
    [cancelButton addTarget:self action:@selector(searchBarCancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:disabledEggWhite forState:UIControlStateDisabled];
    [cancelButton setTitleColor:eggWhite forState:UIControlStateNormal];
    [cancelButton setEnabled:NO];
    [cancelButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0]];
    [cancelButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [searchBackground addSubview:cancelButton];
    
    // Search Field
    CGRect searchBarFrame = CGRectMake(0, 0, barFrame.size.width - 75, barFrame.size.height);
    searchField = [[UISearchBar alloc] initWithFrame:searchBarFrame];
    [searchField setBarStyle:UIBarStyleDefault];
    [searchField setBarTintColor:darkerGray];
    [searchField setPositionAdjustment:UIOffsetZero forSearchBarIcon:UISearchBarIconSearch];
    searchField.delegate = self;
    [searchField setPlaceholder:@"Search Food"];
    [searchBackground addSubview:searchField];
    
    /* Food Catalog Table */
    CGRect tableFrame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - (44+64));
    foodTable = [[UITableView alloc] initWithFrame:tableFrame];
    [foodTable setDelegate:self];
    [foodTable setDataSource:self];
    [foodTable setBackgroundColor:eggWhite];
    [foodTable setSeparatorColor:[UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.25]];
    [self.view addSubview:foodTable];
    
    catalog = [[FoodStore sharedStore] getFoodCatalog];
}

#pragma mark -
#pragma mark UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 54.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    int letterIndex = ((NSNumber *)[sectionIndexes objectAtIndex:section]).intValue;
    NSString *title = [NSString stringWithFormat:@"%@", [alphabet objectAtIndex:letterIndex]];
    TableHeaderView *headerView = [[TableHeaderView alloc] initWithTitle:title];
    
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    sectionIndexes = [self getNumberOfSections];
    return sectionIndexes.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int foodCatalogSection = ((NSNumber *)[sectionIndexes objectAtIndex:section]).intValue;
    return [self getNumberOfFoodForSection:foodCatalogSection];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableCell *cell = [[TableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];

    int foodCatalogSection = ((NSNumber *)[sectionIndexes objectAtIndex:indexPath.section]).intValue;
    Food *f = [self getFoodForSection:foodCatalogSection andRow:(int)indexPath.row];
    [cell.textLabel setText:f.name];
    [cell setAccessoryView:[self viewForFoodGroups:f.foodGroups]];
    
    return cell;
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
                    [hex setFrame:CGRectMake(1, 1, 16, 19)];
                    [hex setImage:[UIImage imageNamed:@"hexCell_1"]];
                    break;
                case 1:
                    [hex setFrame:CGRectMake(17, 1, 16, 19)];
                    [hex setImage:[UIImage imageNamed:@"hexCell_2"]];
                    break;
                case 2:
                    [hex setFrame:CGRectMake(17, 10, 16, 19)];
                    [hex setImage:[UIImage imageNamed:@"hexCell_3"]];
                    break;
                case 3:
                    [hex setFrame:CGRectMake(17, 19, 16, 19)];
                    [hex setImage:[UIImage imageNamed:@"hexCell_4"]];
                    break;
                case 4:
                    [hex setFrame:CGRectMake(1, 19, 16, 19)];
                    [hex setImage:[UIImage imageNamed:@"hexCell_5"]];
                    break;
                case 5:
                    [hex setFrame:CGRectMake(1, 10, 16, 19)];
                    [hex setImage:[UIImage imageNamed:@"hexCell_6"]];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int foodCatalogSection = ((NSNumber *)[sectionIndexes objectAtIndex:indexPath.section]).intValue;
    Food *f = [self getFoodForSection:foodCatalogSection andRow:(int)indexPath.row];
    [f setMeal:meal];
    
    [[FoodStore sharedStore] addFood:f];
    
    [self close:nil];
}

#pragma mark -
#pragma mark UISearchBar

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [cancelButton setEnabled:YES];
    
    CGRect frame = foodTable.frame;
    frame.size.height -= KEYBOARD_OFFSET;
    
    CGRect barFrame = searchBackground.frame;
    barFrame.origin.y -= KEYBOARD_OFFSET;
    
    [UIView animateWithDuration:0.20 animations:^{
        [foodTable setFrame:frame];
        [searchBackground setFrame:barFrame];
    }];
    
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [cancelButton setEnabled:NO];
    
    CGRect frame = foodTable.frame;
    frame.size.height += KEYBOARD_OFFSET;
    
    CGRect barFrame = searchBackground.frame;
    barFrame.origin.y += KEYBOARD_OFFSET;
    
    [UIView animateWithDuration:0.21 animations:^{
        [foodTable setFrame:frame];
        [searchBackground setFrame:barFrame];
    }];
    
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""]) {
        catalog = [[FoodStore sharedStore] getFoodCatalog];
    }
    else {
        catalog = [[FoodStore sharedStore] filterCatalogWithSearch:searchText];
    }
    [foodTable reloadData];
}

- (void)searchBarCancelButtonClicked:(id)sender
{
    [searchField resignFirstResponder];
}

#pragma mark -
#pragma mark Getting Info From Catalog

- (NSArray *)getNumberOfSections
{
    NSMutableArray *sectionNumbers = [[NSMutableArray alloc] init];
    for (int i = 0; i < 26; i++) {
        NSMutableArray *section = [catalog objectAtIndex:i];
        if (section.count > 0) {
            [sectionNumbers addObject:[NSNumber numberWithInt:i]];
        }
    }
    return sectionNumbers;
}

- (int)getNumberOfFoodForSection:(int)section
{
    return (int)((NSMutableArray *)[catalog objectAtIndex:section]).count;
}

- (Food *)getFoodForSection:(int)section andRow:(int)row
{
    NSMutableArray *foodSection = (NSMutableArray *)[catalog objectAtIndex:section];
    return [foodSection objectAtIndex:row];
}

#pragma mark -
#pragma mark AlertView

- (void)userTappedCancel:(AlertView *)alertView
{
    [alertView removeFromSuperview];
}

- (void)userTappedOther:(AlertView *)alertView
{
    NSString *foodName = alertView.textField.text;
    NewFoodViewController *new_VC = [[NewFoodViewController alloc] init];
    [new_VC setFoodName:foodName];
    [self.navigationController pushViewController:new_VC animated:YES];
    
    [alertView removeFromSuperview];
}

#pragma mark -

- (void)setMeal:(int)mealNumber
{
    switch (mealNumber) {
        case 0:
            meal = @"Breakfast";
            break;
        case 1:
            meal = @"Lunch";
            break;
        case 2:
            meal = @"Dinner";
            break;
        case 3:
            meal = @"Snack";
            break;
    }
}

- (void)newFood:(id)sender
{
    AlertView *alert = [[AlertView alloc] init];
    [alert setTitle:@"Create New Food"];
    [alert setPlaceholder:@"Enter name of food"];
    [alert setOtherButtonTitle:@"Next"];
    [alert setDelegate:self];
    [self.view addSubview:alert];
}

- (void)close:(id)sender
{
    [self.navigationController popToViewController:parent_VC animated:YES];
}

@end
