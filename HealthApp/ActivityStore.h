//
//  ActivityStore.h
//  HealthApp
//
//  Created by David Neubauer on 4/3/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityStore : NSObject
{
}

+ (ActivityStore *)sharedStore;
- (BOOL)saveChanges;
- (void)removeActivityFromToday:(NSInteger)num;
- (void)addActivityToToday:(NSInteger)num;
- (BOOL)activityIsInToday:(NSInteger)num;
- (int)tallyActivityPoints:(int)acts;
- (int)getActivitiesForDay:(int)day;
- (int)getNumberOfActivitesForActs:(int)acts;
- (NSMutableArray *)getEarlierActivites;
- (int)getNumberOfEarlierActivites:(NSArray *)earlierActs;
- (BOOL)reset;
- (int)getTodayActNumber:(int)actNum;
- (int)getEarlierAct:(NSMutableArray *)earlierActs Number:(int)actNum;

// Used for overview
- (int)getActivityPoints;

@end
