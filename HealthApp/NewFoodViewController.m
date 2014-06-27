//
//  AddDietViewController.m
//  HealthApp
//
//  Created by David Neubauer on 4/5/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "NewFoodViewController.h"
#import "DietMainView.h"
#import "HelpDietViewController.h"
#import "FoodStore.h"
#import "Food.h"

#import "TitleLabel.h"
#import "CancelButton.h"
#import "RightHeaderButton.h"
#import "AlertView.h"
#import "AlertViewNoTextField.h"

#define HEX_SEPARATION 5
#define KEYBOARD_OFFSET 175

@interface NewFoodViewController () <AlertViewDelegate, AlertViewNoTextFieldDelegate>
{
    UIColor *eggWhite;
    UIColor *disabledEggWhite;
    UIColor *eggWhiteClear;
    UIColor *darkerGray;
    UIColor *lighterGray;
    UIColor *mint;
    
    UIView *movablePanel;
    
    CGPoint touchLocation;
    
    UILabel *saveLabel;
    
    UIImageView *fruitImage;
    UIImageView *grainImage;
    UIImageView *dairyImage;
    UIImageView *veggieImage;
    UIImageView *junkImage;
    UIImageView *proteinImage;
    
    UILabel *fruitLabel;
    UILabel *grainsLabel;
    UILabel *dairyLabel;
    UILabel *veggieLabel;
    UILabel *junkLabel;
    UILabel *proteinLabel;
    
    UITextField *nameField;
    UITextField *mealField;
    NSMutableArray *foodGroupAmounts;
    int foodGroups;
    
    UITableView *mealPicker;
    
    BOOL mealPickerShowing;
    
    NSString *nameOfMeal;
    NSString *nameOfFood;
    
    UIButton *saveButton;
    
    NSArray *foodGroupHeaders;
}
@end

@implementation NewFoodViewController

- (id)init
{
    self = [super init];
    if (self) {
        eggWhite = [UIColor colorWithRed:(218/255.0) green:(218/255.0) blue:(218/255.0) alpha:1.0];
        disabledEggWhite = [UIColor colorWithRed:(218/255.0) green:(218/255.0) blue:(218/255.0) alpha:0.5];
        eggWhiteClear = [UIColor colorWithRed:(218/255.0) green:(218/255.0) blue:(218/255.0) alpha:0.8];
        darkerGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:1.0];
        lighterGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.7];
        mint = [UIColor colorWithRed:(63/255.0) green:(195/255.0) blue:(128/255.0) alpha:1.0];
        
        touchLocation = CGPointMake(0, 0);

        foodGroups = 0x0;
        
        foodGroupAmounts = [[NSMutableArray alloc]
                             initWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.0],
                             [NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.0],
                             [NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.0], nil];
        nameOfMeal = @"";
        
        foodGroupHeaders = [[NSArray alloc] initWithObjects:@"Protein", @"Fruit", @"Grains", @"Dairy", @"Veggie", @"Junk", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    
    // Main View
    CGRect frame = [[UIScreen mainScreen] bounds];
    DietMainView *view = [[DietMainView alloc] initWithFrame:frame];
    [self setView:view];
    
    // NAV
    UIView *navBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    [navBackground setBackgroundColor:eggWhiteClear];
    [self.view addSubview:navBackground];
    
    // Back Button
    CancelButton *backButton = [[CancelButton alloc] init];
    [backButton addTarget:self action:@selector(closeFood:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    // help Button
    RightHeaderButton *helpButton = [[RightHeaderButton alloc] init];
    [helpButton setTitle:@"Help" forState:UIControlStateNormal];
    [helpButton addTarget:self action:@selector(showHelpScreen:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:helpButton];
    
    
    // Title
    TitleLabel *title = [[TitleLabel alloc] init];
    [title setText:@"Food Groups"];
    [self.view addSubview:title];
    
    // Movable Panel has everything but nav bar stuff
    movablePanel = [[UIView alloc] initWithFrame:CGRectMake(0, 64, frame.size.width, frame.size.height-64)];
    [movablePanel setBackgroundColor:eggWhite];
    [self.view addSubview:movablePanel];
    
    // Info
    CGRect infoFrame = CGRectMake(36, 4, 248, 56);
    UILabel *info = [[UILabel alloc] initWithFrame:infoFrame];
    [info setText:@"Tap to add a food group"];
    [info setTextAlignment:NSTextAlignmentCenter];
    [info setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0]];
    [info setTextColor:darkerGray];
    [movablePanel addSubview:info];
    
    // Food Group Hex
    [self setUpFoodHex];
    
    // Save
    CGRect helpFrame = CGRectMake(0, frame.size.height-44, self.view.frame.size.width, 44);
    
    UIView *helpBackground = [[UIView alloc] initWithFrame:helpFrame];
    [helpBackground setBackgroundColor:darkerGray];
    [self.view addSubview:helpBackground];

    saveButton = [[UIButton alloc] initWithFrame:CGRectMake(260, 0, 60, 44)];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveFood:) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setTitleColor:disabledEggWhite forState:UIControlStateDisabled];
    [saveButton setTitleColor:eggWhite forState:UIControlStateNormal];
    [saveButton setEnabled:NO];
    [saveButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0]];
    [saveButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [helpBackground addSubview:saveButton];
    
    saveLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 250, 44)];
    [saveLabel setText:@""];
    [saveLabel setTextAlignment:NSTextAlignmentLeft];
    [saveLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15]];
    [saveLabel setTextColor:eggWhite];
    [helpBackground addSubview:saveLabel];
}

- (void)setUpFoodHex
{
    // Fruit
    fruitImage = [[UIImageView alloc] initWithFrame:CGRectMake(68, 68, 92, 107)];
    [fruitImage setImage:[UIImage imageNamed:@"hex_1"]];
    [movablePanel addSubview:fruitImage];
    
    fruitLabel = [[UILabel alloc] initWithFrame:CGRectMake(54, 72, 106, 20)];
    [fruitLabel setTextColor:darkerGray];
    [fruitLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:14.0]];
    [fruitLabel setTextAlignment:NSTextAlignmentCenter];
    [fruitLabel setTransform:CGAffineTransformMakeRotation(11*M_PI / 6.0)];
    [fruitLabel setText:@"Fruit"];
    [movablePanel addSubview:fruitLabel];
    
    // Grains
    grainImage = [[UIImageView alloc] initWithFrame:CGRectMake(160, 68, 92, 107)];
    [grainImage setImage:[UIImage imageNamed:@"hex_2"]];
    [movablePanel addSubview:grainImage];
    
    grainsLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 72, 106, 20)];
    [grainsLabel setTextColor:darkerGray];
    [grainsLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:14.0]];
    [grainsLabel setTextAlignment:NSTextAlignmentCenter];
    [grainsLabel setTransform:CGAffineTransformMakeRotation(M_PI / 6.0)];
    [grainsLabel setText:@"Grains"];
    [movablePanel addSubview:grainsLabel];
    
    
    // Dairy
    dairyImage = [[UIImageView alloc] initWithFrame:CGRectMake(160, 121, 92, 107)];
    [dairyImage setImage:[UIImage imageNamed:@"hex_3"]];
    [movablePanel addSubview:dairyImage];
    
    dairyLabel = [[UILabel alloc] initWithFrame:CGRectMake(246, 164, 64, 20)];
    [dairyLabel setTextColor:darkerGray];
    [dairyLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:14.0]];
    [dairyLabel setTextAlignment:NSTextAlignmentCenter];
    [dairyLabel setText:@"Dairy"];
    [movablePanel addSubview:dairyLabel];
    
    // Veggie
    veggieImage = [[UIImageView alloc] initWithFrame:CGRectMake(160, 174, 92, 107)];
    [veggieImage setImage:[UIImage imageNamed:@"hex_4"]];
    [movablePanel addSubview:veggieImage];
    
    veggieLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 257, 106, 20)];
    [veggieLabel setTextColor:darkerGray];
    [veggieLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:14.0]];
    [veggieLabel setTextAlignment:NSTextAlignmentCenter];
    [veggieLabel setTransform:CGAffineTransformMakeRotation(11*M_PI / 6.0)];
    [veggieLabel setText:@"Veggie"];
    [movablePanel addSubview:veggieLabel];
    
    
    // Junk
    junkImage = [[UIImageView alloc] initWithFrame:CGRectMake(68, 174, 92, 107)];
    [junkImage setImage:[UIImage imageNamed:@"hex_5"]];
    [movablePanel addSubview:junkImage];
    
    junkLabel = [[UILabel alloc] initWithFrame:CGRectMake(54, 257, 106, 20)];
    [junkLabel setTextColor:darkerGray];
    [junkLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:14.0]];
    [junkLabel setTextAlignment:NSTextAlignmentCenter];
    [junkLabel setTransform:CGAffineTransformMakeRotation(M_PI / 6.0)];
    [junkLabel setText:@"Junk"];
    [movablePanel addSubview:junkLabel];
    
    
    // Protein
    proteinImage = [[UIImageView alloc] initWithFrame:CGRectMake(68, 121, 92, 107)];
    [proteinImage setImage:[UIImage imageNamed:@"hex_6"]];
    [movablePanel addSubview:proteinImage];
    
    proteinLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 164, 64, 20)];
    [proteinLabel setTextColor:darkerGray];
    [proteinLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:14.0]];
    [proteinLabel setTextAlignment:NSTextAlignmentCenter];
    [proteinLabel setText:@"Protein"];
    [movablePanel addSubview:proteinLabel];
    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(44 , 58, 276-44, 291-58)];
//    [view setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:0.5]];
//    [movablePanel addSubview:view];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Don't log touches if the user is typing
    CGFloat bottomOfView = movablePanel.frame.origin.y + movablePanel.frame.size.height;
    if (bottomOfView != self.view.frame.size.height) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    touchLocation = [touch locationInView:self.view];
    
    if (touchLocation.x >= 44 && touchLocation.x <= 276) {
        if (touchLocation.y >= 122 && touchLocation.y <= 355) {
            [self addFoodGroup:touchLocation];
        }
    }
}

- (void)addFoodGroup:(CGPoint)touch
{
    CGPoint p1 = CGPointMake(68 , 185);
    CGPoint p2 = CGPointMake(160, 132);
    CGPoint p3 = CGPointMake(252, 185);
    CGPoint p4 = CGPointMake(252, 292);
    CGPoint p5 = CGPointMake(160, 345);
    CGPoint p6 = CGPointMake(68 , 292);
    
    BOOL leftOfVertical = [self point:touch onLeftSideOfLineFromPoint:p2 toPoint:p5];
    BOOL aboveNegSlope2 = [self point:touch onLeftSideOfLineFromPoint:p4 toPoint:p1];
    BOOL abovePosSlope2 = [self point:touch onLeftSideOfLineFromPoint:p3 toPoint:p6];
    
    BOOL fruit   =  leftOfVertical &&  aboveNegSlope2;
    BOOL grains  = !leftOfVertical &&  abovePosSlope2;
    BOOL dairy   =  aboveNegSlope2 &&  !abovePosSlope2;
    BOOL veggie  = !leftOfVertical && !aboveNegSlope2;
    BOOL junk    =  leftOfVertical && !abovePosSlope2;
    BOOL protein = !aboveNegSlope2 &&  abovePosSlope2;
    
    if (protein) {
        if (foodGroups & 0x20) {
            CGRect frame = proteinImage.frame;
            [proteinImage setFrame:CGRectMake(frame.origin.x + 2*HEX_SEPARATION, frame.origin.y,
                                              frame.size.width, frame.size.height)];
            CGPoint center = proteinLabel.center;
            [proteinLabel setCenter:CGPointMake(center.x + 2*HEX_SEPARATION, center.y)];
            
            foodGroups = foodGroups & 0x1F;
            [self removeServingsOfGroup:@"Protein"];
        } else {
            CGRect frame = proteinImage.frame;
            [proteinImage setFrame:CGRectMake(frame.origin.x - 2*HEX_SEPARATION, frame.origin.y,
                                              frame.size.width, frame.size.height)];
            CGPoint center = proteinLabel.center;
            [proteinLabel setCenter:CGPointMake(center.x - 2*HEX_SEPARATION, center.y)];
            
            foodGroups = foodGroups | 0x20;
            [self askForServingsOfGroup:0];
        }
    }
    else if (fruit) {
        if (foodGroups & 0x1) {
            CGRect frame = fruitImage.frame;
            [fruitImage setFrame:CGRectMake(frame.origin.x + HEX_SEPARATION, frame.origin.y + 2*HEX_SEPARATION,
                                            frame.size.width, frame.size.height)];
            CGPoint center = fruitLabel.center;
            [fruitLabel setCenter:CGPointMake(center.x + HEX_SEPARATION, center.y + 2*HEX_SEPARATION)];
            
            foodGroups = foodGroups & 0x3E;
            [self removeServingsOfGroup:@"Fruit"];
        } else {
            CGRect frame = fruitImage.frame;
            [fruitImage setFrame:CGRectMake(frame.origin.x - HEX_SEPARATION, frame.origin.y - 2*HEX_SEPARATION,
                                        frame.size.width, frame.size.height)];
            CGPoint center = fruitLabel.center;
            [fruitLabel setCenter:CGPointMake(center.x - HEX_SEPARATION, center.y - 2*HEX_SEPARATION)];
            
            foodGroups = foodGroups | 0x1;
            [self askForServingsOfGroup:1];
        }
    }
    else if (grains) {
        if (foodGroups & 0x2) {
            CGRect frame = grainImage.frame;
            [grainImage setFrame:CGRectMake(frame.origin.x - HEX_SEPARATION, frame.origin.y + 2*HEX_SEPARATION,
                                            frame.size.width, frame.size.height)];
            CGPoint center = grainsLabel.center;
            [grainsLabel setCenter:CGPointMake(center.x - HEX_SEPARATION, center.y + 2*HEX_SEPARATION)];
            
            foodGroups = foodGroups & 0x3D;
            [self removeServingsOfGroup:@"Grains"];
        } else {
            CGRect frame = grainImage.frame;
            [grainImage setFrame:CGRectMake(frame.origin.x + HEX_SEPARATION, frame.origin.y - 2*HEX_SEPARATION,
                                            frame.size.width, frame.size.height)];
            CGPoint center = grainsLabel.center;
            [grainsLabel setCenter:CGPointMake(center.x + HEX_SEPARATION, center.y - 2*HEX_SEPARATION)];
            
            foodGroups = foodGroups | 0x2;
            [self askForServingsOfGroup:2];
        }
    }
    else if (dairy) {
        if (foodGroups & 0x4) {
            CGRect frame = dairyImage.frame;
            [dairyImage setFrame:CGRectMake(frame.origin.x - 2*HEX_SEPARATION, frame.origin.y,
                                            frame.size.width, frame.size.height)];
            CGPoint center = dairyLabel.center;
            [dairyLabel setCenter:CGPointMake(center.x - 2*HEX_SEPARATION, center.y)];
            
            foodGroups = foodGroups & 0x3B;
            [self removeServingsOfGroup:@"Dairy"];
        } else {
            CGRect frame = dairyImage.frame;
            [dairyImage setFrame:CGRectMake(frame.origin.x + 2*HEX_SEPARATION, frame.origin.y,
                                            frame.size.width, frame.size.height)];
            CGPoint center = dairyLabel.center;
            [dairyLabel setCenter:CGPointMake(center.x + 2*HEX_SEPARATION, center.y)];
            
            foodGroups = foodGroups | 0x4;
            [self askForServingsOfGroup:3];
        }
    }
    else if (veggie) {
        if (foodGroups & 0x8) {
            CGRect frame = veggieImage.frame;
            [veggieImage setFrame:CGRectMake(frame.origin.x - HEX_SEPARATION, frame.origin.y - 2*HEX_SEPARATION,
                                             frame.size.width, frame.size.height)];
            CGPoint center = veggieLabel.center;
            [veggieLabel setCenter:CGPointMake(center.x - 2*HEX_SEPARATION, center.y - 2*HEX_SEPARATION)];
            
            foodGroups = foodGroups & 0x37;
            [self removeServingsOfGroup:@"Veggie"];
        } else {
            CGRect frame = veggieImage.frame;
            [veggieImage setFrame:CGRectMake(frame.origin.x + HEX_SEPARATION, frame.origin.y + 2*HEX_SEPARATION,
                                             frame.size.width, frame.size.height)];
            CGPoint center = veggieLabel.center;
            [veggieLabel setCenter:CGPointMake(center.x + 2*HEX_SEPARATION, center.y + 2*HEX_SEPARATION)];
            
            foodGroups = foodGroups | 0x8;
            [self askForServingsOfGroup:4];
        }
    }
    else if (junk) {
        if (foodGroups & 0x10) {
            CGRect frame = junkImage.frame;
            [junkImage setFrame:CGRectMake(frame.origin.x + HEX_SEPARATION, frame.origin.y - 2*HEX_SEPARATION,
                                           frame.size.width, frame.size.height)];
            CGPoint center = junkLabel.center;
            [junkLabel setCenter:CGPointMake(center.x + 2*HEX_SEPARATION, center.y - 2*HEX_SEPARATION)];
            
            foodGroups = foodGroups & 0x2F;
            [self removeServingsOfGroup:@"Junk"];
        } else {
            CGRect frame = junkImage.frame;
            [junkImage setFrame:CGRectMake(frame.origin.x - HEX_SEPARATION, frame.origin.y + 2*HEX_SEPARATION,
                                           frame.size.width, frame.size.height)];
            CGPoint center = junkLabel.center;
            [junkLabel setCenter:CGPointMake(center.x - 2*HEX_SEPARATION, center.y + 2*HEX_SEPARATION)];
            
            foodGroups = foodGroups | 0x10;
            [self askForServingsOfGroup:5];
        }
    }
}

- (BOOL)point:(CGPoint)touch onLeftSideOfLineFromPoint:(CGPoint)p1 toPoint:(CGPoint)p2
{
    return ((p2.x - p1.x)*(touch.y - p1.y) - (p2.y - p1.y)*(touch.x - p1.x)) > 0;
}

#pragma mark -
#pragma mark AlertView

- (void)userTappedCancel:(AlertView *)alertView
{
    [self cancelFoodGroup:[foodGroupHeaders objectAtIndex:alertView.tag]];
    [alertView removeFromSuperview];
}

- (void)userTappedOkay:(AlertViewNoTextField *)alertView
{
    [alertView removeFromSuperview];
    
    [self askForServingsOfGroup:(int)alertView.tag];
}

- (void)userTappedOther:(AlertView *)alertView
{
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *numberOfServings = [f numberFromString:alertView.textField.text];
    // Check that number was entered
    if (numberOfServings == nil) {
//        [self cancelFoodGroup:[foodGroupHeaders objectAtIndex:alertView.tag]];
        [self servingsInputError:(int)alertView.tag];
    }
    else if (numberOfServings.floatValue <= 0) {
        [self cancelFoodGroup:[foodGroupHeaders objectAtIndex:alertView.tag]];
    }
    else if (numberOfServings.intValue > 99) {
//        [self cancelFoodGroup:[foodGroupHeaders objectAtIndex:alertView.tag]];
        [self tooManyServingsError:(int)alertView.tag];
    }
    else {
        [foodGroupAmounts replaceObjectAtIndex:alertView.tag withObject:numberOfServings];
        [self updateSaveLabel];
    }
    
    [alertView removeFromSuperview];
}
    

#pragma mark -
#pragma mark UIPickerView

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 4;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = @"";
    switch (row) {
        case 0:
            title = @"Breakfast";
            break;
        case 1:
            title = @"Lunch";
            break;
        case 2:
            title = @"Dinner";
            break;
        case 3:
            title = @"Snack";
            break;
    }
    return title;
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    CGRect frame = movablePanel.frame;
    frame.origin.y += KEYBOARD_OFFSET;
    
    [UIView animateWithDuration:0.20 animations:^{[movablePanel setFrame:frame];}];

    
    return NO;
}

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField == mealField && !mealPickerShowing)
    {
        mealPickerShowing = YES;
        [nameField resignFirstResponder];
        [mealField resignFirstResponder];
        [self showMealPicker];
        return YES;
    }
    else if (textField == nameField) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Food Name"
                                                        message:@"Enter Name of Food"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Okay", nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField *textField = [alert textFieldAtIndex:0];
        [textField setKeyboardType:UIKeyboardTypeAlphabet];
        [textField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
        [textField setText:nameField.text];
        [alert show];
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField.placeholder isEqualToString:@"Enter name of meal"]) {
        [textField resignFirstResponder];
//        [self showMealPicker];
    }
    CGFloat bottomOfView = movablePanel.frame.origin.y + movablePanel.frame.size.height;
    if (bottomOfView == self.view.frame.size.height) {
        CGRect frame = movablePanel.frame;
        frame.origin.y -= KEYBOARD_OFFSET;
        
        [UIView animateWithDuration:0.28 animations:^{[movablePanel setFrame:frame];}];
    }
}

#pragma mark -
#pragma mark UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [view setBackgroundColor:eggWhite];
    
    UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    [topBar setBackgroundColor:darkerGray];
    [view addSubview:topBar];
    
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 1)];
    [bottomBar setBackgroundColor:darkerGray];
    [view addSubview:bottomBar];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 320, 44)];
    [view addSubview:headerLabel];
    [headerLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:24.0]];
    [headerLabel setTextColor:darkerGray];
    [headerLabel setText:@"Choose Meal:"];
    
    return view;
}

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
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.textLabel setTextColor:darkerGray];
    [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:18.0]];
    [cell setBackgroundColor:eggWhite];
    
    NSString *title = @"";
    switch (indexPath.row) {
        case 0:
            title = @"Breakfast";
            break;
        case 1:
            title = @"Lunch";
            break;
        case 2:
            title = @"Dinner";
            break;
        case 3:
            title = @"Snack";
            break;
    }
    
    if ([mealField.text isEqualToString:title]) {
        [cell setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark_accessory"]]];
    }
    [cell.textLabel setText:title];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *meal = @"";
    switch (indexPath.row) {
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
    
    [mealField setText:meal];
    
    CGRect pickerFrame =  mealPicker.frame;
    pickerFrame.origin.y += mealPicker.frame.size.height;
    
    CGRect panelFrame = movablePanel.frame;
    panelFrame.origin.y += KEYBOARD_OFFSET;
    
    [UIView animateWithDuration:0.20
                     animations:^{
                         [mealPicker setFrame:pickerFrame];
                         [movablePanel setFrame:panelFrame];
                     }
                     completion:^(BOOL finished) {
                         [mealPicker removeFromSuperview];
                         mealPicker = NULL;
                         mealPickerShowing = NO;
                     }
    ];
}

#pragma mark -

- (void)saveFood:(id)sender
{
    if (foodGroups == 0) {
        AlertViewNoTextField *alert = [[AlertViewNoTextField alloc] init];
        [alert setTitle:@"No Food Groups Given!"];
        [alert setDelegate:self];
        [self.view addSubview:alert];
    }
    else {
        Food *f = [[Food alloc] init];
        f.name = nameOfFood;
        f.foodGroups = foodGroupAmounts;
        
        [[FoodStore sharedStore] addFoodToCatalog:f];
        [self closeFood:sender];
    }

}

- (void)closeFood:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showHelpScreen:(id)sender
{
    HelpDietViewController *help_VC = [[HelpDietViewController alloc] init];
    [self.navigationController pushViewController:help_VC animated:YES];
}

- (void)showMealPicker
{
    CGRect frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 220);
    mealPicker = [[UITableView alloc] initWithFrame:frame
                                                           style:UITableViewStylePlain];
    [mealPicker setScrollEnabled:NO];
    [mealPicker setBackgroundColor:eggWhite];
    [mealPicker setSeparatorColor:lighterGray];
    [mealPicker setDelegate:self];
    [mealPicker setDataSource:self];
    [self.view addSubview:mealPicker];
    
    CGRect newFrame = CGRectMake(0, self.view.frame.size.height - frame.size.height,
                                 frame.size.width, frame.size.height);
    [UIView animateWithDuration:0.28 animations:^{[mealPicker setFrame:newFrame];}];
}

- (void)askForServingsOfGroup:(int)foodGroupIndex
{
    AlertView *alert = [[AlertView alloc] init];
    NSString *group = [foodGroupHeaders objectAtIndex:foodGroupIndex];
    [alert setTitle:[NSString stringWithFormat:@"Add %@ to Food", group]];
    [alert setKeyboardType:UIKeyboardTypeDecimalPad];
    [alert setPlaceholder:@"Enter number of servings"];
    [alert setOtherButtonTitle:@"Add"];
    [alert setDelegate:self];
    [alert setTag:foodGroupIndex];
    [self.view addSubview:alert];
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@", group]
//                                                    message:@"Enter Number of Servings"
//                                                   delegate:self
//                                          cancelButtonTitle:@"Cancel"
//                                          otherButtonTitles:@"Add", nil];
//    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
//    UITextField *textField = [alert textFieldAtIndex:0];
//    [textField setKeyboardType:UIKeyboardTypeDecimalPad];
//    [alert show];
}

- (void)removeServingsOfGroup:(NSString *)group
{
    NSNumber *zero = [NSNumber numberWithInt:0];
    
    
    if ([group isEqualToString:@"Protein"]) {
        [foodGroupAmounts replaceObjectAtIndex:0 withObject:zero];
    }
    else if ([group isEqualToString:@"Fruit"]) {
        [foodGroupAmounts replaceObjectAtIndex:1 withObject:zero];
    }
    else if ([group isEqualToString:@"Grains"]) {
        [foodGroupAmounts replaceObjectAtIndex:2 withObject:zero];
    }
    else if ([group isEqualToString:@"Dairy"]) {
        [foodGroupAmounts replaceObjectAtIndex:3 withObject:zero];
    }
    else if ([group isEqualToString:@"Veggie"]) {
        [foodGroupAmounts replaceObjectAtIndex:4 withObject:zero];
    }
    else if ([group isEqualToString:@"Junk"]) {
        [foodGroupAmounts replaceObjectAtIndex:5 withObject:zero];
    }
    [self updateSaveLabel];
}

- (void)updateSaveLabel
{
    NSString *text = @"";
    for (int i = 0; i < 6; i++) {
//        int number = roundf(((NSNumber *)[foodGroupAmounts objectAtIndex:i]).floatValue);
        float number = ((NSNumber *)[foodGroupAmounts objectAtIndex:i]).floatValue;
        if (number == 0)
            continue;
        if (![text isEqualToString:@""]) {
            text = [text stringByAppendingString:@", "];
        }
        if (number == (int)number) {
            switch (i) {
                case 0:
                    text = [text stringByAppendingString:[NSString stringWithFormat:@"%d Protein", (int)number]];
                    break;
                case 1:
                    text = [text stringByAppendingString:[NSString stringWithFormat:@"%d Fruit", (int)number]];
                    break;
                case 2:
                    text = [text stringByAppendingString:[NSString stringWithFormat:@"%d Grains", (int)number]];
                    break;
                case 3:
                    text = [text stringByAppendingString:[NSString stringWithFormat:@"%d Dairy", (int)number]];
                    break;
                case 4:
                    text = [text stringByAppendingString:[NSString stringWithFormat:@"%d Veggie", (int)number]];
                    break;
                case 5:
                    text = [text stringByAppendingString:[NSString stringWithFormat:@"%d Junk", (int)number]];
                    break;
            }
        }
        else {
            switch (i) {
                case 0:
                    text = [text stringByAppendingString:[NSString stringWithFormat:@"%.2f Fruit", number]];
                    break;
                case 1:
                    text = [text stringByAppendingString:[NSString stringWithFormat:@"%.2f Grains", number]];
                    break;
                case 2:
                    text = [text stringByAppendingString:[NSString stringWithFormat:@"%.2f Dairy", number]];
                    break;
                case 3:
                    text = [text stringByAppendingString:[NSString stringWithFormat:@"%.2f Veggie", number]];
                    break;
                case 4:
                    text = [text stringByAppendingString:[NSString stringWithFormat:@"%.2f Junk", number]];
                    break;
                case 5:
                    text = [text stringByAppendingString:[NSString stringWithFormat:@"%.2f Protein", number]];
                    break;
            }
        }
    }
    if ([text isEqualToString:@""]) {
        [saveButton setEnabled:NO];
    }
    else {
        [saveButton setEnabled:YES];
    }
    
    [saveLabel setText:text];
}

- (void)setMealName:(NSString *)mealName
{
    nameOfMeal = mealName;
}

- (void)setFoodName:(NSString *)name
{
    nameOfFood = name;
}

- (void)cancelFoodGroup:(NSString *)foodGroup
{
    if ([foodGroup isEqualToString:@"Fruit"]) {
        CGRect frame = fruitImage.frame;
        [fruitImage setFrame:CGRectMake(frame.origin.x + HEX_SEPARATION, frame.origin.y + 2*HEX_SEPARATION,
                                        frame.size.width, frame.size.height)];
        CGPoint center = fruitLabel.center;
        [fruitLabel setCenter:CGPointMake(center.x + HEX_SEPARATION, center.y + 2*HEX_SEPARATION)];
        
        foodGroups = foodGroups & 0x3E;
    }
    else if ([foodGroup isEqualToString:@"Grains"]) {
        CGRect frame = grainImage.frame;
        [grainImage setFrame:CGRectMake(frame.origin.x - HEX_SEPARATION, frame.origin.y + 2*HEX_SEPARATION,
                                        frame.size.width, frame.size.height)];
        CGPoint center = grainsLabel.center;
        [grainsLabel setCenter:CGPointMake(center.x - HEX_SEPARATION, center.y + 2*HEX_SEPARATION)];
        
        foodGroups = foodGroups & 0x3D;
    }
    else if ([foodGroup isEqualToString:@"Dairy"]) {
        CGRect frame = dairyImage.frame;
        [dairyImage setFrame:CGRectMake(frame.origin.x - 2*HEX_SEPARATION, frame.origin.y,
                                        frame.size.width, frame.size.height)];
        CGPoint center = dairyLabel.center;
        [dairyLabel setCenter:CGPointMake(center.x - 2*HEX_SEPARATION, center.y)];
        
        foodGroups = foodGroups & 0x3B;
    }
    else if ([foodGroup isEqualToString:@"Veggie"]) {
        CGRect frame = veggieImage.frame;
        [veggieImage setFrame:CGRectMake(frame.origin.x - HEX_SEPARATION, frame.origin.y - 2*HEX_SEPARATION,
                                         frame.size.width, frame.size.height)];
        CGPoint center = veggieLabel.center;
        [veggieLabel setCenter:CGPointMake(center.x - HEX_SEPARATION, center.y - 2*HEX_SEPARATION)];
        
        foodGroups = foodGroups & 0x37;
    }
    else if ([foodGroup isEqualToString:@"Junk"]) {
        CGRect frame = junkImage.frame;
        [junkImage setFrame:CGRectMake(frame.origin.x + HEX_SEPARATION, frame.origin.y - 2*HEX_SEPARATION,
                                       frame.size.width, frame.size.height)];
        CGPoint center = junkLabel.center;
        [junkLabel setCenter:CGPointMake(center.x + HEX_SEPARATION, center.y - 2*HEX_SEPARATION)];
        
        foodGroups = foodGroups & 0x2F;
    }
    else if ([foodGroup isEqualToString:@"Protein"]) {
        CGRect frame = proteinImage.frame;
        [proteinImage setFrame:CGRectMake(frame.origin.x + 2*HEX_SEPARATION, frame.origin.y,
                                          frame.size.width, frame.size.height)];
        CGPoint center = proteinLabel.center;
        [proteinLabel setCenter:CGPointMake(center.x + HEX_SEPARATION, center.y)];
        
        foodGroups = foodGroups & 0x1F;
    }
    else {
        return;
    }
    
    [self removeServingsOfGroup:foodGroup];
}

- (void)servingsInputError:(int)group
{
    AlertViewNoTextField *alert = [[AlertViewNoTextField alloc] init];
    [alert setTitle:@"Couldn't Read Number!"];
    [alert setDelegate:self];
    [alert setTag:group];
    [self.view addSubview:alert];
}

- (void)tooManyServingsError:(int)group
{
    AlertViewNoTextField *alert = [[AlertViewNoTextField alloc] init];
    [alert setTitle:@"Too Many Servings!"];
    [alert setDelegate:self];
    [alert setTag:group];
    [self.view addSubview:alert];
}

@end
