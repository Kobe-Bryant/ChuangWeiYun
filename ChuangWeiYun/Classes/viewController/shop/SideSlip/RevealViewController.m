//
//  RevealViewController.m
//  SideSlip
//
//  Created by yunlai on 13-8-5.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import "RevealViewController.h"

@interface RevealViewController ()

@end

@implementation RevealViewController

- (id)initWithFrontViewController:(UIViewController *)aFrontViewController rearViewController:(UIViewController *)aBackViewController
{
	self = [super initWithFrontViewController:aFrontViewController rearViewController:aBackViewController];
	
	if (nil != self)
	{
		self.delegate = self;
	}
	
	return self;
}

- (BOOL)revealController:(SideSlipViewController *)revealController shouldRevealRearViewController:(UIViewController *)rearViewController
{
	return YES;
}

- (BOOL)revealController:(SideSlipViewController *)revealController shouldHideRearViewController:(UIViewController *)rearViewController
{
	return YES;
}

//- (void)revealController:(SideSlipViewController *)revealController willRevealRearViewController:(UIViewController *)rearViewController
//{
//	NSLog(@"%@", NSStringFromSelector(_cmd));
//}

- (void)revealController:(SideSlipViewController *)revealController didRevealRearViewController:(UIViewController *)rearViewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateLeft" object:nil];
	NSLog(@"%@", NSStringFromSelector(_cmd));
}

//- (void)revealController:(SideSlipViewController *)revealController willHideRearViewController:(UIViewController *)rearViewController
//{
//	NSLog(@"%@", NSStringFromSelector(_cmd));
//}

- (void)revealController:(SideSlipViewController *)revealController didHideRearViewController:(UIViewController *)rearViewController
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateRight" object:nil];
	NSLog(@"%@", NSStringFromSelector(_cmd));
}

@end
