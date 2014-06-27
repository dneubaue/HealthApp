//
//  TableCell.m
//  HealthApp
//
//  Created by David Neubauer on 5/24/14.
//  Copyright (c) 2014 David Neubauer. All rights reserved.
//

#import "TableCell.h"

@implementation TableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self.textLabel setTextColor:[UIColor colorWithRed:(70/255.0)
                                                     green:(70/255.0)
                                                      blue:(70/255.0)
                                                     alpha:1.0]];
        [self.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin"
                                                size:22.0]];
        
        [self.detailTextLabel setTextColor:[UIColor colorWithRed:(70/255.0)
                                                     green:(70/255.0)
                                                      blue:(70/255.0)
                                                     alpha:1.0]];
        [self.detailTextLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Thin"
                                                size:18.0]];
        
        [self setBackgroundColor:[UIColor colorWithRed:(218/255.0)
                                                 green:(218/255.0)
                                                  blue:(218/255.0)
                                                 alpha:1.0]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
