//
//  Food.m
//  HealthApp
//
//  Created by David Neubauer on 4/5/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "Food.h"

@implementation Food
@synthesize name, meal, foodGroups;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setName:[aDecoder decodeObjectForKey:@"name"]];
        [self setMeal:[aDecoder decodeObjectForKey:@"meal"]];
        [self setFoodGroups:[aDecoder decodeObjectForKey:@"foodGroups"]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:name forKey:@"name"];
    [aCoder encodeObject:meal forKey:@"meal"];
    [aCoder encodeObject:foodGroups forKey:@"foodGroups"];
}

@end
