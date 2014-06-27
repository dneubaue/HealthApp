//
//  MonitorForegroundView.m
//  HealthApp
//
//  Created by David Neubauer on 5/4/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "MonitorForegroundView.h"

@interface MonitorForegroundView ()
{
    CGFloat percent;
}
@end

@implementation MonitorForegroundView

- (id)initWithFrame:(CGRect)frame andPercent:(CGFloat)percentOfCircle
{
    self = [super initWithFrame:frame];
    if (self) {
        percent = percentOfCircle;
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
    CGContextSetRGBStrokeColor(ctx, (63/255.0), (195/255.0), (128/255.0), 1.0);
//    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    CGFloat start = 1*M_PI/2.0;
    CGFloat degree = percent * 360;
    CGFloat radians = start + (degree * (M_PI/180.0));
    
    CGContextAddArc(ctx, center.x, center.y, (bounds.size.width/2.0)-4, start, radians, NO);
    CGContextStrokePath(ctx);
}

@end
