//
//  NavigationButton.h
//  HealthApp
//
//  Created by David Neubauer on 5/24/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationButton : UIView
{
    
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
- (void)toggleRotation;
- (void)moveToOpen;

@end
