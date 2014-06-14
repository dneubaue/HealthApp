//
//  FoodStore.m
//  HealthApp
//
//  Created by David Neubauer on 4/5/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "FoodStore.h"
#import "Food.h"
#import "UserDataStore.h"
#import "UserSettingsStore.h"

@interface FoodStore ()
{
    NSMutableArray *foodCatalog;
    
    NSMutableArray *foodDiary;  // Meal1, Meal2, ... ; Meal1 - food1, food2, ...
    NSMutableArray *groupLevels;
    NSMutableArray *dailyScores;
    
    NSDate *dateToReset;
}
@end

@implementation FoodStore
@synthesize today, glassesOfWater;

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

+ (FoodStore *)sharedStore
{
    static FoodStore *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:NULL] init];
    }

    return sharedStore;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Catalog
        NSString *path = [self catalogArchivePath];
        foodCatalog = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (!foodCatalog) {
            foodCatalog = [[NSMutableArray alloc] init];
            for (int i = 0; i < 26; i++) {
                NSMutableArray *letterSection = [[NSMutableArray alloc] init];
                [foodCatalog addObject:letterSection];
            }
        }
        
        // Diary
        path = [self diaryArchivePath];
        foodDiary = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        if (!foodDiary) {
            foodDiary = [[NSMutableArray alloc] init];
            for (int i = 0;i < 4; i++) {
                NSMutableArray *array = [[NSMutableArray alloc] init];
                [foodDiary addObject:array];
            }
        }
        
        // Today's Levels
        path = [self levelsArchivePath];
        groupLevels = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (!groupLevels) {
            groupLevels = [[NSMutableArray alloc] // Fruit, Grains, Dairy, Veggie, Junk, Protein, Water, # servings
                           initWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithInt:0], [NSNumber numberWithFloat:0.0], nil];
        }
        glassesOfWater = ((NSNumber *)[groupLevels objectAtIndex:6]).intValue;
        
        // Today
        path = [self todayArchivePath];
        today = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        // Scores
        path = [self scoresPath];
        dailyScores = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (!dailyScores) {
            dailyScores = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:0],
                                                                  [NSNumber numberWithInt:0], [NSNumber numberWithInt:0],
                                                                  [NSNumber numberWithInt:0], [NSNumber numberWithInt:0],
                                                                  [NSNumber numberWithInt:0], nil];
            NSDate *date = [[NSDate date] dateByAddingTimeInterval:-86400];
            [dailyScores addObject:date];
            
        }
        dateToReset = [dailyScores objectAtIndex:7];
    }
    return self;
}

- (BOOL)saveChanges
{
    NSString *path = [self diaryArchivePath];
    BOOL save = [NSKeyedArchiver archiveRootObject:foodDiary toFile:path];
    
    path = [self levelsArchivePath];
    [groupLevels replaceObjectAtIndex:6 withObject:[NSNumber numberWithInt:glassesOfWater]];
    save = save & [NSKeyedArchiver archiveRootObject:groupLevels toFile:path];
    
    path = [self catalogArchivePath];
    save = save & [NSKeyedArchiver archiveRootObject:foodCatalog toFile:path];
    
    path = [self todayArchivePath];
    save = save & [NSKeyedArchiver archiveRootObject:today toFile:path];
    
    path = [self scoresPath];
    save = save & [NSKeyedArchiver archiveRootObject:dailyScores toFile:path];
    
    return save;
}

#pragma mark -
#pragma mark Archive Paths

- (NSString *)diaryArchivePath
{
    NSArray *docDirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                           NSUserDomainMask,
                                                           YES);
    NSString *docDir = [docDirs objectAtIndex:0];
    return [docDir stringByAppendingPathComponent:@"foodDiary.Archive"];
}

- (NSString *)catalogArchivePath
{
    NSArray *docDirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                           NSUserDomainMask,
                                                           YES);
    NSString *docDir = [docDirs objectAtIndex:0];
    return [docDir stringByAppendingPathComponent:@"foodCatalog.Archive"];
}

- (NSString *)levelsArchivePath
{
    NSArray *docDirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                           NSUserDomainMask,
                                                           YES);
    NSString *docDir = [docDirs objectAtIndex:0];
    return [docDir stringByAppendingPathComponent:@"levels.Archive"];
}

- (NSString *)todayArchivePath
{
    NSArray *docDirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                           NSUserDomainMask,
                                                           YES);
    NSString *docDir = [docDirs objectAtIndex:0];
    return [docDir stringByAppendingPathComponent:@"today.Archive"];
}

- (NSString *)scoresPath
{
    NSArray *docDirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                           NSUserDomainMask,
                                                           YES);
    NSString *docDir = [docDirs objectAtIndex:0];
    return [docDir stringByAppendingPathComponent:@"scores.Archive"];
}

#pragma mark -

- (void)addFood:(Food *)food
{
    int index = 3;
    if ([food.meal isEqualToString:@"Breakfast"]) {
        index = 0;
    }
    else if ([food.meal isEqualToString:@"Lunch"]) {
        index = 1;
    }
    else if ([food.meal isEqualToString:@"Dinner"]) {
        index = 2;
    }
    
    NSMutableArray *mealArray = [foodDiary objectAtIndex:index];
    [mealArray addObject:food];
    [self incrementFoodGroups:food.foodGroups];
}

- (void)incrementFoodGroups:(NSArray *)foodGroups
{
    CGFloat additionalServings = 0;
    for (int i = 0; i < 6; i++) {
        CGFloat number = ((NSNumber *)[foodGroups objectAtIndex:i]).floatValue;
        additionalServings += number;
        CGFloat oldNumber = ((NSNumber *)[groupLevels objectAtIndex:i]).floatValue;
        [groupLevels replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:number+oldNumber]];
    }
    CGFloat oldNumber = ((NSNumber *)[groupLevels objectAtIndex:7]).floatValue;
    [groupLevels replaceObjectAtIndex:7 withObject:[NSNumber numberWithFloat:additionalServings+oldNumber]];
    
    [self tallyTodaysDietPoints];
    [self saveChanges];
}

- (void)deleteFoodNumber:(int)foodNumber andMeal:(int)mealNumber
{
    
    NSMutableArray *meal = [foodDiary objectAtIndex:mealNumber];
    Food *food = [meal objectAtIndex:foodNumber];
    
    // Remove from diary
    [meal removeObjectAtIndex:foodNumber];
    
    // Remove from levels
    CGFloat removedServings = 0;
    NSArray *foodLevels = food.foodGroups;
    for (int i = 0; i < 6; i++) {
        float oldLevel = ((NSNumber *)[groupLevels objectAtIndex:i]).floatValue;
        CGFloat foodLevel = ((NSNumber *)[foodLevels objectAtIndex:i]).floatValue;
        float newLevel = oldLevel - foodLevel;
        removedServings += foodLevel;
        [groupLevels replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:newLevel]];
    }
    CGFloat oldNumber = ((NSNumber *)[groupLevels objectAtIndex:7]).floatValue;
    [groupLevels replaceObjectAtIndex:7 withObject:[NSNumber numberWithFloat:oldNumber-removedServings]];
    
    
    [self tallyTodaysDietPoints];
    [self saveChanges];
}

- (int)numberOfMeals
{
    return (int)foodDiary.count;
}

- (NSString *)nameOfMeal:(int)mealNumber
{
    NSMutableArray *meal = [foodDiary objectAtIndex:mealNumber];
    Food *f = [meal objectAtIndex:0];
    return f.meal;
}

- (int)numberOfFoodInMeal:(int)mealNumber
{
    NSMutableArray *meal = [foodDiary objectAtIndex:mealNumber];
    return (int)meal.count;
}

- (NSMutableArray *)getFoodDiary
{
    return foodDiary;
}

- (Food *)foodNumber:(int)foodNumber fromMeal:(int)mealNumber
{
    NSMutableArray *meal = [foodDiary objectAtIndex:mealNumber];
    
    if (meal == nil || meal.count < foodNumber) {
        return nil;
    }
    
    return [meal objectAtIndex:foodNumber];
}


#pragma mark Levels
#pragma mark -

- (CGFloat)getTotalServings
{
    return ((NSNumber *)[groupLevels objectAtIndex:7]).floatValue;
}

- (NSArray *)getFoodLevels
{
    return groupLevels;
}

- (CGFloat)getFruitLevel
{
    NSNumber *level = [groupLevels objectAtIndex:0];
    return level.floatValue;
}

- (CGFloat)getGrainLevel
{
    NSNumber *level = [groupLevels objectAtIndex:1];
    return level.floatValue;
}

- (CGFloat)getProteinLevel
{
    NSNumber *level = [groupLevels objectAtIndex:5];
    return level.floatValue;
}

- (CGFloat)getVeggieLevel
{
    NSNumber *level = [groupLevels objectAtIndex:3];
    return level.floatValue;
}

- (CGFloat)getDairyLevel
{
    NSNumber *level = [groupLevels objectAtIndex:2];
    return level.floatValue;
}

- (CGFloat)getJunkLevel
{
    NSNumber *level = [groupLevels objectAtIndex:4];
    return level.floatValue;
}

- (int)getGlassesOfWater
{
    return glassesOfWater;
}

- (CGFloat)getFruitPercent
{
    NSNumber *level = [groupLevels objectAtIndex:0];
    CGFloat totalServings = ((NSNumber *)[groupLevels objectAtIndex:7]).floatValue;
    return (totalServings > 0)? (level.floatValue / totalServings) * 100 : 0;
}

- (CGFloat)getGrainPercent
{
    NSNumber *level = [groupLevels objectAtIndex:1];
    CGFloat totalServings = ((NSNumber *)[groupLevels objectAtIndex:7]).floatValue;
    return (totalServings > 0)? (level.floatValue / totalServings) * 100 : 0;
}

- (CGFloat)getProteinPercent
{
    NSNumber *level = [groupLevels objectAtIndex:5];
    CGFloat totalServings = ((NSNumber *)[groupLevels objectAtIndex:7]).floatValue;
    return (totalServings > 0)? (level.floatValue / totalServings) * 100 : 0;
}

- (CGFloat)getVeggiePercent
{
    NSNumber *level = [groupLevels objectAtIndex:3];
    CGFloat totalServings = ((NSNumber *)[groupLevels objectAtIndex:7]).floatValue;
    return (totalServings > 0)? (level.floatValue / totalServings) * 100 : 0;
}

- (CGFloat)getDairyPercent
{
    NSNumber *level = [groupLevels objectAtIndex:2];
    CGFloat totalServings = ((NSNumber *)[groupLevels objectAtIndex:7]).floatValue;
    return (totalServings > 0)? (level.floatValue / totalServings) * 100 : 0;
}

- (CGFloat)getJunkPercent
{
    NSNumber *level = [groupLevels objectAtIndex:4];
    CGFloat totalServings = ((NSNumber *)[groupLevels objectAtIndex:7]).floatValue;
    return (totalServings > 0)? (level.floatValue / totalServings) * 100 : 0;
}

- (void)resetData
{
    if (today != nil && [self compareDate:[NSDate date] toDate:today] == NSOrderedSame) {
        return;
    }
    
    // Scoring
    if (today != nil) {
        int todaysWeekday = (int)[[[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit
                                                                  fromDate:today] weekday];
        [self tallyAndSavePointsToDay:todaysWeekday-1];
    }
    
    [self setToday:[NSDate date]];
    
    // Clear Food Diary
    for (int i = 0; i < 4; i++) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [foodDiary replaceObjectAtIndex:i withObject:array];
    }
    
    // Clear Water
    glassesOfWater = 0;
    
    // Clear Food Group Levels
    for (int i = 0; i < 6; i++) {
        [groupLevels replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:0.0]];
    }
    [groupLevels replaceObjectAtIndex:6 withObject:[NSNumber numberWithInt:0]];
    [groupLevels replaceObjectAtIndex:7 withObject:[NSNumber numberWithInt:0]];
}

#pragma  mark -
#pragma  mark Scoring

- (NSDate *)nextSunday
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [calendar components:NSWeekdayCalendarUnit |
                                        NSHourCalendarUnit    |
                                        NSMinuteCalendarUnit  |
                                        NSSecondCalendarUnit
                                                   fromDate:[NSDate date]];
    NSInteger weekday = [dateComponents weekday];
    NSDate *nextSunday = nil;
    NSInteger daysTillNextSunday = 8 - weekday;
    int secondsInDay = 86400; // 24 * 60 * 60
    nextSunday = [[NSDate date] dateByAddingTimeInterval:secondsInDay * daysTillNextSunday];
    
    dateComponents = [calendar components:NSYearCalendarUnit |
                      NSMonthCalendarUnit |
                      NSDayCalendarUnit |
                      NSHourCalendarUnit    |
                      NSMinuteCalendarUnit  |
                      NSSecondCalendarUnit
                                 fromDate:nextSunday];
    [dateComponents setHour:0];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];
    
    return [calendar dateFromComponents:dateComponents];
}

- (BOOL)resetScores
{
    if (dateToReset == nil || [[NSDate date] compare:dateToReset] == NSOrderedDescending) {
        dateToReset = [self nextSunday];
        dailyScores = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:0],
                                                               [NSNumber numberWithInt:0], [NSNumber numberWithInt:0],
                                                               [NSNumber numberWithInt:0], [NSNumber numberWithInt:0],
                                                               [NSNumber numberWithInt:0], dateToReset,
                                                               nil];
        return YES;
    }
    return NO;
}

- (int)compareDate:(NSDate *)date1 toDate:(NSDate *)date2
{
    int year1 = (int)[[[NSCalendar currentCalendar]
                       components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                       fromDate:date1] year];
    int year2 = (int)[[[NSCalendar currentCalendar]
                       components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                       fromDate:date2] year];
    if (year1 == year2) {
        int month1 = (int)[[[NSCalendar currentCalendar]
                            components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                            fromDate:date1] month];
        int month2 = (int)[[[NSCalendar currentCalendar]
                            components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                            fromDate:date2] month];
        if (month1 == month2) {
            int day1 = (int)[[[NSCalendar currentCalendar]
                              components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                              fromDate:date1] day];
            int day2 = (int)[[[NSCalendar currentCalendar]
                              components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                              fromDate:date2] day];
            if (day1 == day2)
                return NSOrderedSame;
            else if (day1 < day2)
                return NSOrderedAscending;
            else
                return NSOrderedDescending;
        }
        else if (month1 < month2)
            return NSOrderedAscending;
        else
            return NSOrderedDescending;
    }
    else if (year1 < year2)
        return NSOrderedAscending;
    else
        return NSOrderedDescending;
}

- (int)dietPointsForDay:(int)day
{
    return ((NSNumber *)[dailyScores objectAtIndex:day]).intValue;
}

- (int)totalDietPointsThisWeek
{
    int sum = 0;
    for (int i = 0; i < 7; i++) {
        sum += ((NSNumber *)[dailyScores objectAtIndex:i]).intValue;
    }
    return sum;
}

- (void)tallyTodaysDietPoints
{
    int todaysWeekday = (int)[[[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit
                                                              fromDate:[NSDate date]] weekday];
    [self tallyAndSavePointsToDay:todaysWeekday-1];
}

- (void)tallyAndSavePointsToDay:(int)day
{
    CGFloat totalServings = ((NSNumber *)[groupLevels objectAtIndex:7]).floatValue;
    
    int sum = 0;
    for (int i = 0; i < 6; i++) {
        CGFloat level = ((NSNumber *)[groupLevels objectAtIndex:i]).floatValue;
        if (level == 0) {
            continue;
        }
        CGFloat actual = (totalServings > 0)? (level / totalServings) : 0;
        
        NSArray *goals = [UserSettingsStore sharedStore].foodGroupGoals;
        CGFloat levelGoal = ((NSNumber *)[goals objectAtIndex:i]).floatValue;
        
        if (fabsf(levelGoal - actual) <= .05) {
            sum++;
        }
    }
    int oldValue = ((NSNumber *)[dailyScores objectAtIndex:day]).intValue;
    [[UserDataStore sharedStore] addUserPoints:(sum-oldValue)];
    
    [dailyScores replaceObjectAtIndex:day withObject:[NSNumber numberWithInt:sum]];
}

#pragma mark -
#pragma mark Food Catalog

- (NSArray *)getFoodCatalog
{
    return foodCatalog;
}

- (NSArray *)filterCatalogWithSearch:(NSString *)substring
{
    NSMutableArray *filteredCatalog = [[NSMutableArray alloc] init];
    for (int i = 0;  i < 26; i++) {
        NSMutableArray *section = [foodCatalog objectAtIndex:i];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", substring];
        NSArray *filteredSection = [section filteredArrayUsingPredicate:predicate];
        [filteredCatalog addObject:filteredSection];
    }
    return filteredCatalog;
}

- (NSArray *)copyOfFoodCatalog
{
    NSMutableArray *copy = [[NSMutableArray alloc] init];
    for (int i = 0; i < 26; i++) {
        NSMutableArray *section = [foodCatalog objectAtIndex:i];
        NSMutableArray *copiedSection = [[NSMutableArray alloc] initWithArray:section copyItems:YES];
        [copy addObject:copiedSection];
    }
    
    return copy;
}

- (void)addFoodToCatalog:(Food *)food
{
    // Add
    NSString *foodName = [food.name uppercaseString];
    const char *name = [foodName UTF8String];
    char firstLetter = name[0];
    int indexOfCatalog = firstLetter - 'A';
    NSLog(@"Index of %@ is %d", foodName, indexOfCatalog);
    
    // Food Catalog
    NSMutableArray *section = [foodCatalog objectAtIndex:indexOfCatalog];
    [section addObject:food];
    
    // Sort
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                 ascending:YES];
    [section sortUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    [self saveChanges];
}

- (void)deleteFoodFromCatalog:(Food *)food
{
    NSLog(@"Delete %@ from catalog.", food.name);
}

//- (NSArray *)getNumberOfSections
//{
//    NSMutableArray *sectionNumbers = [[NSMutableArray alloc] init];
//    for (int i = 0; i < 26; i++) {
//        NSMutableArray *section = [foodCatalog objectAtIndex:i];
//        if (section.count > 0) {
//            [sectionNumbers addObject:[NSNumber numberWithInt:i]];
//        }
//    }
//    return sectionNumbers;
//}
//
//- (int)getNumberOfFoodForSection:(int)section
//{
//    return ((NSMutableArray *)[foodCatalog objectAtIndex:section]).count;
//}
//
//- (Food *)getFoodForSection:(int)section andRow:(int)row
//{
//    NSMutableArray *foodSection = (NSMutableArray *)[foodCatalog objectAtIndex:section];
//    return [foodSection objectAtIndex:row];
//}

#pragma mark -

@end
