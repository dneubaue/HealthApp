//
//  SettingsViewController.m
//  HealthApp
//
//  Created by David Neubauer on 6/15/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SettingsViewController.h"
#import "SettingsView.h"
#import "UserSettingsStore.h"
#import "AlertViewNoTextField.h"

#import "TitleLabel.h"
#import "NavigationButton.h"
#import "RightHeaderButton.h"
#import "TableCell.h"
#import "TableHeaderView.h"

#define KEYBOARD_HEIGHT 216

@interface SettingsViewController ()
{
    // Colors
    UIColor *eggWhite;
    UIColor *disabledGray;
    UIColor *darkerGray;
    UIColor *lighterGray;
    UIColor *mint;
    
    BOOL shouldCloseNavButton;
    NavigationButton *navButton;
    UITableView *settingsTable;
    NSArray *dietHeaders;
    NSMutableArray *dietTextFields;
    CGFloat TABLE_HEIGHT;
}
@end

@implementation SettingsViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        eggWhite = [UIColor colorWithRed:(218/255.0) green:(218/255.0) blue:(218/255.0) alpha:1.0];
        darkerGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:1.0];
        lighterGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.7];
        mint = [UIColor colorWithRed:(63/255.0) green:(195/255.0) blue:(128/255.0) alpha:1.0];
        
        dietHeaders = [[NSMutableArray alloc] initWithObjects:@"Protein", @"Fruit", @"Grains", @"Dairy", @"Veggie", @"Junk", nil];
        dietTextFields = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (shouldCloseNavButton) {
        [navButton toggleRotation];
        shouldCloseNavButton = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    // Main View
    CGRect frame = [[UIScreen mainScreen] bounds];
    SettingsView *view = [[SettingsView alloc] initWithFrame:frame];
    [self setView:view];
    
    // Nav Button
    navButton = [[NavigationButton alloc] init];
    [navButton addTarget:self action:@selector(showSidePanel:) forControlEvents:UIControlEventTouchUpInside];
    if (shouldCloseNavButton) {
        [navButton moveToOpen]; // Open nav, so animating to close it happens when view appears
    }
    [self.view addSubview:navButton];
    
    // Save button
    RightHeaderButton *editButton = [[RightHeaderButton alloc] init];
    [editButton setTitle:@"Edit" forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(toggleEditSettings:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editButton];
    
    // Title
    TitleLabel *title = [[TitleLabel alloc] init];
    [title setText:@"Settings"];
    [self.view addSubview:title];
    
    // Table
    TABLE_HEIGHT = 318;//frame.size.height-title.frame.size.height;
    CGRect tableFrame = CGRectMake(0, 64, 320, TABLE_HEIGHT);
    settingsTable = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    [settingsTable setBackgroundColor:eggWhite];
    [settingsTable setSeparatorColor:[UIColor colorWithRed:(70/255.0)
                                                     green:(70/255.0)
                                                      blue:(70/255.0)
                                                     alpha:0.25]];
    [settingsTable setDelegate:self];
    [settingsTable setDataSource:self];
    [self.view addSubview:settingsTable];
}

#pragma mark -
#pragma mark UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 54;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = @"Food Group Goals";
    TableHeaderView *headerView = [[TableHeaderView alloc] initWithTitle:title];
    
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableCell *cell = [[TableCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    
    cell.textLabel.text = [dietHeaders objectAtIndex:indexPath.row];
    
    int percent = [[UserSettingsStore sharedStore] goalForFoodGroup:(int)indexPath.row];
    NSString *percentString = [NSString stringWithFormat:@"%d%%", percent];
    if (indexPath.row + 1 > dietTextFields.count) {
        cell.accessoryView = [self textFieldAccessoryWithPlaceHolder:percentString
                                                              andRow:indexPath.row];
    } else {
        UITextField *field = [dietTextFields objectAtIndex:indexPath.row];
        field.text = percentString;
        cell.accessoryView = field;
    }
    
    return cell;
}

#pragma mark -
#pragma mark UITextField

- (UITextField *)textFieldAccessoryWithPlaceHolder:(NSString *)text andRow:(NSUInteger)row
{
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    field.backgroundColor = [UIColor clearColor];
    field.textColor = lighterGray;
    field.tintColor = mint;
    field.enabled = NO;
    
    [field setBorderStyle:UITextBorderStyleNone];
    field.layer.masksToBounds = YES;
    field.layer.borderColor = darkerGray.CGColor;
    
    [field setTextAlignment:NSTextAlignmentRight];
    [field setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0]];
    [field setText:text];
    field.delegate = self;
    field.tag = row + 1;
    
    [dietTextFields addObject:field];
    
    return field;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField selectAll:textField];
    
    CGRect frame = settingsTable.frame;
    CGFloat bottomOfTable = frame.origin.y + frame.size.height;
    CGFloat topOfKeyboard = self.view.frame.size.height - KEYBOARD_HEIGHT;
    if (bottomOfTable <= topOfKeyboard) {
        return;
    }
    frame.size.height -= (bottomOfTable - topOfKeyboard);
    [UIView animateWithDuration:0.20
                     animations:^{
                         [settingsTable setFrame:frame];
                     }
                     completion:^(BOOL finished) {
                     }
     ];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect frame = settingsTable.frame;
    if (frame.size.height == TABLE_HEIGHT) {
        return;
    }
    frame.size.height = TABLE_HEIGHT;
    [UIView animateWithDuration:0.20
                     animations:^{
                         [settingsTable setFrame:frame];
                     }
                     completion:^(BOOL finished) {
                     }
     ];
    
    NSString *text = @"";
    if ([textField.text hasSuffix:@"%"]) {
        text = [textField.text substringToIndex:textField.text.length-1];
    } else {
        text = textField.text;
    }
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:0];
    NSNumber *percent = [numberFormatter numberFromString:text];
    
    if (percent.intValue > 100) {
        textField.text = @"0%";
        
        AlertViewNoTextField *alert = [[AlertViewNoTextField alloc] init];
        [alert setTitle:@"Invalid Percent!"];
        [alert setDelegate:self];
        [self.view addSubview:alert];
    } else {
        textField.text = [NSString stringWithFormat:@"%d%%", percent.intValue];
    }
}

/* May use in the future **
- (void)checkAllTextFields
{
    int percentLeft = 100;
    for (int i = 0; i < dietTextFields.count; i++) {
        UITextField *textField = [dietTextFields objectAtIndex:i];
        if (percentLeft > 0) {
            NSString *str = [textField.text substringToIndex:textField.text.length-1];
            
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            [numberFormatter setMaximumFractionDigits:0];
            NSNumber *percent = [numberFormatter numberFromString:str];
            
            percentLeft -= percent.intValue;
            if (percentLeft < 0) {
                textField.text = [NSString stringWithFormat:@"%d%%", percent.intValue + percentLeft];
                
                [[UserSettingsStore sharedStore] setGoal:percent.intValue + percentLeft
                                                forGroup:i];
                
                percentLeft = 0;
            } else if (i == dietTextFields.count-1 && percentLeft > 0) {
                textField.text = [NSString stringWithFormat:@"%d%%", percentLeft + percent.intValue];
                
                [[UserSettingsStore sharedStore] setGoal:percent.intValue + percentLeft
                                                forGroup:i];
            } else {
                [[UserSettingsStore sharedStore] setGoal:percent.intValue
                                                forGroup:i];
            }
                
        } else {
            textField.text = @"0%";
            [[UserSettingsStore sharedStore] setGoal:0
                                            forGroup:i];
        }
    }
}
*/

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -

#pragma mark AlertView

- (void)userTappedOkay:(AlertViewNoTextField *)alertView
{
    [alertView removeFromSuperview];
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

- (void)showSidePanel:(id)sender
{
    [delegate movePanel];
    [navButton toggleRotation];
}

- (void)toggleEditSettings:(RightHeaderButton *)button
{
    if (button.tag == 0) {
        for (int i = 0; i < dietTextFields.count; i++) {
            UITextField *textField = [dietTextFields objectAtIndex:i];
            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.textColor = darkerGray;
            textField.enabled = YES;
        }
        [button setTitle:@"Save" forState:UIControlStateNormal];
        button.tag = 1;
        
    } else if ([self saveSettings:button]) {
        for (int i = 0; i < dietTextFields.count; i++) {
            UITextField *textField = [dietTextFields objectAtIndex:i];
            textField.enabled = NO;
            textField.borderStyle = UITextBorderStyleNone;
            textField.textColor = lighterGray;
        }
        [button setTitle:@"Edit" forState:UIControlStateNormal];
        button.tag = 0;
    }
    
}

// Validates that the percentages of food group goals
//  accumulate to 100
- (BOOL)saveSettings:(id)sender
{
    int percentages[6] = {0, 0, 0, 0, 0, 0};
    int total = 0;
    for (int i = 0; i < dietTextFields.count; i++) {
        UITextField *textField = [dietTextFields objectAtIndex:i];
        [textField resignFirstResponder];
        NSString *str = [textField.text substringToIndex:textField.text.length-1];
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [numberFormatter setMaximumFractionDigits:0];
        NSNumber *percent = [numberFormatter numberFromString:str];
        
        percentages[i] = percent.intValue;
        total += percentages[i];
    }
    
    if (total != 100) {
        AlertViewNoTextField *alert = [[AlertViewNoTextField alloc] init];
        [alert setTitle:@"Goals must add to 100!"];
        alert.delegate = self;
        [self.view addSubview:alert];
        
        return NO;
    } else {
        for (int i = 0; i < dietTextFields.count; i++) {
            UITextField *textField = [dietTextFields objectAtIndex:i];
            textField.borderStyle = UITextBorderStyleRoundedRect;
            
            [[UserSettingsStore sharedStore] setGoal:percentages[i] forGroup:i];
        }
        return YES;
    }
}

@end
