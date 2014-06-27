//
//  OverviewViewController.h
//  HealthApp
//
//  Created by David Neubauer on 5/4/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"

@interface OverviewViewController : UIViewController <MainViewControllerDelegate>
{
    id <SideViewControllerDelegate> delegate;
}
@property (nonatomic, strong) id <SideViewControllerDelegate> delegate;

@end
