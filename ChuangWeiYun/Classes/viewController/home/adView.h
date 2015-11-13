//
//  adView.h
//  cw
//
//  Created by siphp on 13-08-05.
//  Copyright 2012 __MyCompanyName__. All rights reserved.

#import <UIKit/UIKit.h>

@class myImageView;

@interface adView : UIView
{
	myImageView *_picView;
}
@property (nonatomic, retain) myImageView *picView;

@end
