//
//  ActivityViewController.h
//  HealthApp
//
//  Created by David Neubauer on 4/2/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"


@interface ActivityViewController : UIViewController <MainViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>
{
    id <SideViewControllerDelegate> delegate;
}
@property (nonatomic, strong) id <SideViewControllerDelegate> delegate;

- (void)resetGraph;

@end
