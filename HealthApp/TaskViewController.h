//
//  TaskViewController.h
//  HealthApp
//
//  Created by David Neubauer on 4/4/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface TaskViewController : UIViewController <MainViewControllerDelegate, UITableViewDataSource,
                                                  UITableViewDelegate, UIAlertViewDelegate>
{
    id <SideViewControllerDelegate> delegate;
}
@property (nonatomic, strong) id <SideViewControllerDelegate> delegate;

@end
