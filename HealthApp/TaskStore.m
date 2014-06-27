//
//  TaskStore.m
//  HealthApp
//
//  Created by David Neubauer on 4/4/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "TaskStore.h"
#import "Task.h"
#import "UserDataStore.h"

@interface TaskStore ()
{
    NSMutableArray *tasks;
    NSMutableArray *todaysTasks;
    NSMutableArray *tomorrowsTasks;
    NSMutableArray *laterTasks;
    NSMutableArray *dailyScores;
    
    NSDate *dateToReset;
}
@end

@implementation TaskStore

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

+ (TaskStore *)sharedStore
{
    static TaskStore *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:NULL] init];
    }
    
    [sharedStore updateTasks];
    
    return sharedStore;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSString *path = [self archivePath];
        tasks = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (!tasks) {
            tasks = [[NSMutableArray alloc] init];
        }
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
    NSString *path = [self archivePath];
    NSString *path2 = [self scoresPath];
    
    BOOL save = [NSKeyedArchiver archiveRootObject:tasks toFile:path];
    
    [dailyScores replaceObjectAtIndex:7 withObject:dateToReset];
    save =  save && [NSKeyedArchiver archiveRootObject:dailyScores toFile:path2];
    return save;
}

- (NSString *)archivePath
{
    NSArray *docDirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                           NSUserDomainMask,
                                                           YES);
    NSString *docDir = [docDirs objectAtIndex:0];
    return [docDir stringByAppendingPathComponent:@"tasks.Archive"];
}

- (NSString *)scoresPath
{
    NSArray *docDirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                           NSUserDomainMask,
                                                           YES);
    NSString *docDir = [docDirs objectAtIndex:0];
    return [docDir stringByAppendingPathComponent:@"scores.Archive"];
}


- (void)addTask:(Task *)task
{
    // Add
    [tasks addObject:task];
    
    // Sort
    NSSortDescriptor *sortDescriptor, *sortDescriptor2;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date"
                                                 ascending:YES];
    sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"description"
                                                  ascending:YES];
    [tasks sortUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, sortDescriptor2, nil]];
    
    [self saveChanges];
}

- (void)completeTaskWithDescription:(NSString *)description andDay:(int)day
{
    int taskIndex = 0;
    while (taskIndex < tasks.count) {
        Task *task = [tasks objectAtIndex:taskIndex];
        int tasksDayOfWeek = (int)[[[NSCalendar currentCalendar]
                                    components:NSWeekdayCalendarUnit
                                    fromDate:task.date] weekday];
        if (tasksDayOfWeek >= day && [task.description isEqualToString:description]) {
            [tasks removeObjectAtIndex:taskIndex];
            int today = (int)[[[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit
                                                              fromDate:[NSDate date]] weekday];
            if (tasksDayOfWeek < today) {
                tasksDayOfWeek += 7;
            }
            int points = tasksDayOfWeek - today + 1;
            
            int oldScore = ((NSNumber *)[dailyScores objectAtIndex:today-1]).intValue;
            [dailyScores replaceObjectAtIndex:today-1 withObject:[NSNumber numberWithInt:oldScore+points]];
            [self saveChanges];
            
            [[UserDataStore sharedStore] addUserPoints:points];
            
            return;
        }
        taskIndex++;
    }
}

- (void)deleteTaskWithDescription:(NSString *)description andDay:(int)day
{
    int taskIndex = 0;
    while (taskIndex < tasks.count) {
        Task *task = [tasks objectAtIndex:taskIndex];
        int tasksDayOfWeek = (int)[[[NSCalendar currentCalendar]
                                    components:NSWeekdayCalendarUnit
                                    fromDate:task.date] weekday];
        if (tasksDayOfWeek >= day && [task.description isEqualToString:description]) {
            [tasks removeObjectAtIndex:taskIndex];
            [self saveChanges];
            return;
        }
        taskIndex++;
    }
}

- (void)populateTaskLists
{
    todaysTasks = [[NSMutableArray alloc] init];
    tomorrowsTasks = [[NSMutableArray alloc] init];
    laterTasks = [[NSMutableArray alloc] init];
    NSDate *todaysDate = [NSDate date];
    int todayDayOfWeek = (int)[[[NSCalendar currentCalendar]
                                components:NSWeekdayCalendarUnit
                                fromDate:todaysDate] weekday];
    int taskIndex = 0;
    
    // While tasks is equal to today
    while (taskIndex < tasks.count) {
        Task *task = [tasks objectAtIndex:taskIndex];
        if ([self compareDate:todaysDate toDate:task.date] == NSOrderedSame) {
            [todaysTasks addObject:task];
        }
        else {
            break;
        }
        taskIndex++;
    }
    // While tasks is equal to tomorrow
    while (taskIndex < tasks.count) {
        Task *task = [tasks objectAtIndex:taskIndex];
        int tasksDayOfWeek = (int)[[[NSCalendar currentCalendar]
                                    components:NSWeekdayCalendarUnit
                                    fromDate:task.date] weekday];
        int tomorrow = (todayDayOfWeek != 7)? todayDayOfWeek+1 : 1;
        if (tomorrow == tasksDayOfWeek) {
            [tomorrowsTasks addObject:task];
        }
        else {
            break;
        }
        taskIndex++;
    }
    // Add the rest to later
    while (taskIndex < tasks.count) {
        Task *task = [tasks objectAtIndex:taskIndex];
        [laterTasks addObject:task];
        taskIndex++;
    }
}

/* This method is called to fill out table view */
- (NSMutableArray *)tasksForDay:(int)daysAfterToday
{
    if (daysAfterToday == 0) {
        return todaysTasks;
    }
    else if (daysAfterToday == 1) {
        return tomorrowsTasks;
    }
    else {
        return laterTasks;
    }
}

/* Clears any tasks that are past due and reorganizes the tasks list */
- (void)updateTasks
{
    // While there is a task who's date is in the past, delete task
    int tasksDeleted = 0;
    while (tasksDeleted < tasks.count) {
        Task *firstTask = [tasks objectAtIndex:0];
        NSDate *dateOfFirstTask = firstTask.date;
        NSDate *todaysDate = [NSDate date];
        
        // dateOfFirstTask before today
        if ([self compareDate:todaysDate toDate:dateOfFirstTask] == NSOrderedDescending) {
            [tasks removeObjectAtIndex:0];
            tasksDeleted++;
        }
        else {
            break;
        }
    }
    
    return;
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
- (int)taskPointsForDay:(int)day
{
    return ((NSNumber *)[dailyScores objectAtIndex:day]).intValue;
}

- (int)getTaskPoints
{
    int sum = 0;
    for (int i = 0; i < 7; i++) {
        sum += ((NSNumber *)[dailyScores objectAtIndex:i]).intValue;
    }
    return sum;
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
        dailyScores = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:0],
                                                              [NSNumber numberWithInt:0], [NSNumber numberWithInt:0],
                                                              [NSNumber numberWithInt:0], [NSNumber numberWithInt:0],
                                                              [NSNumber numberWithInt:0], dateToReset,
                                                              nil];
        
        return YES;
    }
    return NO;
}

@end
