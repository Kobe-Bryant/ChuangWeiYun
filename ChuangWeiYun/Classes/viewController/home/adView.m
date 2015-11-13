//
//  adView.m
//  cw
//
//  Created by siphp on 13-08-05.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "adView.h"
#import "myImageView.h"

@implementation adView

@synthesize picView = _picView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //图片
        myImageView *tempPicView = [[myImageView alloc] initWithFrame:self.bounds withImageId:@"0"];
        self.picView = tempPicView;
        [self addSubview:self.picView];
        [tempPicView release];
        
//        UILabel *tempDescLabel = [[UILabel alloc] initWithFrame:CGRectMake( 0.0f , self.frame.size.height - 30.0f , self.frame.size.width , 30.0f )];
//        tempDescLabel.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
//        tempDescLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
//        tempDescLabel.font = [UIFont systemFontOfSize:12];
//        tempDescLabel.textColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
//        tempDescLabel.textAlignment = UITextAlignmentLeft;
//        tempDescLabel.numberOfLines = 1;
//        self.descLabel = tempDescLabel;
//        [tempDescLabel release];
//        
//        [self addSubview:self.descLabel];
        
        
    }
    return self;
}

- (void)dealloc {
    self.picView = nil;
    [super dealloc];
}


@end
