//
//  HelpActivityViewController.m
//  HealthApp
//
//  Created by David Neubauer on 4/3/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "HelpActivityViewController.h"
#import "HelpActivityView.h"
#import "TitleLabel.h"
#import "BackButton.h"
#import "TableHeaderView.h"

@interface HelpActivityViewController ()
{
    UIColor *eggWhite;
    UIColor *darkerGray;
    UIColor *lighterGray;
    UIColor *mint;
    
    NSArray *cellStrings;
    NSArray *recommenedStrings;
    NSArray *exampleStrings;
}
@end

@implementation HelpActivityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        eggWhite = [UIColor colorWithRed:(218/255.0) green:(218/255.0) blue:(218/255.0) alpha:1.0];
        darkerGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:1.0];
        lighterGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.7];
        mint = [UIColor colorWithRed:(63/255.0) green:(195/255.0) blue:(128/255.0) alpha:1.0];
        
        cellStrings = [NSArray arrayWithObjects:@"Everyday", @"Aerobic", @"Recreational", @"Strength", @"Flexibility", nil];
        recommenedStrings = [NSArray arrayWithObjects:@"7", @"3-5", @"3-5", @"2-3", @"2-3", nil];
        exampleStrings = [NSArray arrayWithObjects:@"Walk pet, yard work, chores",
                                                   @"Swimming, running, cycling",
                                                   @"Basketball, Tennis, Hiking",
                                                   @"Weight Lifting",
                                                   @"Stretching, Yoga, Pilates", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    
    // Get Main View
    CGRect frame = [[UIScreen mainScreen] bounds];
    UIView *view = [[HelpActivityView alloc] initWithFrame:frame];
    [self setView:view];
    
    // Title
    TitleLabel *title = [[TitleLabel alloc] init];
    [title setText:@"Activity Help"];
    [self.view addSubview:title];
    
    // Back Button
    BackButton *backButton = [[BackButton alloc] init];
    [backButton addTarget:self action:@selector(backToAddScreen:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    // Table
    CGRect tableFrame = CGRectMake(0, 64, self.view.frame.size.width, 504);
    UITableView *table = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
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
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = [cellStrings objectAtIndex:section];
    TableHeaderView *headerView = [[TableHeaderView alloc] initWithTitle:title];
//    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240, 65)];
//    [view setBackgroundColor:eggWhite];
//    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 240, 65)];
//    [view addSubview:headerLabel];
//    
//    [headerLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:24.0]];
//    [headerLabel setTextColor:mint];
//    [headerLabel setText:[cellStrings objectAtIndex:section]];
    
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    if (indexPath.row == 0) {
        NSString *days = [recommenedStrings objectAtIndex:indexPath.section];
        [cell.textLabel setText:[NSString stringWithFormat:@"Recomended %@ Days a Week", days]];
    }
    else {
        NSString *examples = [exampleStrings objectAtIndex:indexPath.section];
        [cell.textLabel setText:[NSString stringWithFormat:@"e.g., %@", examples]];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.textLabel setTextColor:darkerGray];
    [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0]];
    [cell setBackgroundColor:eggWhite];
    
    return cell;
}

#pragma mark -

- (void)backToAddScreen:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
