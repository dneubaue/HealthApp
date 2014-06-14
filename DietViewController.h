//
//  DietViewController.h
//  HealthApp
//
//  Created by David Neubauer on 4/5/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface DietViewController : UIViewController <MainViewControllerDelegate, UITableViewDelegate,
                                                  UITableViewDataSource, UIScrollViewDelegate>
{
    id <SideViewControllerDelegate> delegate;
}
@property (strong, nonatomic) id <SideViewControllerDelegate> delegate;

@end
