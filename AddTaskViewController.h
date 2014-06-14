//
//  AddTaskViewController.h
//  HealthApp
//
//  Created by David Neubauer on 4/4/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;

@interface AddTaskViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    
}
- (id)initWithTask:(Task *)t;

@end
