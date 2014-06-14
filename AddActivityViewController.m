//
//  AddActivityViewController.m
//  HealthApp
//
//  Created by David Neubauer on 4/2/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "AddActivityViewController.h"
#import "AddActivityView.h"
#import "HelpActivityViewController.h"
#import "ActivityStore.h"
#import "TitleLabel.h"
#import "BackButton.h"
#import "RightHeaderButton.h"
#import "TableCell.h"
#import "UserDataStore.h"

@interface AddActivityViewController ()
{
    UIColor *eggWhite;
    UIColor *darkerGray;
    UIColor *lighterGray;
    UIColor *mint;
    
    NSArray *cellStrings;
    
    int netChangedActs;
}
@end

@implementation AddActivityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        eggWhite = [UIColor colorWithRed:(218/255.0) green:(218/255.0) blue:(218/255.0) alpha:1.0];
        darkerGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:1.0];
        lighterGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.5];
        mint = [UIColor colorWithRed:(63/255.0) green:(195/255.0) blue:(128/255.0) alpha:1.0];
        
        cellStrings = [NSArray arrayWithObjects:@"Everyday", @"Aerobic Exercise", @"Recreational Activities",
                                                @"Strength Training", @"Flexibility Training", nil];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    netChangedActs = 0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    
    // Get Main View
    CGRect frame = [[UIScreen mainScreen] bounds];
    UIView *view = [[AddActivityView alloc] initWithFrame:frame];
    [self setView:view];
    
    // Back Button
    BackButton *backButton = [[BackButton alloc] init];
    [backButton addTarget:self action:@selector(backToMainScreen:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:@"Save" forState:UIControlStateNormal];
    [self.view addSubview:backButton];
    
    // Title
    TitleLabel *title = [[TitleLabel alloc] init];
    [title setText:@"Add Activity"];
    [self.view addSubview:title];
    
    // Info text
    CGRect infoFrame = CGRectMake(36, 108, 248, 35);
    UILabel *info = [[UILabel alloc] initWithFrame:infoFrame];
    [info setText:@"Tap the activities you have done today"];
    [info setTextAlignment:NSTextAlignmentCenter];
    [info setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15]];
    [info setTextColor:mint];
    [self.view addSubview:info];
    
    // Table
    CGRect tableFrame = CGRectMake(0, 168, self.view.frame.size.width, 227);
    UITableView *table = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    [table setBackgroundColor:eggWhite];
    [table setSeparatorColor:[UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.25]];
    [table setScrollEnabled:NO];
    [table setDelegate:self];
    [table setDataSource:self];
    [self.view addSubview:table];
    
    // help Button
    RightHeaderButton *helpButton = [[RightHeaderButton alloc] init];
    [helpButton setTitle:@"Help" forState:UIControlStateNormal];
    [helpButton addTarget:self action:@selector(showHelpScreen:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:helpButton];
}

#pragma mark - 
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableCell *cell = [[TableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    [cell.textLabel setText:[cellStrings objectAtIndex:indexPath.row]];
    
    if ([[ActivityStore sharedStore] activityIsInToday:indexPath.row]) {
        [cell setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryView != nil) {
        [cell setAccessoryView:nil];
        [[ActivityStore sharedStore] removeActivityFromToday:indexPath.row];
        netChangedActs--;
    }
    else {
        [cell setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark"]]];
        [[ActivityStore sharedStore] addActivityToToday:indexPath.row];
        netChangedActs++;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -

- (void)backToMainScreen:(id)sender
{
    // Update user points
    [[UserDataStore sharedStore] addUserPoints:netChangedActs];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showHelpScreen:(id)sender
{
    HelpActivityViewController *helpAct_VC = [[HelpActivityViewController alloc] init];
    [self.navigationController pushViewController:helpAct_VC animated:YES];
}

@end
