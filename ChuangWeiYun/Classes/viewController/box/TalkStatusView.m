//
//  TalkStatusView.m
//  TestTalkToLuohui
//
//  Created by meng on 13-10-12.
//  Copyright (c) 2013年 meng. All rights reserved.
//

#import "TalkStatusView.h"

@implementation TalkStatusView
@synthesize talkStatus = _talkStatus;
@synthesize myImageView = _myImageView;
@synthesize count       = _count;
@synthesize isRounding  = _isRounding;
@synthesize timer       = _timer;
@synthesize currentTime = _currentTime;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _myImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_myImageView];
        UITapGestureRecognizer *TapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom)];
        
        [_myImageView addGestureRecognizer:TapRecognizer];
         _myImageView.userInteractionEnabled = YES;
        
        _talkStatus = TALKSUCCESS;
    }
    
    return self;
}

- (void)handleTapFrom
{
    if (_talkStatus == TALKFAILD) {
        [self setCurrectStatus:TALKISSENDING];
        [_delegate reSendaTalk:_currentTime];
    }
}

- (void)setCurrectStatus:(int)status
{
    switch (status) {
        case TALKSUCCESS:
        {
            [self talkSuccess];
        }
            break;
        case TALKFAILD:
        {
            [self talkFaild];
            
        }
            break;
        case TALKISSENDING:
        {
            [self isSendingTalk];
            
        }
            break;
        case TALKINIT:
        {
            [self talkSuccess];
            
        }
            break;
            
        default:
            break;
    }
}

- (void)isSendingTalk
{
    _talkStatus = TALKISSENDING;
    _myImageView.hidden = NO;
    _myImageView.image = [UIImage imageNamed:@"loading_fail_feedback.png"];
    _timer =  [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(Round) userInfo:nil repeats:YES];
}

- (void)talkSuccess
{
    _talkStatus = TALKFAILD;
    _myImageView.hidden = NO;
    [_timer invalidate];
    _timer = nil;
    CGFloat angle = 0*(M_PI/180.0f);
    CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
    CGAffineTransform scaled = CGAffineTransformScale(transform, 1, 1);
    [_myImageView setTransform:scaled];
    _myImageView.image = [UIImage imageNamed:@""];

}

- (void)talkFaild
{
    _talkStatus = TALKFAILD;
    _myImageView.hidden = NO;
    [_timer invalidate];
    _timer = nil;
    CGFloat angle = 0*(M_PI/180.0f);
    CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
    CGAffineTransform scaled = CGAffineTransformScale(transform, 1, 1);
    [_myImageView setTransform:scaled];
    _myImageView.image = [UIImage imageNamed:@"refresh_fail_feedback.png"];
}

- (void)Round
{
    
    if (_count > 18)
    {
        _count = 1;
    }
    
    CGFloat angle = _count*20 *(M_PI/180.0f);
    CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
    CGAffineTransform scaled = CGAffineTransformScale(transform, 1, 1);
    
    [_myImageView setTransform:scaled];
    _count++;
    
}

- (void)dealloc
{
    [_myImageView release];
    [super dealloc];
}
@end
