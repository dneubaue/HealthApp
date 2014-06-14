//
//  ChooseMealViewController.h
//  HealthApp
//
//  Created by David Neubauer on 5/26/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseMealViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    UIViewController *parent_VC;
}
@property (nonatomic, strong) UIViewController *parent_VC;

@end
