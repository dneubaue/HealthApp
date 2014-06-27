//
//  Task.m
//  HealthApp
//
//  Created by David Neubauer on 4/4/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "Task.h"

@implementation Task
@synthesize description, date;


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setDescription:[aDecoder decodeObjectForKey:@"description"]];
        [self setDate:[aDecoder decodeObjectForKey:@"date"]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:description forKey:@"description"];
    [aCoder encodeObject:date forKey:@"date"];
}

@end
