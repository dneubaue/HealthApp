//
//  AddDietViewController.h
//  HealthApp
//
//  Created by David Neubauer on 4/5/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewFoodViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate,
                                                     UIPickerViewDataSource, UIPickerViewDelegate,
                                                     UITableViewDataSource, UITableViewDelegate>
{
    
}

- (void)setMealName:(NSString *)mealName;
- (void)setFoodName:(NSString *)name;

@end
