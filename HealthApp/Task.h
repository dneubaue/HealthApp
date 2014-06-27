//
//  Task.h
//  HealthApp
//
//  Created by David Neubauer on 4/4/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Task : NSObject <NSCoding>
{
    NSString *description;
    NSDate *date;
}
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSDate *date;

@end
