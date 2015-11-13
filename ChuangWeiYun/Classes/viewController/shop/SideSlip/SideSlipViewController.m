//
//  SideSlipViewController.m
//  SideSlip
//
//  Created by yunlai on 13-8-5.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SideSlipViewController.h"

#define REVEAL_EDGE 260.0f
#define REVEAL_EDGE_OVERDRAW 60.0f
#define REVEAL_VIEW_TRIGGER_LEVEL_LEFT 125.0f
#define REVEAL_VIEW_TRIGGER_LEVEL_RIGHT 200.0f
#define VELOCITY_REQUIRED_FOR_QUICK_FLICK 1300.0f

@interface SideSlipViewController ()

@property (retain, nonatomic) UIView *frontView;
@property (retain, nonatomic) UIView *rearView;
@property (assign, nonatomic) float previousPanOffset;

- (CGFloat)_calculateOffsetForTranslationInView:(CGFloat)x;
- (void)_revealAnimation;
- (void)_concealAnimation;

- (void)_addFrontViewControllerToHierarchy:(UIViewController *)frontViewController;
- (void)_addRearViewControllerToHierarchy:(UIViewController *)rearViewController;
- (void)_removeFrontViewControllerFromHierarchy:(UIViewController *)frontViewController;
- (void)_removeRearViewControllerFromHierarchy:(UIViewController *)rearViewController;

@end

@implementation SideSlipViewController

@synthesize previousPanOffset = _previousPanOffset;
@synthesize currentFrontViewPosition = _currentFrontViewPosition;
@synthesize frontViewController = _frontViewController;
@synthesize rearViewController = _rearViewController;
@synthesize frontView = _frontView;
@synthesize rearView = _rearView;
@synthesize delegate = _delegate;

- (id)initWithFrontViewController:(UIViewController *)aFrontViewController rearViewController:(UIViewController *)aBackViewController
{
	self = [super init];
	
	if (nil != self)
	{
		_frontViewController = [aFrontViewController retain];
		_rearViewController = [aBackViewController retain];
	}
	
	return self;
}

#pragma mark - Reveal Callbacks

- (void)tapGesture:(UITapGestureRecognizer *)recognizer
{
    if (FrontViewPositionLeft == self.currentFrontViewPosition) {
		if ([self.delegate respondsToSelector:@selector(revealController:shouldRevealRearViewController:)]) {
			if (![self.delegate revealController:self shouldRevealRearViewController:self.rearViewController]) {
				return;
			}
		}
		
		if ([self.delegate respondsToSelector:@selector(revealController:willRevealRearViewController:)]) {
			[self.delegate revealController:self willRevealRearViewController:self.rearViewController];
		}
		
		[self _revealAnimation];
		
		self.currentFrontViewPosition = FrontViewPositionRight;
	} else {
		if ([self.delegate respondsToSelector:@selector(revealController:shouldHideRearViewController:)]) {
			if (![self.delegate revealController:self shouldHideRearViewController:self.rearViewController]) {
				return;
			}
		}
        
		if ([self.delegate respondsToSelector:@selector(revealController:willHideRearViewController:)]) {
			[self.delegate revealController:self willHideRearViewController:self.rearViewController];
		}
		
		[self _concealAnimation];
		
		self.currentFrontViewPosition = FrontViewPositionLeft;
	}
}

- (void)revealGesture:(UIPanGestureRecognizer *)recognizer
{
	if ([self.delegate conformsToProtocol:@protocol(SideSlipViewControllerDelegate)]) {
		if (FrontViewPositionLeft == self.currentFrontViewPosition) {
			if ([self.delegate respondsToSelector:@selector(revealController:shouldRevealRearViewController:)]) {
				if (![self.delegate revealController:self shouldRevealRearViewController:self.rearViewController]) {
					return;
				}
			}
		} else {
			if ([self.delegate respondsToSelector:@selector(revealController:shouldHideRearViewController:)]) {
				if (![self.delegate revealController:self shouldHideRearViewController:self.rearViewController]) {
					return;
				}
			}
		}
	}
	
	if (UIGestureRecognizerStateBegan == [recognizer state]) {
		if ([self.delegate conformsToProtocol:@protocol(SideSlipViewControllerDelegate)]) {
			if (FrontViewPositionLeft == self.currentFrontViewPosition) {
				if ([self.delegate respondsToSelector:@selector(revealController:willRevealRearViewController:)]) {
					[self.delegate revealController:self willRevealRearViewController:self.rearViewController];
				}
			} else {
				if ([self.delegate respondsToSelector:@selector(revealController:willHideRearViewController:)]) {
					[self.delegate revealController:self willHideRearViewController:self.rearViewController];
				}
			}
		}
	}

	if (UIGestureRecognizerStateEnded == [recognizer state]) {
		if (fabs([recognizer velocityInView:self.view].x) > VELOCITY_REQUIRED_FOR_QUICK_FLICK) {
			if ([recognizer velocityInView:self.view].x > 0.0f) {
				[self _revealAnimation];
			} else {
				[self _concealAnimation];
			}
		} else {
			float dynamicTriggerLevel = (FrontViewPositionLeft == self.currentFrontViewPosition) ? REVEAL_VIEW_TRIGGER_LEVEL_LEFT : REVEAL_VIEW_TRIGGER_LEVEL_RIGHT;
			
			if (self.frontView.frame.origin.x >= dynamicTriggerLevel && self.frontView.frame.origin.x != REVEAL_EDGE) {
				[self _revealAnimation];
			} else if (self.frontView.frame.origin.x < dynamicTriggerLevel && self.frontView.frame.origin.x != 0.0f) {
				[self _concealAnimation];
			}
		}
		
		if (self.frontView.frame.origin.x == 0.0f) {
			self.currentFrontViewPosition = FrontViewPositionLeft;
		} else {
			self.currentFrontViewPosition = FrontViewPositionRight;
		}
		
		return;
	}
	
	if (FrontViewPositionLeft == self.currentFrontViewPosition) {
		if ([recognizer translationInView:self.view].x < 0.0f) {
			self.frontView.frame = CGRectMake(0.0f, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
		} else {
			float offset = [self _calculateOffsetForTranslationInView:[recognizer translationInView:self.view].x];
			self.frontView.frame = CGRectMake(offset, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
		}
	} else {
		if ([recognizer translationInView:self.view].x > 0.0f) {
			float offset = [self _calculateOffsetForTranslationInView:([recognizer translationInView:self.view].x+REVEAL_EDGE)];
			self.frontView.frame = CGRectMake(offset, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
		} else if ([recognizer translationInView:self.view].x > -REVEAL_EDGE) {
			self.frontView.frame = CGRectMake([recognizer translationInView:self.view].x+REVEAL_EDGE, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
		} else {
			self.frontView.frame = CGRectMake(0.0f, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
		}
	}
}

- (void)revealToggle:(id)sender
{
	if (FrontViewPositionLeft == self.currentFrontViewPosition) {
		if ([self.delegate respondsToSelector:@selector(revealController:shouldRevealRearViewController:)]) {
			if (![self.delegate revealController:self shouldRevealRearViewController:self.rearViewController]) {
				return;
			}
		}
		
		if ([self.delegate respondsToSelector:@selector(revealController:willRevealRearViewController:)]) {
			[self.delegate revealController:self willRevealRearViewController:self.rearViewController];
		}
		
		[self _revealAnimation];
		
		self.currentFrontViewPosition = FrontViewPositionRight;
	} else {
		if ([self.delegate respondsToSelector:@selector(revealController:shouldHideRearViewController:)]) {
			if (![self.delegate revealController:self shouldHideRearViewController:self.rearViewController]) {
				return;
			}
		}

		if ([self.delegate respondsToSelector:@selector(revealController:willHideRearViewController:)]) {
			[self.delegate revealController:self willHideRearViewController:self.rearViewController];
		}
		
		[self _concealAnimation];
		
		self.currentFrontViewPosition = FrontViewPositionLeft;
	}
}

#pragma mark - Helper

- (void)_revealAnimation
{
	[UIView animateWithDuration:0.25f animations:^ {
         self.frontView.frame = CGRectMake(REVEAL_EDGE, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
    } completion:^(BOOL finished) {
         if ([self.delegate respondsToSelector:@selector(revealController:didRevealRearViewController:)]) {
             [self.delegate revealController:self didRevealRearViewController:self.rearViewController];
         }
    }];
}

- (void)_concealAnimation
{
	[UIView animateWithDuration:0.25f animations:^ {
         self.frontView.frame = CGRectMake(0.0f, 0.0f, self.frontView.frame.size.width, self.frontView.frame.size.height);
    } completion:^(BOOL finished) {
         if ([self.delegate respondsToSelector:@selector(revealController:didHideRearViewController:)]) {
             [self.delegate revealController:self didHideRearViewController:self.rearViewController];
         }
    }];
}

- (CGFloat)_calculateOffsetForTranslationInView:(CGFloat)x
{
	CGFloat result;
	
	if (x <= REVEAL_EDGE) {
		result = x;
	} else if (x <= REVEAL_EDGE+(M_PI*REVEAL_EDGE_OVERDRAW/2.0f)) {
		result = REVEAL_EDGE_OVERDRAW*sin((x-REVEAL_EDGE)/REVEAL_EDGE_OVERDRAW)+REVEAL_EDGE;
	} else {
		result = REVEAL_EDGE+REVEAL_EDGE_OVERDRAW;
	}
	
	return result;
}
- (void)_addFrontViewControllerToHierarchy:(UIViewController *)frontViewController
{
	[self addChildViewController:frontViewController];
	[self.frontView addSubview:frontViewController.view];
    
	if ([frontViewController respondsToSelector:@selector(didMoveToParentViewController:)]) {
		[frontViewController didMoveToParentViewController:self];
	}
}

- (void)_addRearViewControllerToHierarchy:(UIViewController *)rearViewController
{
	[self addChildViewController:rearViewController];
	[self.rearView addSubview:rearViewController.view];
    
	if ([rearViewController respondsToSelector:@selector(didMoveToParentViewController:)]) {
		[rearViewController didMoveToParentViewController:self];
	}
}

- (void)_removeFrontViewControllerFromHierarchy:(UIViewController *)frontViewController
{
	[frontViewController.view removeFromSuperview];
	if ([frontViewController respondsToSelector:@selector(removeFromParentViewController:)]) {
		[frontViewController removeFromParentViewController];
	}
}

- (void)_removeRearViewControllerFromHierarchy:(UIViewController *)rearViewController
{
	[rearViewController.view removeFromSuperview];
	if ([rearViewController respondsToSelector:@selector(removeFromParentViewController:)]) {
		[rearViewController removeFromParentViewController];
	}
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.frontView = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
	self.rearView = [[[UIView alloc] initWithFrame:self.view.bounds] autorelease];
	
	self.frontView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	self.rearView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	
	[self.view addSubview:self.rearView];
	[self.view addSubview:self.frontView];
	
    // 创建阴影
	UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.frontView.bounds];
	self.frontView.layer.masksToBounds = NO;
	self.frontView.layer.shadowColor = [UIColor blackColor].CGColor;
	self.frontView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
	self.frontView.layer.shadowOpacity = 1.0f;
	self.frontView.layer.shadowRadius = 2.5f;
	self.frontView.layer.shadowPath = shadowPath.CGPath;
	
	self.previousPanOffset = 0.0f;
	self.currentFrontViewPosition = FrontViewPositionLeft;
	
	[self _addRearViewControllerToHierarchy:self.rearViewController];
	[self _addFrontViewControllerToHierarchy:self.frontViewController];
}

- (void)viewDidUnload
{
	[self _removeRearViewControllerFromHierarchy:self.rearViewController];
	[self _removeFrontViewControllerFromHierarchy:self.frontViewController];
	
	self.frontView = nil;
    self.rearView = nil;
}

- (void)dealloc
{
	[_frontViewController release], _frontViewController = nil;
	[_rearViewController release], _rearViewController = nil;
	[_frontView release], _frontView = nil;
	[_rearView release], _rearView = nil;
	[super dealloc];
}

@end
