//
//  ActivityStore.m
//  HealthApp
//
//  Created by David Neubauer on 4/3/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "ActivityStore.h"

@interface ActivityStore ()
{
    NSMutableArray *activities;

    NSDate *dateToReset;
}
@end

@implementation ActivityStore

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

+ (ActivityStore *)sharedStore
{
    static ActivityStore *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:NULL] init];
    }
    
    return sharedStore;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSString *path = [self archivePath];
        activities = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (!activities) {
            activities = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:0],
                                                                 [NSNumber numberWithInt:0], [NSNumber numberWithInt:0],
                                                                 [NSNumber numberWithInt:0], [NSNumber numberWithInt:0],
                                                                 [NSNumber numberWithInt:0], nil];
            NSDate *date = [[NSDate date] dateByAddingTimeInterval:-86400];
            [activities addObject:date];
            
        }
        dateToReset = [activities objectAtIndex:7];
    }
    
    return self;
}

- (BOOL)saveChanges
{
    NSString *path = [self archivePath];

    [activities replaceObjectAtIndex:7 withObject:dateToReset];
    BOOL save = [NSKeyedArchiver archiveRootObject:activities toFile:path];
    return save;
}

- (NSString *)archivePath
{
    NSArray *docDirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                           NSUserDomainMask,
                                                           YES);
    NSString *docDir = [docDirs objectAtIndex:0];
    return [docDir stringByAppendingPathComponent:@"activities.Archive"];
}

- (BOOL)activityIsInToday:(NSInteger)num
{
    int today = (int)[[[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:[NSDate date]] weekday];
    
    int todaysActs = ((NSNumber *)[activities objectAtIndex:today-1]).intValue;
    return todaysActs & (0x1 << num);
}

- (void)removeActivityFromToday:(NSInteger)num
{
    int today = (int)[[[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:[NSDate date]] weekday];
    
    int oldActs = ((NSNumber *)[activities objectAtIndex:today-1]).intValue;
    int newActs = oldActs & (0x1F ^ 0x1 << num);
    [activities replaceObjectAtIndex:today-1 withObject:[NSNumber numberWithInt:newActs]];
    
    [self saveChanges];
}

- (void)addActivityToToday:(NSInteger)num
{
    int today = (int)[[[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:[NSDate date]] weekday];
    
    int oldActs = ((NSNumber *)[activities objectAtIndex:today-1]).intValue;
    int newActs = oldActs | (0x1 << num);
    [activities replaceObjectAtIndex:today-1 withObject:[NSNumber numberWithInt:newActs]];
    
    [self saveChanges];
}

- (int)tallyActivityPoints:(int)day
{
    int acts = ((NSNumber *)[activities objectAtIndex:day]).intValue;
    int sum = 0;
    for (int i = 0; i < 5; i++) {
        int act = acts & 0x1;
        if (i > 0)
            sum += act;
        sum += act;
        acts = acts >> 1;
    }
    return sum;
}

- (int)getActivitiesForDay:(int)day
{
    return ((NSNumber *)[activities objectAtIndex:day]).intValue;
}

- (int)getNumberOfActivitesForActs:(int)acts
{
    int sum = 0;
    for (int i = 0; i < 5; i++) {
        if (acts & (0x1 << i)) {
            sum++;
        }
    }
    return sum;
}

- (NSMutableArray *)getEarlierActivites
{
    NSMutableArray *earlierActs = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:0],
                   [NSNumber numberWithInt:0], [NSNumber numberWithInt:0],
                   [NSNumber numberWithInt:0], [NSNumber numberWithInt:0],
                   [NSNumber numberWithInt:0], nil];
    
    int today = (int)[[[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:[NSDate date]] weekday];
    for (int i = 0; i < today-1; i++) {
        int acts = ((NSNumber *)[activities objectAtIndex:i]).intValue;
        for (int j = 0; j < 5; j++) {
            int act = acts & (0x1 << j);
            
            int oldCount = ((NSNumber *)[earlierActs objectAtIndex:j]).intValue;
            int newCount = oldCount + act;
            [earlierActs replaceObjectAtIndex:j withObject:[NSNumber numberWithInt:newCount]];
        }
    }
    
    return earlierActs;
}

- (int)getNumberOfEarlierActivites:(NSArray *)earlierActs
{
    int sum = 0;
    for (int i = 0; i < earlierActs.count; i++) {
        if (((NSNumber *)[earlierActs objectAtIndex:i]).intValue != 0) {
            sum++;
        }
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
        activities = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:0],
                                                             [NSNumber numberWithInt:0], [NSNumber numberWithInt:0],
                                                             [NSNumber numberWithInt:0], [NSNumber numberWithInt:0],
                                                             [NSNumber numberWithInt:0], dateToReset,
                                                             nil];
        
        return YES;
    }
    return NO;
}

- (int)getTodayActNumber:(int)actNum
{
    int today = (int)[[[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:[NSDate date]] weekday];
    int acts = ((NSNumber *)[activities objectAtIndex:today-1]).intValue;
    int actIdx = 0;
    for (int i = 0; i < 5; i++) {
        int act = acts & (0x1 << i);
        if (act > 0) {
            if (actIdx == actNum)
                return i;
            else
                actIdx++;
        }
    }
    return actIdx;
}

- (int)getEarlierAct:(NSMutableArray *)earlierActs Number:(int)actNum
{
    while (activities.count > 8) {
        [activities removeObjectAtIndex:8];
    }
    int acts = 0;
    int actIdx = 0;
    for (int i = 0; i < 7; i++) {
        acts = ((NSNumber *)[earlierActs objectAtIndex:i]).intValue;
        if (acts > 0) {
            if (actIdx == actNum)
                return i;
            else
                actIdx++;
        }
    }
    return actIdx;
}

- (int)getActivityPoints
{
    int sum = 0;
    for (int i = 0; i < 7; i++) {
        sum += [self tallyActivityPoints:i];
    }
    return sum;
}

@end
