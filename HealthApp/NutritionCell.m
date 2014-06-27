//
//  NutritonCell.m
//  HealthApp
//
//  Created by David Neubauer on 4/5/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "NutritionCell.h"
#import "FoodStore.h"
#import "UserSettingsStore.h"

@interface NutritionCell ()
{
    UIColor *eggWhite;
    UIColor *eggWhiteClear;
    UIColor *darkerGray;
    UIColor *lighterGray;
    UIColor *mint;
    
    UIColor *fruitColor;
    UIColor *grainColor;
    UIColor *proteinColor;
    UIColor *veggieColor;
    UIColor *dairyColor;
    
    UIView *colorView;
    UILabel *titleLabel;
    UILabel *percentTotal;
    UILabel *totalLabel;
    UILabel *percentGoal;
    UILabel *goalLabel;
}
@end

@implementation NutritionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        eggWhite = [UIColor colorWithRed:(218/255.0) green:(218/255.0) blue:(218/255.0) alpha:1.0];
        darkerGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:1.0];
        lighterGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.7];
        mint = [UIColor colorWithRed:(63/255.0) green:(195/255.0) blue:(128/255.0) alpha:1.0];
        
        fruitColor = [UIColor colorWithRed:(225/255.0) green:(130/255.0) blue:(132/255.0) alpha:1.0];
        grainColor = [UIColor colorWithRed:(255/255.0) green:(199/255.0) blue:(107/255.0) alpha:1.0];
        proteinColor = [UIColor colorWithRed:(180/255.0) green:(138/255.0) blue:(215/255.0) alpha:1.0];
        veggieColor = [UIColor colorWithRed:(162/255.0) green:(214/255.0) blue:(127/255.0) alpha:1.0];
        dairyColor = [UIColor colorWithRed:(136/255.0) green:(197/255.0) blue:(239/255.0) alpha:1.0];
        
        colorView = [[UIView alloc] initWithFrame:CGRectMake(10, 8, 18, 18)];
        [colorView.layer setCornerRadius: 5];
        [self addSubview:colorView];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, 0, 160, 34)];
        [titleLabel setTextAlignment:NSTextAlignmentLeft];
        [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:24.0]];
        [titleLabel setTextColor:darkerGray];
        [self addSubview:titleLabel];
        
        percentTotal = [[UILabel alloc] initWithFrame:CGRectMake(204, 0, 56, 34)];
        [percentTotal setTextAlignment:NSTextAlignmentCenter];
        [percentTotal setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0]];
        [percentTotal setTextColor:darkerGray];
        [self addSubview:percentTotal];
        
//        totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(204, 23, 56, 9)];
//        [totalLabel setTextAlignment:NSTextAlignmentCenter];
//        [totalLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:9.0]];
//        [totalLabel setTextColor:darkerGray];
//        [totalLabel setText:@"% Total"];
//        [self addSubview:totalLabel];
        
        percentGoal = [[UILabel alloc] initWithFrame:CGRectMake(260, 0, 56, 34)];
        [percentGoal setTextAlignment:NSTextAlignmentCenter];
        [percentGoal setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0]];
        [percentGoal setTextColor:lighterGray];
        [self addSubview:percentGoal];
        
//        goalLabel = [[UILabel alloc] initWithFrame:CGRectMake(260, 23, 56, 9)];
//        [goalLabel setTextAlignment:NSTextAlignmentCenter];
//        [goalLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:9.0]];
//        [goalLabel setTextColor:darkerGray];
//        [goalLabel setText:@"% Goal"];
//        [self addSubview:goalLabel];
    }
    return self;
}

- (void)setFoodGroup:(int)foodGroup
{
    // Get total number of servings
    NSArray *foodServings = [[FoodStore sharedStore] getFoodLevels];
    int size = (int)foodServings.count;
    CGFloat totalServings = 0;
    for (int i = 0; i < size; i++) {
        NSNumber *number = [foodServings objectAtIndex:i];
        totalServings += number.floatValue;
    }
    
    int goal = [[UserSettingsStore sharedStore] goalForFoodGroup:foodGroup];
    
    int percent;
    switch (foodGroup) {
        case 0:
            [colorView setBackgroundColor:proteinColor];
            [titleLabel setText:@"Protein"];
            percent = [[FoodStore sharedStore] getProteinPercent];
            [percentTotal setText:[NSString stringWithFormat:@"%d", percent]];
            
            [percentGoal setText:[NSString stringWithFormat:@"%d", goal]];
            break;
        case 1:
            [colorView setBackgroundColor:fruitColor];
            [titleLabel setText:@"Fruit"];
            percent = [[FoodStore sharedStore] getFruitPercent];
            [percentTotal setText:[NSString stringWithFormat:@"%d", percent]];
            
            [percentGoal setText:[NSString stringWithFormat:@"%d", goal]];
            break;
        case 2:
            [colorView setBackgroundColor:grainColor];
            [titleLabel setText:@"Grain"];
            percent = [[FoodStore sharedStore] getGrainPercent];
            [percentTotal setText:[NSString stringWithFormat:@"%d", percent]];
            
            [percentGoal setText:[NSString stringWithFormat:@"%d", goal]];
            break;
        case 3:
            [colorView setBackgroundColor:dairyColor];
            [titleLabel setText:@"Dairy"];
            percent = [[FoodStore sharedStore] getDairyPercent];
            [percentTotal setText:[NSString stringWithFormat:@"%d", percent]];
            
            [percentGoal setText:[NSString stringWithFormat:@"%d", goal]];
            break;
        case 4:
            [colorView setBackgroundColor:veggieColor];
            [titleLabel setText:@"Veggie"];
            percent = [[FoodStore sharedStore] getVeggiePercent];
            [percentTotal setText:[NSString stringWithFormat:@"%d", percent]];
            
            [percentGoal setText:[NSString stringWithFormat:@"%d", goal]];
            break;
        case 5:
            [colorView setBackgroundColor:darkerGray];
            [titleLabel setText:@"Junk"];
            percent = [[FoodStore sharedStore] getJunkPercent];
            [percentTotal setText:[NSString stringWithFormat:@"%d", percent]];
            
            [percentGoal setText:[NSString stringWithFormat:@"%d", goal]];
            break;
    }
}

@end
