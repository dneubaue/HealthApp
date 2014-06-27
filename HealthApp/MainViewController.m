//
//  MainViewController.m
//  HealthApp
//
//  Created by David Neubauer on 4/4/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"
#import "ActivityViewController.h"
#import "DietViewController.h"
#import "TaskViewController.h"
#import "SettingsViewController.h"
#import "AlertViewNoTextField.h"

#import "NewFoodViewController.h"
#import "HelpDietViewController.h"
#import "OverviewViewController.h"

#define SLIDE_TIMING .25
#define PANEL_WIDTH 80

@interface MainViewController () <SideViewControllerDelegate, AlertViewNoTextFieldDelegate>
{
    // Colors
    UIColor *eggWhite;
    UIColor *lighterWhite;
    UIColor *darkerGray;
    UIColor *lighterGray;
    UIColor *mint;
    
    // View Controllers
    NSArray *viewControllers;
    UINavigationController *nav_VC;
    OverviewViewController *overview_VC;
    ActivityViewController *activity_VC;
    DietViewController *diet_VC;
    TaskViewController *task_VC;
    SettingsViewController *settings_VC;
    
    UITableView *table;
    NSArray *headers;
    int activeNavSection;
}
@end

@implementation MainViewController
@synthesize delegate, showingNavMenu;

- (id)init
{
    self = [super init];
    if (self) {
        // Public Variable
        showingNavMenu = NO;
        
        // Private
        eggWhite = [UIColor colorWithRed:(218/255.0) green:(218/255.0) blue:(218/255.0) alpha:1.0];
        lighterWhite = [UIColor colorWithRed:(218/255.0) green:(218/255.0) blue:(218/255.0) alpha:0.5];
        darkerGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:1.0];
        lighterGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.7];
        mint = [UIColor colorWithRed:(63/255.0) green:(195/255.0) blue:(128/255.0) alpha:1.0];
        
        headers = [[NSArray alloc] initWithObjects:@"Overview", @"Activity", @"Diet", @"Tasks", @"Settings", @"Send a Suggestion", nil];
        activeNavSection = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Get View
    CGRect frame = [[UIScreen mainScreen] bounds];
    MainView *view = [[MainView alloc] initWithFrame:frame];
    [self setView:view];
    
    // Table for navigation
    CGRect tableFrame = CGRectMake(0, 64, self.view.frame.size.width, 54 * headers.count);
    table = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    [table setBackgroundColor:darkerGray];
    [table setSeparatorColor:lighterWhite];
    [table setDelegate:self];
    [table setDataSource:self];
    [self.view addSubview:table];
    
    // Overview View Controller
    overview_VC = [[OverviewViewController alloc] init];
    overview_VC.delegate = self;
    
    // Activity View Controller
    activity_VC = [[ActivityViewController alloc] init];
    activity_VC.delegate = self;
    
    // Diet View Controller
    diet_VC = [[DietViewController alloc] init];
    diet_VC.delegate = self;
    
    // Task View Controller
    task_VC = [[TaskViewController alloc] init];
    task_VC.delegate = self;
    
    // Settings View Controller
    settings_VC = [[SettingsViewController alloc] init];
    settings_VC.delegate = self;
    
    // Add View Controllers to array
    viewControllers = [[NSArray alloc] initWithObjects:overview_VC, activity_VC, diet_VC, task_VC, settings_VC, nil];
    
    // Navigation Controller
    nav_VC = [[UINavigationController alloc] init];
    [nav_VC setViewControllers:[NSArray arrayWithObject:overview_VC]];
    self.delegate = overview_VC;
    [self.view addSubview:nav_VC.view];
    [self addChildViewController:nav_VC];
    [nav_VC didMoveToParentViewController:self];
    
}

#pragma mark -
#pragma mark Showing and Hiding Navigation Menu

- (void)movePanel
{
    if (showingNavMenu)
        [self movePanelToOriginalPosition];
    else
        [self movePanelRight];
}

- (void)movePanelRight
{
    [table reloadData];
    
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         nav_VC.view.frame = CGRectMake(self.view.frame.size.width - PANEL_WIDTH, 0, self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             showingNavMenu = YES;
                         }
                     }];
}

- (void)movePanelToOriginalPosition
{
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         nav_VC.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             showingNavMenu = NO;
                         }
                     }];
}

#pragma mark -
#pragma mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger x = headers.count;
    return  x;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Create cell and edit appearance
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.textLabel setTextColor:eggWhite];
    [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:20.0]];
    if (indexPath.row == activeNavSection) {
        [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:22.0]];
    }
    [cell setBackgroundColor:darkerGray];
    
    // Set title of cell to corresponding section
    NSString *headerTitle = [headers objectAtIndex:indexPath.row];
    [cell.textLabel setText:headerTitle];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Check if user wants to email a suggestion
    if (indexPath.row == 5) {
        [self sendSuggestion];
        return;
    }
    
    if (activeNavSection == indexPath.row) {
        [self movePanelToOriginalPosition];
        [self.delegate userChoseOtherViewController];
        return;
    }
    
    UIViewController *viewController = [viewControllers objectAtIndex:indexPath.row];
    self.delegate = (id<MainViewControllerDelegate>)viewController;
    [self.delegate userChoseThisViewController];
    [nav_VC setViewControllers:[NSArray arrayWithObject:viewController]];
    activeNavSection = (int)indexPath.row;
    [self movePanelToOriginalPosition];
}

#pragma mark -
#pragma mark AlertViewDelegate

- (void)userTappedOkay:(AlertViewNoTextField *)alertView
{
    [alertView removeFromSuperview];
}


#pragma mark -

- (void)sendSuggestion
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mail_VC = [[MFMailComposeViewController alloc] init];
        
        [mail_VC setToRecipients:@[@"neubauer.dev@gmail.com"]];
        [mail_VC setSubject:@"MintCondition Suggestion"];
        NSString *messageBody = @"Please enter any bugs or new feature suggestions:\n\n";
        [mail_VC setMessageBody:messageBody isHTML:NO];
        mail_VC.mailComposeDelegate = self;
        
        [self presentViewController:mail_VC animated:YES completion:nil];
    } else {
        AlertViewNoTextField *alert = [[AlertViewNoTextField alloc] init];
        [alert setTitle:@"Mail cannot be loaded on your device."];
        alert.delegate = self;
        [self.view addSubview:alert];
    }
    
}

- (void)showMessageResult:(MFMailComposeResult)result
{
    NSString *title = @"";
    if (MFMailComposeResultSent) {
        title = @"Thanks you";
    } else {
        title = @"Message failed to send";
    }
    
    AlertViewNoTextField *alert = [[AlertViewNoTextField alloc] init];
    [alert setTitle:title];
    alert.delegate = self;
    [self.view addSubview:alert];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    if (result == MFMailComposeResultSent || result == MFMailComposeResultFailed) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self showMessageResult:result];
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
