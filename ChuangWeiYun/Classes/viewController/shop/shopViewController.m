//
//  shopViewController.m
//  cw
//
//  Created by siphp on 13-8-7.
//
//

#import "shopViewController.h"

@interface shopViewController ()

@end

@implementation shopViewController

- (id)initWithFrontViewController:(UIViewController *)aFrontViewController rearViewController:(UIViewController *)aBackViewController
{
	self = [super initWithFrontViewController:aFrontViewController rearViewController:aBackViewController];
	
	if (nil != self) {
		self.delegate = self;
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (BOOL)revealController:(SideSlipViewController *)revealController shouldRevealRearViewController:(UIViewController *)rearViewController
{
	return YES;
}

- (BOOL)revealController:(SideSlipViewController *)revealController shouldHideRearViewController:(UIViewController *)rearViewController
{
	return YES;
}

- (void)revealController:(SideSlipViewController *)revealController didRevealRearViewController:(UIViewController *)rearViewController
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateLeft" object:nil];
	NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(SideSlipViewController *)revealController didHideRearViewController:(UIViewController *)rearViewController
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateRight" object:nil];
	NSLog(@"%@", NSStringFromSelector(_cmd));
}
@end
