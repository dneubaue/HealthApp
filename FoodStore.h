//
//  FoodStore.h
//  HealthApp
//
//  Created by David Neubauer on 4/5/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Food;

@interface FoodStore : NSObject
{
    int glassesOfWater;
    NSDate *today;
}
@property (strong, nonatomic) NSDate *today;
@property int glassesOfWater;


+ (FoodStore *)sharedStore;
- (BOOL)saveChanges;
- (void)addFood:(Food *)food;
- (void)deleteFoodNumber:(int)foodNumber andMeal:(int)mealNumber;
- (int)numberOfMeals;
- (NSString *)nameOfMeal:(int)mealNumber;
- (int)numberOfFoodInMeal:(int)mealNumber;
- (NSMutableArray *)getFoodDiary;
- (Food *)foodNumber:(int)foodNumber fromMeal:(int)mealNumber;

- (NSArray *)getFoodLevels;
- (CGFloat)getTotalServings;
- (CGFloat)getFruitLevel;
- (CGFloat)getGrainLevel;
- (CGFloat)getProteinLevel;
- (CGFloat)getVeggieLevel;
- (CGFloat)getDairyLevel;
- (CGFloat)getJunkLevel;

- (int)getGlassesOfWater;

- (CGFloat)getFruitPercent;
- (CGFloat)getGrainPercent;
- (CGFloat)getProteinPercent;
- (CGFloat)getVeggiePercent;
- (CGFloat)getDairyPercent;
- (CGFloat)getJunkPercent;

- (void)resetData;
- (int)compareDate:(NSDate *)date1 toDate:(NSDate *)date2;

- (int)dietPointsForDay:(int)day;
- (int)totalDietPointsThisWeek;
- (void)tallyTodaysDietPoints;

- (NSArray *)getFoodCatalog;
- (NSArray *)filterCatalogWithSearch:(NSString *)substring;
- (NSArray *)copyOfFoodCatalog;
- (void)addFoodToCatalog:(Food *)food;
- (void)deleteFoodFromCatalog:(Food *)food;
//- (NSArray *)getNumberOfSections;
//- (int)getNumberOfFoodForSection:(int)section;
//- (Food *)getFoodForSection:(int)section andRow:(int)row;

@end
