//
//  UserSettings.m
//  HealthApp
//
//  Created by David Neubauer on 6/8/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "UserSettingsStore.h"

@interface UserSettingsStore ()
{
    enum groups;
}

@end

@implementation UserSettingsStore

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

+ (UserSettingsStore *)sharedStore
{
    static UserSettingsStore *sharedStore = nil;
    if (!sharedStore) {
        sharedStore = [[super allocWithZone:NULL] init];
    }
    
    return sharedStore;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSString *path = [self goalsPath];
        self.foodGroupGoals = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (!self.foodGroupGoals) {
            self.foodGroupGoals = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithDouble:.25],
                                                                   [NSNumber numberWithDouble:.23],
                                                                   [NSNumber numberWithDouble:.20],
                                                                   [NSNumber numberWithDouble:.05],
                                                                   [NSNumber numberWithDouble:.25],
                                                                   [NSNumber numberWithDouble:.02],nil];
        }
        enum groups {
            FRUIT, GRAINS, DAIRY, VEGGIE, JUNK, PROTEIN
        };
    }
    return self;
}

- (BOOL)saveChanges
{
    NSString *path = [self goalsPath];
    BOOL save = [NSKeyedArchiver archiveRootObject:self.foodGroupGoals toFile:path];
    return save;
}

- (NSString *)goalsPath
{
    NSArray *docDirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                           NSUserDomainMask,
                                                           YES);
    NSString *docDir = [docDirs objectAtIndex:0];
    return [docDir stringByAppendingPathComponent:@"goals.Archive"];
}

- (int)goalForFoodGroup:(int)index
{
    return 100 * ((NSNumber *)[self.foodGroupGoals objectAtIndex:index]).floatValue;
}

- (void)setGoal:(CGFloat)goal forGroup:(int)index
{
    NSNumber *number = [NSNumber numberWithFloat:goal * 0.01];
    [self.foodGroupGoals replaceObjectAtIndex:index withObject:number];
    
    if (index == self.foodGroupGoals.count-1) {
        [self saveChanges];
    }
}

@end
