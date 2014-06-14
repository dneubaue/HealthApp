//
//  GraphPlot.m
//  HealthApp
//
//  Created by David Neubauer on 5/5/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "GraphPlot.h"
#import "ActivityStore.h"
#import "FoodStore.h"
#import "TaskStore.h"
#import "UserDataStore.h"

@implementation GraphPlot

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSArray *levels = [self getPointsPerDay];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    int graphHeight = 130;
    
    CGContextSetLineWidth(ctx, 2);
    CGContextSetRGBStrokeColor(ctx, (63/255.0), (195/255.0), (128/255.0), 1.0);
    CGContextSetRGBFillColor(ctx, (63/255.0), (195/255.0), (128/255.0), 0.25);
    
    // Filled Plot
    CGContextMoveToPoint(ctx, 1, graphHeight);
    for (int i = 0; i < levels.count; i++) {
        int level = ((NSNumber *)[levels objectAtIndex:i]).intValue;
        CGContextAddLineToPoint(ctx, 32*i + 28, [self pixelsFromHeight:level]);
    }
    CGContextAddLineToPoint(ctx, 32*(levels.count-1) + 28, graphHeight);
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
//    CGContextStrokePath(ctx);
    
    // Line Plot
    CGContextMoveToPoint(ctx, 1, graphHeight);
    for (int i = 0; i < levels.count; i++) {
        int level = ((NSNumber *)[levels objectAtIndex:i]).intValue;
        CGContextAddLineToPoint(ctx, 32*i + 28, [self pixelsFromHeight:level]);
    }
    CGContextStrokePath(ctx);
    
    // Dots
    CGContextSetRGBFillColor(ctx, (218/255.0), (218/255.0), (218/255.0), 1.0);
    CGContextSetLineWidth(ctx, 1);
    for (int i = 0; i < levels.count; i++) {
        int level = ((NSNumber *)[levels objectAtIndex:i]).intValue;
        CGContextAddArc(ctx, 32*i + 28, [self pixelsFromHeight:level], 3, 0.0, 2*M_PI, YES);
        CGContextFillPath(ctx);
        CGContextAddArc(ctx, 32*i + 28, [self pixelsFromHeight:level], 3, 0.0, 2*M_PI, YES);
        CGContextStrokePath(ctx);
    }
}

- (NSArray *)getPointsPerDay
{
    NSMutableArray *levels = [[NSMutableArray alloc] init];
    int today = (int)[[[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:[NSDate date]] weekday];
    for (int i = 0; i < today-1; i++) {
        [levels addObject:[[UserDataStore sharedStore] pointsForDay:i]];
    }
    NSNumber *todaysPoints = [NSNumber numberWithInt:[[UserDataStore sharedStore] getUserPoints]];
    [levels addObject:todaysPoints];
    return levels;
}

- (CGFloat)pixelsFromHeight:(CGFloat)height
{
    int maxPoints = [[UserDataStore sharedStore] pointsAtCurrentLevel];
    if (height > maxPoints || height < 0) {
        NSLog(@"GraphPlot.h: Height is out of bounds");
        return 0;
    }
    if (height == 0) {
        return 130;
    }
    
    CGFloat H = 119;
    CGFloat unit = H / (double)maxPoints;
    
    return H - (height * unit) + 12;
}

@end
