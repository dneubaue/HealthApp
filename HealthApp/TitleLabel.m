//
//  TitleLabel.m
//  HealthApp
//
//  Created by David Neubauer on 5/24/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "TitleLabel.h"

@implementation TitleLabel

- (id)init
{
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(80, 20, 160, 44)];
        [self setTextAlignment:NSTextAlignmentCenter];
        [self setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:28.0]];
        [self setTextColor:[UIColor colorWithRed:(70/255.0) green:(70/255.0) blue:(70/255.0) alpha:1.0]];
    }
    return self;
}

@end
