//
//  AddTaskViewController.m
//  HealthApp
//
//  Created by David Neubauer on 4/4/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "AddTaskViewController.h"
#import "TaskAddView.h"
#import "TaskStore.h"
#import "Task.h"
#import "TitleLabel.h"
#import "TableCell.h"
#import "CancelButton.h"

#define HEADER_HEIGHT 10

@interface AddTaskViewController ()
{
    Task *task;
    
    UIColor *eggWhite;
    UIColor *darkerGray;
    UIColor *lighterGray;
    UIColor *mint;
    
    NSArray *daysOfWeek;
    UITableView *table;
}
@end

@implementation AddTaskViewController

- (id)initWithTask:(Task *)t
{
    self = [super init];
    if (self) {
        task = t;
        
        eggWhite = [UIColor colorWithRed:(218/255.0) green:(218/255.0) blue:(218/255.0) alpha:1.0];
        darkerGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:1.0];
        lighterGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.7];
        mint = [UIColor colorWithRed:(63/255.0) green:(195/255.0) blue:(128/255.0) alpha:1.0];
        
        daysOfWeek = [[NSArray alloc] initWithObjects:@"Sunday", @"Monday", @"Tuesday",
                                                      @"Wednesday", @"Thursday", @"Friday",
                                                      @"Saturday", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];

    // Main View
    CGRect frame = [[UIScreen mainScreen] bounds];
    TaskAddView *view = [[TaskAddView alloc] initWithFrame:frame];
    [self setView:view];
    
    // Back Button
    CancelButton *backButton = [[CancelButton alloc] initWithFrame:CGRectMake(6, 20, 44, 44)];
    [backButton addTarget:self action:@selector(closeTask:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];

    
    // Title
    TitleLabel *title = [[TitleLabel alloc] init];
    [title setText:@"Pick Day"];
    [self.view addSubview:title];

    // Table
    int height = 308 + (2*HEADER_HEIGHT);
    int y = (self.view.frame.size.height - height) / 2.0;
    CGRect tableFrame = CGRectMake(0, y, self.view.frame.size.width, height);
    table = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    [table setBackgroundColor:eggWhite];
    [table setSeparatorColor:lighterGray];
    [table setScrollEnabled:NO];
    [table setDelegate:self];
    [table setDataSource:self];
    [self.view addSubview:table];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int today = (int)[[[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:[NSDate date]] weekday];
    return (today == 1)? 1 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int today = (int)[[[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:[NSDate date]] weekday];
    if (section == 0)
        return 7 - (today-1);
    else
        return today-1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    if (section == 0) {
        [view setBackgroundColor:eggWhite];
    } else {
        [view setBackgroundColor:eggWhite];
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableCell *cell = [[TableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    
    if (indexPath.row == 0 && indexPath.section == 0) {
        [cell.textLabel setText:@"Today"];
        [cell.textLabel setTextColor:mint];
        [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:22.0]];
        return cell;
    }
    else if (indexPath.row == 1 && indexPath.section == 0) {
        [cell.textLabel setText:@"Tomorrow"];
        return cell;
    }
    
    int today = (int)[[[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:[NSDate date]] weekday];
    int row = today + (int)indexPath.row;
    if (indexPath.section == 1) {
        row  = (int)indexPath.row + 1;
    }
    
    NSString *dayString = [daysOfWeek objectAtIndex:row-1];
    [cell.textLabel setText:dayString];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int today = (int)[[[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:[NSDate date]] weekday];
    int oneDay = 86400; // 86400 Seconds in a day
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark_accessory"]]];
    
    if (indexPath.section == 0) {
        task.date = [[NSDate date] dateByAddingTimeInterval:((int)indexPath.row * oneDay)];
    }
    // Next week
    else {
        int numberOfDaysAfterToday = ((7-today)+1) + (int)indexPath.row;
        task.date = [[NSDate date] dateByAddingTimeInterval:(numberOfDaysAfterToday*oneDay)];
    }
    [[TaskStore sharedStore] addTask:task];
    [self closeTask:nil];
}

#pragma mark -

- (void)closeTask:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
