//
//  TaskStore.h
//  HealthApp
//
//  Created by David Neubauer on 4/4/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Task;

@interface TaskStore : NSObject
{
}

+ (TaskStore *)sharedStore;
- (BOOL)saveChanges;
- (void)addTask:(Task *)task;
- (void)completeTaskWithDescription:(NSString *)description andDay:(int)day;
- (void)deleteTaskWithDescription:(NSString *)description andDay:(int)day;
- (void)populateTaskLists;
- (NSMutableArray *)tasksForDay:(int)daysAfterToday;
- (int)taskPointsForDay:(int)day;
- (int)getTaskPoints;
- (BOOL)reset;
@end
