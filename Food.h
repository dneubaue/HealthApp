//
//  Food.h
//  HealthApp
//
//  Created by David Neubauer on 4/5/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Food : NSObject <NSCoding>
{
    NSString *name;
    NSString *meal;
    NSMutableArray *foodGroups;
}
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *meal;
@property (strong, nonatomic) NSMutableArray *foodGroups;

@end
