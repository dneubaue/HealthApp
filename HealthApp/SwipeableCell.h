//
//  SwipeableCell.h
//  HealthApp
//
//  Created by David Neubauer on 5/6/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SwipeableCell;

@protocol SwipeableCellDelegate <NSObject>

@required
- (void)taskCompleted:(SwipeableCell *)cell;
- (void)deleteTask:(SwipeableCell *)cell;

@end

@interface SwipeableCell : UITableViewCell
{
    id <SwipeableCellDelegate> delegate;
}

@property (strong, nonatomic) id <SwipeableCellDelegate> delegate;

@end
