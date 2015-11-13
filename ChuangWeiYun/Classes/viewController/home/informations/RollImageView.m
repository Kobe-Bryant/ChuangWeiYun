//
//  RollImageView.m
//  cw
//
//  Created by yunlai on 13-12-7.
//
//

#import "RollImageView.h"
#import "Common.h"
#import "AudioStreamer.h"

#define BgImgViewWidth      220.f
#define BgImgViewHeight     4.f

@implementation RollImageView

@synthesize url;
@synthesize streamer;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        
        playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        playBtn.frame = CGRectMake(0.f, 0.f, 40.f, 40.f);
        [playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:playBtn];
        
        UIImageView *bgImgView = [[UIImageView alloc]initWithFrame:CGRectMake(55.f, 18.f, BgImgViewWidth, BgImgViewHeight)];
        bgImgView.image = [UIImage imageCwNamed:@"pic_music_bar.png"];
        [self addSubview:bgImgView];
        [bgImgView release], bgImgView = nil;
        
        slider = [[UISlider alloc] initWithFrame:CGRectMake(55.f, 8.f, BgImgViewWidth, 0.f)];
		//slider.continuous = YES;
        slider.backgroundColor = [UIColor clearColor];
        UIImage *img = [UIImage imageCwNamed:@"pic_music_bar.png"];
        [slider setThumbImage:[UIImage imageCwNamed:@"pic_music_color.png"] forState: UIControlStateNormal];
        [slider setMinimumTrackImage:img forState:UIControlStateNormal];
        [slider setMaximumTrackImage:img forState:UIControlStateNormal];
        [self addSubview:slider];
        
        slideImgView = [[UIImageView alloc]initWithFrame:CGRectZero];
        slideImgView.image = [UIImage imageCwNamed:@"pic_music_color.png"];
        [self addSubview:slideImgView];
        
        self.playState = 0;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"rollimageView dealloc.....");
    [slider release], slider = nil;
    [slideImgView release], slideImgView = nil;
    
    [timer invalidate];
    timer = nil;
    
    playBtn = nil;
    
    if (streamer) {
        if ([streamer isPlaying]) {
            [streamer pause];
        }
        [self stop];
        [streamer release], streamer = nil;
    }

    [super dealloc];
}

- (void)setPlayState:(int)aplayState
{
    playState = aplayState;
    if (playState == 0) {
        [playBtn setImage:[UIImage imageCwNamed:@"icon_music_play.png"] forState:UIControlStateNormal];
    } else {
        [playBtn setImage:[UIImage imageCwNamed:@"icon_music_stop.png"] forState:UIControlStateNormal];
    }
}

- (void)setSlideColorWidth:(CGFloat)width
{
    CGFloat wid = 0.f;
    
    if (streamer.duration != 0.000000) {
        wid = BgImgViewWidth / streamer.duration * width;
    }

    slideImgView.frame = CGRectMake(55.f, 18.f, wid, BgImgViewHeight);
}

- (void)playBtnClick:(UIButton *)btn
{
    [self play];
}

// type 为0 不需要释放streamer 其他值释放
- (void)setPlayer:(int)type
{
    if (streamer && [streamer isPlaying]) {
        [streamer pause];
    }
    
    if (type == 0) {
        [self setSlideColorWidth:0];
        slider.value = 0;
        [self stop];
        if (streamer) {
            [streamer release], streamer = nil;
        }
    } 
}

- (BOOL)isProcessing
{
    return [streamer isPlaying] || [streamer isWaiting] || [streamer isFinishing] ;
}

- (void)play
{
    if (!streamer) {
        
        self.streamer = [[AudioStreamer alloc] initWithURL:self.url];
        
        // set up display updater
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                    [self methodSignatureForSelector:@selector(updateProgress)]];
        [invocation setSelector:@selector(updateProgress)];
        [invocation setTarget:self];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                             invocation:invocation
                                                repeats:YES];
        
        // register the streamer on notification 
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playbackStateChanged:)
                                                     name:ASStatusChangedNotification
                                                   object:streamer];
    }
    
    if ([streamer isPlaying] || [streamer isWaiting]) {
        [streamer pause];
    } else {
        [streamer start];
    }
}


- (void)stop
{
    slider.value = 0;
    self.playState = 0;

    // release streamer
	if (streamer)
	{
		[streamer stop];
		[streamer release];
		streamer = nil;
        
        // remove notification observer for streamer
		[[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:ASStatusChangedNotification
                                                      object:streamer];
	}
}

- (void)updateProgress
{
    if (streamer.progress <= streamer.duration ) {
        slider.minimumValue = 0;
        slider.maximumValue = streamer.duration;
        
        [self setSlideColorWidth:slider.value];
        slider.value = streamer.progress;
    } else {
        [self setSlideColorWidth:0];
        slider.value = 0;
    }
}

/*
 *  observe the notification listener when loading an audio
 */
- (void)playbackStateChanged:(NSNotification *)notification
{
	if ([streamer isWaiting]) {
        self.playState = 1;
    } else if ([streamer isIdle]) {
        self.playState = 0;
		[self stop];
	} else if ([streamer isPaused]) {
        self.playState = 0;
    } else if ([streamer isPlaying]) {
        self.playState = 1;
	} else if ([streamer isFinishing]){
        self.playState = 0;
    }
}

@end
