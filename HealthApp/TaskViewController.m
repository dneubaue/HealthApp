//
//  TaskViewController.m
//  HealthApp
//
//  Created by David Neubauer on 4/4/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "TaskViewController.h"
#import "TaskMainView.h"
#import "TaskStore.h"
#import "AddTaskViewController.h"
#import "Task.h"
#import "SwipeableCell.h"
#import "TitleLabel.h"
#import "NavigationButton.h"
#import "PlusButton.h"
#import "TableHeaderView.h"
#import "TableCell.h"
#import "AlertView.h"
#import "UserDataStore.h"

@interface TaskViewController () <SwipeableCellDelegate, AlertViewDelegate>
{
    UIColor *eggWhite;
    UIColor *darkerGray;
    UIColor *lighterGray;
    UIColor *mint;
    
    UITableView *table;
    
    NSArray *headerTitles;
    NSMutableArray *todayTasks;
    NSMutableArray *tomorrowTasks;
    NSMutableArray *laterTasks;
    BOOL noTasksToday;
    BOOL noTasksTomorrow;
    BOOL noTasksLater;
    
    Task *task;
    
    NavigationButton *navButton;
    BOOL shouldCloseNavButton;
}
@end

@implementation TaskViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        eggWhite = [UIColor colorWithRed:(218/255.0) green:(218/255.0) blue:(218/255.0) alpha:1.0];
        darkerGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:1.0];
        lighterGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.7];
        mint = [UIColor colorWithRed:(63/255.0) green:(195/255.0) blue:(128/255.0) alpha:1.0];
        
        headerTitles = [[NSArray alloc] initWithObjects:@"Today", @"Tomorrow", @"Later", nil];
        todayTasks = [[NSMutableArray alloc] init];
        tomorrowTasks = [[NSMutableArray alloc] init];
        laterTasks = [[NSMutableArray alloc] init];
        noTasksToday = NO;
        noTasksTomorrow = NO;
        noTasksLater = NO;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (shouldCloseNavButton) {
        [navButton toggleRotation];
        shouldCloseNavButton = NO;
    }
    
    [[TaskStore sharedStore] reset];
    [table reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    
    // Main View
    CGRect frame = [[UIScreen mainScreen] bounds];
    TaskMainView *view = [[TaskMainView alloc] initWithFrame:frame];
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
    [addButton addTarget:self action:@selector(addTask:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addButton];
    
    // Title
    TitleLabel *title = [[TitleLabel alloc] init];
    [title setText:@"Tasks"];
    [self.view addSubview:title];
    
    // Table
    CGRect tableFrame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64);
    table = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    [table setBackgroundColor:eggWhite];
    [table setSeparatorColor:[UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.25]];
    [table setDelegate:self];
    [table setDataSource:self];
    [self.view addSubview:table];

}

#pragma mark -
#pragma mark UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 54.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = [headerTitles objectAtIndex:section];
    TableHeaderView *headerView = [[TableHeaderView alloc] initWithTitle:title];
    
    UIButton *button = [[UIButton alloc] init];
    CGRect frame = headerView.frame;
    frame.origin = CGPointMake(0, 0);
    [button setFrame:frame];
    [button addTarget:self action:@selector(addTask:) forControlEvents:UIControlEventTouchUpInside];
    [button setTag:section+1];
    [headerView addSubview:button];
    
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3; // Today, Tomorrow, and Later
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [[TaskStore sharedStore] populateTaskLists];
    
    if (section == 0) {
        todayTasks = [[TaskStore sharedStore] tasksForDay:0];
        return todayTasks.count;
    }
    else if (section == 1) {
        tomorrowTasks = [[TaskStore sharedStore] tasksForDay:1];
        return tomorrowTasks.count;
    }
    else {
        laterTasks = [[TaskStore sharedStore] tasksForDay:2];
        return laterTasks.count;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SwipeableCell *cell = [[SwipeableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    [cell setDelegate:self];
    
    // Cell Text
    Task *t;
    if (indexPath.section == 0 && todayTasks.count != 0) {
        t = [todayTasks objectAtIndex:indexPath.row];
        [cell.detailTextLabel setText:@""];
    } else if (indexPath.section == 1 && tomorrowTasks.count != 0) {
        t = [tomorrowTasks objectAtIndex:indexPath.row];
        [cell.detailTextLabel setText:@""];
    } else if (indexPath.section == 2 && laterTasks.count != 0) {
        t = [laterTasks objectAtIndex:indexPath.row];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE"];
        NSString *weekday = [dateFormatter stringFromDate:t.date];
        [cell.detailTextLabel setText:weekday];
    }
    
    cell.textLabel.text = t.description;
    
    return cell;
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
//                                            forRowAtIndexPath:(NSIndexPath *)indexPath
//{
////    if (editingStyle == UITableViewCellEditingStyleDelete) {
////        UITableViewCell *cellToDelete = [tableView cellForRowAtIndexPath:indexPath];
////        NSString *taskDescription = cellToDelete.textLabel.text;
////        [[TaskStore sharedStore] deleteTaskWithDescription:taskDescription andDay:(int)indexPath.section];
////        
////        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
////                         withRowAnimation:UITableViewRowAnimationFade];
////    }
//}

#pragma mark -
#pragma mark UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Create Task
        task = [[Task alloc] init];
        task.description = [alertView textFieldAtIndex:0].text;
        
        if (alertView.tag == 1 || alertView.tag == 2) {
            NSDate *date;
            int oneDay = 86400; // 86400 Seconds in a day
            if (alertView.tag == 1) {
                date = [NSDate date];
            }
            else if (alertView.tag == 2) {
                date = [[NSDate date] dateByAddingTimeInterval:oneDay];
            }
            task.date = date;
            [[TaskStore sharedStore] addTask:task];
            [table reloadData];
        }
        else {
            // Next part
            AddTaskViewController *addTask_VC = [[AddTaskViewController alloc] initWithTask:task];
            [self.navigationController pushViewController:addTask_VC animated:YES];
        }
    }
}

#pragma mark -
#pragma mark SwipeableCellDelegate

- (void)taskCompleted:(SwipeableCell *)cell
{
    NSIndexPath *indexPath = [table indexPathForCell:cell];
    
    UITableViewCell *cellToDelete = [table cellForRowAtIndexPath:indexPath];
    NSString *taskDescription = cellToDelete.textLabel.text;
    [[TaskStore sharedStore] completeTaskWithDescription:taskDescription andDay:(int)indexPath.section];
    
    [table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                 withRowAnimation:UITableViewRowAnimationFade];
}

- (void)deleteTask:(SwipeableCell *)cell
{
    NSIndexPath *indexPath = [table indexPathForCell:cell];
    
    UITableViewCell *cellToDelete = [table cellForRowAtIndexPath:indexPath];
    NSString *taskDescription = cellToDelete.textLabel.text;
    [[TaskStore sharedStore] deleteTaskWithDescription:taskDescription andDay:(int)indexPath.section];
    
    [table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                     withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark -
#pragma mark AlertViewDelegate

- (void)addTask:(id)sender
{
    UIButton *button = (UIButton *)sender;
    int tag = (int)button.tag;
    AlertView *alert = [[AlertView alloc] init];
    if (tag == 1) {
        NSString *string = @"New Task for Today";
        [alert setTitle:string];
        [alert setOtherButtonTitle:@"Add"];
    }
    else if (tag == 2) {
        NSString *string = @"New Task for Tomorrow";
        [alert setTitle:string];
        [alert setOtherButtonTitle:@"Add"];
    }
    else {
        NSString *string = @"New Task";
        [alert setTitle:string];
        [alert setOtherButtonTitle:@"Next"];
    }
    [alert setPlaceholder:@"Enter task name..."];
    [alert setDelegate:self];
    alert.tag = tag;
    [self.view addSubview:alert];
}

- (void)userTappedCancel:(AlertView *)alertView
{
    [alertView removeFromSuperview];
}

- (void)userTappedOther:(AlertView *)alertView
{
    // Create Task
    task = [[Task alloc] init];
    task.description = alertView.textField.text;
    
    if (alertView.tag == 1 || alertView.tag == 2) {
        NSDate *date;
        int oneDay = 86400; // 86400 Seconds in a day
        if (alertView.tag == 1) {
            date = [NSDate date];
        }
        else if (alertView.tag == 2) {
            date = [[NSDate date] dateByAddingTimeInterval:oneDay];
        }
        task.date = date;
        [[TaskStore sharedStore] addTask:task];
        [table reloadData];
    }
    else {
        // Next part
        AddTaskViewController *addTask_VC = [[AddTaskViewController alloc] initWithTask:task];
        [self.navigationController pushViewController:addTask_VC animated:YES];
    }
    
    [alertView removeFromSuperview];
}

#pragma mark -
#pragma mark SideViewControllerDelegate

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
