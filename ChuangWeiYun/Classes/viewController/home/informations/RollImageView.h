//
//  RollImageView.h
//  cw
//
//  Created by yunlai on 13-12-7.
//
//

#import <UIKit/UIKit.h>

@class AudioStreamer;

@interface RollImageView : UIImageView
{
    NSTimer *timer;
    UIButton *playBtn;
    int playState;
    UIImageView *slideImgView;
    UISlider* slider;
    BOOL isClick;
    AudioStreamer *streamer;
}

@property (retain, nonatomic) NSURL *url;

@property (retain, nonatomic) AudioStreamer *streamer;

- (void)setPlayer:(int)type;

@end
