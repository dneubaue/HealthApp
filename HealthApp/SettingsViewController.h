//
//  SettingsViewController.h
//  HealthApp
//
//  Created by David Neubauer on 6/15/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "AlertViewNoTextField.h"

@interface SettingsViewController : UIViewController <MainViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, AlertViewNoTextFieldDelegate>
{
    id <SideViewControllerDelegate> delegate;
}
@property (nonatomic, strong) id <SideViewControllerDelegate> delegate;
@end
