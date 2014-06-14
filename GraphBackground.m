//
//  GraphBackground.m
//  HealthApp
//
//  Created by David Neubauer on 5/5/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "GraphBackground.h"

@implementation GraphBackground

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
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect bounds = self.bounds;
    
    // Y - axis Bar
    CGContextSetLineWidth(ctx, 1);
    CGContextSetRGBStrokeColor(ctx, (70/255.0), (70/255.0), (70/255.0), 1.0);
    
    CGContextMoveToPoint(ctx, 0, 0);
    CGContextAddLineToPoint(ctx, 0, bounds.size.height);
    
    // X - axis Bar
    CGContextSetLineWidth(ctx, 1);
    CGContextSetRGBStrokeColor(ctx, (70/255.0), (70/255.0), (70/255.0), 1.0);
    
    CGContextAddLineToPoint(ctx, bounds.size.width, bounds.size.height);
    
    CGContextStrokePath(ctx);
    
    // Measure Bars
    for (int i = 0; i < 5; i++) {
        CGContextSetLineWidth(ctx, 1);
        CGContextSetRGBStrokeColor(ctx, (70/255.0), (70/255.0), (70/255.0), 0.25);
        CGContextMoveToPoint(ctx, 1, 11 + 24*i);
        CGContextAddLineToPoint(ctx, bounds.size.width-1, 11 + 24*i);
        CGContextStrokePath(ctx);
    }

}


@end
