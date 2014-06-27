//
//  MonitorView.m
//  HealthApp
//
//  Created by David Neubauer on 5/4/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "MonitorBackgroundView.h"

@implementation MonitorBackgroundView

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
    
    CGFloat x = bounds.size.width/2.0;
    CGFloat y = bounds.size.height/2.0;
    CGPoint center = CGPointMake(x, y);
    
    CGContextSetLineWidth(ctx, 7);
    CGContextSetRGBStrokeColor(ctx, (70/255.0), (70/255.0), (70/255.0), 0.1);
    
    CGContextAddArc(ctx, center.x, center.y, (bounds.size.width/2.0)-4, 0.0, M_PI*2.0, YES);
    CGContextStrokePath(ctx);
}


@end
