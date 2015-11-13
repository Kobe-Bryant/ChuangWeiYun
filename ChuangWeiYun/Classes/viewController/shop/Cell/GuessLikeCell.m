//
//  GuessLikeCell.m
//  cw
//
//  Created by yunlai on 13-8-17.
//
//

#import "GuessLikeCell.h"
#import "XLCycleScrollView.h"
#import "Common.h"
#import "FileManager.h"
#import "adView.h"
#import "myImageView.h"
#import "IconPictureProcess.h"

#define KGuessLikeViewCellHeight  160.f

@implementation GuessLikeCell

@synthesize scrollView = _scrollView;
@synthesize picsArr;
@synthesize delegate;
@synthesize cwStatusType;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGFloat height = KCellUpW;
        
        _bgView = [[UIView alloc]initWithFrame:CGRectMake(KCellLeftW, KCellUpW, KUIScreenWidth-2*KCellLeftW, KGuessLikeViewCellHeight)];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.cornerRadius = 8.f;
        _bgView.layer.masksToBounds = YES;
        _bgView.layer.borderWidth = 0.3f;
        _bgView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        [self.contentView addSubview:_bgView];
        
        _imageV = [[UIImageView alloc]initWithFrame:CGRectMake(KCellLeftW, height, KCellSmallImageWH, KCellSmallImageWH)];
        _imageV.image = [UIImage imageCwNamed:@"icon_love_store.png"];
        [_bgView addSubview:_imageV];
        
        _label = [[UILabel alloc]initWithFrame:CGRectMake(KCellSmallImageWH+2*KCellLeftW, height, 100.f, 20.f)];
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = [UIColor blackColor];
        [_bgView addSubview:_label];
        
        height += 20.f + 5.f;
        
        _scrollView = [[XLCycleScrollView alloc] initWithFrame:CGRectMake(KCellUpW, height, KUIScreenWidth - 4*KCellUpW, KGuessLikeViewCellHeight - 2*KCellUpW - KCellSmallImageWH)];
        _scrollView.isAutoPlay = YES;
        _scrollView.isResponseTap = NO;
        _scrollView.delegate = self;
        _scrollView.datasource = self;
        [_bgView addSubview:_scrollView];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"GuessLikeCell...");
    [_imageV release], _imageV = nil;
    [_label release], _label = nil;
    [_bgView release], _bgView = nil;
    [_scrollView release], _scrollView = nil;
    self.picsArr = nil;
    
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setCellContentAndFrame:(NSMutableArray *)arr
{
    self.picsArr = arr;
    
    _label.text = @"相关活动";
    
    [_scrollView reloadData];
}

+ (CGFloat)getCellHeight
{
    return KGuessLikeViewCellHeight + 2*KCellUpW;
}

#pragma mark - XLCycleScrollViewDatasource
- (NSInteger)numberOfPages
{
    NSLog(@"self.picsArr count 111= %d",self.picsArr.count);
    return self.picsArr.count;
}

- (UIView *)pageAtIndex:(XLCycleScrollView *)xlcScrollView viewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    adView *view = [xlcScrollView dequeueReusableViewWithIndex:[indexPath section]];
    
    if (view == nil) {
        view = [[[adView alloc]initWithFrame:CGRectMake(0.f , 0.f , KUIScreenWidth - 4*KCellUpW, KGuessLikeViewCellHeight)] autorelease];
    }
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    NSDictionary *adDic = [self.picsArr objectAtIndex:[indexPath row]];
    
    //图片
    view.picView.mydelegate = self;
    view.picView.imageId = [NSString stringWithFormat:@"%d",[indexPath row]];
    
    NSString *picUrl = nil;
    if (cwStatusType == StatusTypePfDetail) {
        picUrl = [adDic objectForKey:@"img_path"]; 
    } else {
        picUrl = [adDic objectForKey:@"img"]; 
    }
    NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
    
    if (picUrl.length > 1) {
        UIImage *pic = [FileManager getPhoto:picName];
        if (pic.size.width > 2) {
            [view.picView stopSpinner];
            view.picView.image = pic;
        } else {
            UIImage *defaultPic = [UIImage imageCwNamed:@"default_320x180.png"];
            
            view.picView.image = defaultPic;
            [view.picView stopSpinner];
            [view.picView startSpinner];
            [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:indexPath delegate:self];
        }
    } else {
        UIImage *defaultPic = [UIImage imageCwNamed:@"default_320x180.png"];
        view.picView.image = defaultPic;
    }
    
    [pool release];
    
    return view;
}

// 图片加载
#pragma mark - IconDownloaderDelegate
- (void)appImageDidLoad:(NSString *)url withImageType:(int)Type
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        IconDownLoader *iconDownloader = [[IconPictureProcess sharedPictureProcess].imageDownloadsInProgress objectForKey:url];
        if (iconDownloader != nil)
        {
            if(iconDownloader.cardIcon.size.width > 2.0)
            {
                //保存图片
                [[IconPictureProcess sharedPictureProcess] savePhoto:iconDownloader.cardIcon url:url];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_scrollView reloadData];
                });
            }
            
            [[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:url];
        }
    });
    
    [pool release];
}
- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type {}
#pragma mark - myImageViewDelegate
- (void)imageViewTouchesEnd:(NSString *)imageId
{
    if ([delegate respondsToSelector:@selector(guessLikeCellClickImg:proID:)]) {
        
        NSDictionary *dict = [self.picsArr objectAtIndex:[imageId intValue]];
        NSLog(@"dict = %@",dict);
        NSString *pid = nil;
        if (cwStatusType == StatusTypePfDetail) {
            pid = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"preactivity_id"] intValue]];
        } else {
            pid = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"id"] intValue]]; //product_id
        }
        
        NSLog(@"pid = %@",pid);
        [delegate guessLikeCellClickImg:self proID:pid];
    }
}
@end
