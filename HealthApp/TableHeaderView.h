//
//  TableHeaderView.h
//  HealthApp
//
//  Created by David Neubauer on 5/24/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableHeaderView : UIView
{
    UILabel *label;
}
@property (nonatomic, strong) UILabel *label;

- (id)initWithTitle:(NSString *)title;

@end
