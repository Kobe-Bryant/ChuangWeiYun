//
//  UITableScrollViewCell.m
//  scrollview
//
//  Created by yunlai on 13-8-16.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import "UITableScrollViewCell.h"

@implementation UITableScrollViewCell

@synthesize index;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)createView
{
}

- (void)dealloc
{
    NSLog(@"uitablescrollviewcell dealloc......");
    [super dealloc];
}

@end
