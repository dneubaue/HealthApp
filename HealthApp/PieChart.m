//
//  PieChart.m
//  HealthApp
//
//  Created by David Neubauer on 5/20/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "PieChart.h"
#import "FoodStore.h"

@interface PieChart ()
{
    UIColor *eggWhite;
    UIColor *darkerGray;
    UIColor *lighterGray;
    UIColor *mint;
    
    UIColor *fruitColor;
    UIColor *grainColor;
    UIColor *proteinColor;
    UIColor *veggieColor;
    UIColor *dairyColor;
}
@end

@implementation PieChart

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        eggWhite = [UIColor colorWithRed:(218/255.0) green:(218/255.0) blue:(218/255.0) alpha:1.0];
        darkerGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:1.0];
        lighterGray = [UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:0.7];
        mint = [UIColor colorWithRed:(63/255.0) green:(195/255.0) blue:(128/255.0) alpha:1.0];
        
        fruitColor = [UIColor colorWithRed:(224/255.0) green:(130/255.0) blue:(131/255.0) alpha:1.0];
        grainColor = [UIColor colorWithRed:(254/255.0) green:(201/255.0) blue:(86/255.0) alpha:1.0];
        proteinColor = [UIColor colorWithRed:(179/255.0) green:(136/255.0) blue:(221/255.0) alpha:1.0];
        veggieColor = [UIColor colorWithRed:(163/255.0) green:(215/255.0) blue:(112/255.0) alpha:1.0];
        dairyColor = [UIColor colorWithRed:(137/255.0) green:(196/255.0) blue:(244/255.0) alpha:1.0];
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
    
    // Background
    CGContextSetLineWidth(ctx, 2);
    if ([[FoodStore sharedStore] getTotalServings] > 0) {
        CGContextSetRGBFillColor(ctx, (70/255.0), (70/255.0), (70/255.0), 1.0);
    }
    else {
        CGContextSetRGBFillColor(ctx, (70/255.0), (70/255.0), (70/255.0), 0.1);
    }
    
    CGContextAddArc(ctx, center.x, center.y, (bounds.size.width/2.0)-1, 0.0, M_PI*2.0, YES);
    CGContextFillPath(ctx);
    
//    NSArray *foodServings = [[FoodStore sharedStore] getFoodLevels];
//    int size = foodServings.count;
//    CGFloat totalServings = 0;
//    for (int i = 0; i < size; i++) {
//        NSNumber *number = [foodServings objectAtIndex:i];
//        totalServings += number.floatValue;
//    }
    
    CGContextSetLineWidth(ctx, 1);
    CGContextSetRGBStrokeColor(ctx, (70/255.0), (70/255.0), (70/255.0), 0.1);
//    CGContextMoveToPoint(ctx, x, y);
//    CGContextSetRGBStrokeColor(ctx, (218/255.0), (218/255.0), (218/255.0), 1.0);
//    CGContextSetRGBStrokeColor(ctx, (70/255.0), (70/255.0), (70/255.0), 1.0);
    CGFloat percent, degree, startAngle, endAngle;
    startAngle = M_PI/2.0;
    for (int i = 0; i < 6; i++) {
        // Get food group
//        if (i != 0) {
//            continue;
//        }
        percent = 0;
        switch (i) {
            case 0:
                percent = [[FoodStore sharedStore] getFruitPercent];
                CGContextSetRGBFillColor(ctx, (224/255.0), (130/255.0), (131/255.0), 1);
                break;
            case 1:
                percent = [[FoodStore sharedStore] getGrainPercent];
                CGContextSetRGBFillColor(ctx, (254/255.0), (201/255.0), (86/255.0), 1);
                break;
            case 2:
                percent = [[FoodStore sharedStore] getDairyPercent];
                CGContextSetRGBFillColor(ctx, (137/255.0), (196/255.0), (244/255.0), 1);
                break;
            case 3:
                percent = [[FoodStore sharedStore] getVeggiePercent];
                CGContextSetRGBFillColor(ctx, (163/255.0), (215/255.0), (112/255.0), 1);
                break;
            case 4:
                percent = [[FoodStore sharedStore] getJunkPercent];
                CGContextSetRGBFillColor(ctx, (70/255.0), (70/255.0), (70/255.0), 1);
                break;
            case 5:
                percent = [[FoodStore sharedStore] getProteinPercent];
                CGContextSetRGBFillColor(ctx, (179/255.0), (136/255.0), (221/255.0), 1);
                break;
        }
        
        // Measure of percentage on pie chart
        if (percent == 0) {
            continue;
        }
        percent /= 100.0;
        degree = percent * 360;
        endAngle = startAngle + (degree * (M_PI/180.0));
        
        // Fill the pie slice
        CGContextAddArc(ctx, center.x, center.y, (bounds.size.width/2.0)-3, startAngle, endAngle, NO);
        CGContextAddLineToPoint(ctx, x, y);
        CGContextFillPath(ctx);
        
        
        // Increment Loop Values
        startAngle = endAngle;
    }
}

@end
