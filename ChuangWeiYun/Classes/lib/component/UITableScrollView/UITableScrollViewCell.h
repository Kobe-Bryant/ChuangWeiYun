//
//  UITableScrollViewCell.h
//  scrollview
//
//  Created by yunlai on 13-8-16.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableScrollViewCell : UIView
{
    NSInteger index;
}

@property (assign, nonatomic) NSInteger index;

- (void)createView;

@end
