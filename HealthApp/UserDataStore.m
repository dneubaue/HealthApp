//
//  UserDataStore.m
//  HealthApp
//
//  Created by David Neubauer on 5/7/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "UserDataStore.h"

#define POINTS 0
#define LEVEL 1
#define STAR 2

#define NUM_STARS 4
#define NUM_LEVELS 25


@interface UserDataStore ()
{
    NSMutableArray *userData;
    NSMutableArray *dailyPoints;
    int pointsPerLevel[NUM_LEVELS];
    NSDate *dateToReset;
}

@end

@implementation UserDataStore

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

+ (UserDataStore *)sharedStore
{
    static UserDataStore *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:NULL] init];
    }
    
    return sharedStore;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSArray *paths = [self getPaths];
        
        NSString *path = [paths objectAtIndex:0];
        userData = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (!userData) {
            userData = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:0],
                                                               [NSNumber numberWithInt:0],
                                                               [NSNumber numberWithInt:0], nil];
        }
        
        path = [paths objectAtIndex:1];
        dailyPoints = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (!dailyPoints) {
            NSDate *date = [NSDate date];
            dailyPoints = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:0],
                                                                  [NSNumber numberWithInt:0],
                                                                  [NSNumber numberWithInt:0],
                                                                  [NSNumber numberWithInt:0],
                                                                  [NSNumber numberWithInt:0],
                                                                  [NSNumber numberWithInt:0],
                                                                  [NSNumber numberWithInt:0],
                                                                  date, nil];
        }
        dateToReset = [dailyPoints objectAtIndex:7];
        
        pointsPerLevel[0] = 10;
        pointsPerLevel[1] = 10;
        pointsPerLevel[2] = 10;
        pointsPerLevel[3] = 10;
        pointsPerLevel[4] = 10;
        for (int i = 5; i < 15; i++) {
            pointsPerLevel[i] = 25;
            pointsPerLevel[i+10] = 50;
        }
    }
    return self;
}

- (BOOL)saveChanges
{
    NSArray *paths = [self getPaths];
    NSString *path1 = [paths objectAtIndex:0];
    NSString *path2 = [paths objectAtIndex:1];
    
    BOOL save = [NSKeyedArchiver archiveRootObject:userData toFile:path1];
    save &= [NSKeyedArchiver archiveRootObject:dailyPoints toFile:path2];
    
    return save;
}

- (NSArray *)getPaths
{
    NSArray *docDirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                           NSUserDomainMask,
                                                           YES);
    NSString *docDir = [docDirs objectAtIndex:0];
    
    NSString *path1 = [docDir stringByAppendingPathComponent:@"UserData_userData.Archive"];
    NSString *path2 = [docDir stringByAppendingPathComponent:@"UserData_dailyPoints.Archive"];
    return [[NSArray alloc] initWithObjects:path1, path2, nil];
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

- (void)saveTodaysPoints
{
    // Set the rest of the weekdays this amount of points
    int weekday = (int)[[[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit
                                                        fromDate:[NSDate date]] weekday];
    NSNumber *points = [NSNumber numberWithInt:[self getUserPoints]];
    for (int i = weekday-1; i < 7; i++) {
        [dailyPoints replaceObjectAtIndex:i withObject:points];
    }
    [self saveChanges];
}

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

- (BOOL)reset
{
    if (dateToReset == nil || [[NSDate date] compare:dateToReset] == NSOrderedDescending) {
        dateToReset = [self nextSunday];
        dailyPoints = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:0],
                                                              [NSNumber numberWithInt:0],
                                                              [NSNumber numberWithInt:0],
                                                              [NSNumber numberWithInt:0],
                                                              [NSNumber numberWithInt:0],
                                                              [NSNumber numberWithInt:0],
                                                              [NSNumber numberWithInt:0],
                                                              dateToReset,
                                                              nil];
        
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark Points

- (NSNumber *)pointsForDay:(int)dayOfWeek
{
    return [dailyPoints objectAtIndex:dayOfWeek];
}

- (int)getUserPoints
{
    return ((NSNumber *)[userData objectAtIndex:POINTS]).intValue;
}

- (int)pointsRemaining
{
    int currentPoints = [self getUserPoints];
    int level = [self getUserLevel];
    int pointsInCurrentLevel = pointsPerLevel[level];
    return pointsInCurrentLevel - currentPoints;
}

- (void)setUserPoints:(int)points
{
    [userData replaceObjectAtIndex:POINTS withObject:[NSNumber numberWithInt:points]];
    [self saveTodaysPoints];
}

- (void)addUserPoints:(int)points
{
    int currentPoints = [self getUserPoints] + points;
    int level = [self getUserLevel];
    int pointsInCurrentLevel = pointsPerLevel[level];
    BOOL userShouldLevelUp = (currentPoints >= pointsInCurrentLevel);
    BOOL userShouldLevelDown = currentPoints < 0;
    
    if (userShouldLevelUp) {
        BOOL success = [self levelUp];
        if (success) {
            [self setUserPoints:currentPoints-pointsInCurrentLevel];
        } else {
            [self setUserPoints:pointsInCurrentLevel];
        }
    } else if (userShouldLevelDown) {
        BOOL success = [self levelDown];
        if (success) {
            int pointsInLastLevel = pointsPerLevel[level-1];
            [self setUserPoints:pointsInLastLevel + currentPoints];
        } else {
            [self setUserPoints:0];
        }
    } else {
        [self setUserPoints:currentPoints];
    }
    
    [self saveTodaysPoints];
}

#pragma mark -
#pragma mark Level

- (int)pointsAtCurrentLevel
{
    int level = [self getUserLevel];
    return pointsPerLevel[level];
}

- (int)getUserLevel
{
    return ((NSNumber *)[userData objectAtIndex:LEVEL]).intValue;
}

- (void)setUserLevel:(int)level
{
    [userData replaceObjectAtIndex:LEVEL withObject:[NSNumber numberWithInt:level]];
}

- (BOOL)levelUp
{
    int level = [self getUserLevel];
    if (level == (NUM_LEVELS-1)) {
        BOOL success = [self starUp];
        if (success) {
            [self setUserLevel:0];
        } else {
            return NO;
        }
    } else {
        [self setUserLevel:level+1];
    }
    return YES;
}

- (BOOL)levelDown
{
    int level = [self getUserLevel];
    if (level == 0) {
        BOOL success = [self starDown];
        if (success) {
            [self setUserLevel:NUM_LEVELS-1];
        } else {
            return NO;
        }
    } else {
        [self setUserLevel:level-1];
    }
    return YES;
}

- (void)incrementUserLevel
{
    int oldLevel = ((NSNumber *)[userData objectAtIndex:LEVEL]).intValue;
    [userData replaceObjectAtIndex:LEVEL withObject:[NSNumber numberWithInt:oldLevel+1]];
}

#pragma mark -
#pragma mark Stars

- (void)setUserStars:(int)level
{
    [userData replaceObjectAtIndex:STAR withObject:[NSNumber numberWithInt:level]];
}

- (int)getUserStars
{
    return ((NSNumber *)[userData objectAtIndex:STAR]).intValue;
}

- (BOOL)starUp
{
    int numStars = [self getUserStars];
    if (numStars == NUM_STARS) {
        return NO;
    } else {
        [self setUserStars:numStars+1];
    }
    return YES;
}

- (BOOL)starDown
{
    int numStars = [self getUserStars];
    if (numStars == 0) {
        return NO;
    } else {
        [self setUserStars:numStars-1];
    }
    return YES;
}


















@end
