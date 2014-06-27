//
//  AddFoodViewController.h
//  HealthApp
//
//  Created by David Neubauer on 5/11/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddFoodViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,
                                                     UITextFieldDelegate, UISearchBarDelegate,
                                                     UIAlertViewDelegate>
{
    UIViewController *parent_VC;
}
@property (nonatomic, strong) UIViewController *parent_VC;

- (void)setMeal:(int)mealNumber;

@end
