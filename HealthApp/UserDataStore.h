//
//  UserDataStore.h
//  HealthApp
//
//  Created by David Neubauer on 5/7/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDataStore : NSObject
{
}

+ (UserDataStore *)sharedStore;
- (BOOL)saveChanges;
- (void)saveTodaysPoints;
- (BOOL)reset;

- (NSNumber *)pointsForDay:(int)dayOfWeek;

- (int)getUserPoints;
- (int)pointsRemaining;
- (void)setUserPoints:(int)points;
- (void)addUserPoints:(int)points;

- (int)pointsAtCurrentLevel;
- (int)getUserLevel;
- (void)setUserLevel:(int)level;
- (BOOL)levelUp;
- (BOOL)levelDown;

- (void)setUserStars:(int)stars;
- (int)getUserStars;
- (BOOL)starUp;
- (BOOL)starDown;

@end
