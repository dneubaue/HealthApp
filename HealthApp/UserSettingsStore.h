//
//  UserSettings.h
//  HealthApp
//
//  Created by David Neubauer on 6/8/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserSettingsStore : NSObject

@property NSMutableArray *foodGroupGoals;

+ (UserSettingsStore *)sharedStore;
- (BOOL)saveChanges;

- (int)goalForFoodGroup:(int)index;
- (void)setGoal:(CGFloat)goal forGroup:(int)index;

@end
