//
//  AlertViewNoTextField.h
//  HealthApp
//
//  Created by David Neubauer on 5/26/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlertView.h"

@class AlertViewNoTextField;

@protocol AlertViewNoTextFieldDelegate <NSObject>

@required
- (void)userTappedOkay:(AlertViewNoTextField *)alertView;

@end


@interface AlertViewNoTextField : UIView
{
    id<AlertViewNoTextFieldDelegate> delegate;
}
@property (nonatomic, strong) id<AlertViewNoTextFieldDelegate> delegate;

- (void)setTitle:(NSString *)text;

@end
