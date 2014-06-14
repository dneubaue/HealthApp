//
//  AlertView.h
//  HealthApp
//
//  Created by David Neubauer on 5/25/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlertView;

@protocol AlertViewDelegate <NSObject>

@required
- (void)userTappedCancel:(AlertView *)alertView;
- (void)userTappedOther:(AlertView *)alertView;

@end

@interface AlertView : UIView
{
    UITextField *textField;
    id<AlertViewDelegate> delegate;
}
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) id<AlertViewDelegate> delegate;

- (void)setTitle:(NSString *)text;
- (void)setPlaceholder:(NSString *)text;
- (void)setOtherButtonTitle:(NSString *)text;
- (void)setKeyboardType:(UIKeyboardType)type;

@end
