//
//  PfAdImageCell.m
//  cw
//
//  Created by yunlai on 13-8-27.
//
//

#import "PfAdImageCell.h"
#import "Common.h"
#import "FileManager.h"
#import "IconPictureProcess.h"

#define PfAdImageH      180.f

@implementation PfAdImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _scrollView = [[SingleScrollView alloc] initWithFrame:CGRectMake(0.0f , 0.0f , KUIScreenWidth , PfAdImageH)];
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        
        picArr = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"pfadimagecell dealloc........");
    [_scrollView release], _scrollView = nil;
    [picArr release], picArr = nil;
    if (CWPview) {
        [CWPview release], CWPview = nil;
    }

    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setCellContentAndFrame:(NSMutableArray *)arr
{
    [picArr removeAllObjects];
    [picArr addObjectsFromArray:arr];
    [_scrollView reloadScrollView];
}

- (void)scrollinvalidate
{
    [_scrollView invalidateSingle];
}

+ (CGFloat)getCellHeight
{
    return PfAdImageH;
}

#pragma mark - SingleScrollViewDelegate
- (NSInteger)numberOfPagesSingle:(SingleScrollView *)singleScrollView
{
    return picArr.count;
}

- (CWImageView *)pageSingleReturnEachView:(SingleScrollView *)singleScrollView pageIndex:(NSInteger)index
{
    CWImageView *view = [[[CWImageView alloc]initWithFrame:CGRectMake(index*KUIScreenWidth , 0.f , KUIScreenWidth , PfAdImageH)] autorelease];

    NSDictionary *adDic = [picArr objectAtIndex:index];
    
    //图片
    view.delegate = self;
    
    NSString *picUrl = [adDic objectForKey:@"thumb_pic"];
    NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
    
    if (picUrl.length > 1) {
        UIImage *pic = [FileManager getPhoto:picName];
        CGSize size = [UIImage fitsize:pic.size size:CGSizeMake(KUIScreenWidth, PfAdImageH)];
        CGFloat x = index*KUIScreenWidth + (KUIScreenWidth-size.width) / 2;
        CGFloat y = (PfAdImageH - size.height) / 2;
        view.frame = CGRectMake(x, y, size.width, size.height);
        if (pic.size.width > 2) {
            view.image = pic;
        } else {
            UIImage *defaultPic = [UIImage imageCwNamed:@"default_320x180.png"];
            view.image = defaultPic;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:30000];
            [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:indexPath delegate:self];
        }
    } else {
        UIImage *defaultPic = [UIImage imageCwNamed:@"default_320x180.png"];
        view.image = defaultPic;
    }
    
    return view;
}

#pragma mark - IconDownloaderDelegate
- (void)appImageDidLoad:(NSString *)url withImageType:(int)Type
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        IconDownLoader *iconDownloader = [[IconPictureProcess sharedPictureProcess].imageDownloadsInProgress objectForKey:url];
        if (iconDownloader != nil)
        {
            if(iconDownloader.cardIcon.size.width > 2.0)
            {
                //保存图片
                [[IconPictureProcess sharedPictureProcess] savePhoto:iconDownloader.cardIcon url:url];

                dispatch_async(dispatch_get_main_queue(), ^{
                    [_scrollView reloadScrollViewImage:iconDownloader.cardIcon index:iconDownloader.indexPathInTableView.row];
                });
            }
            
            [[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:url];
        }
    });
}
- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type {}
#pragma mark - CWImageViewDelegate
- (void)touchCWImageView:(CWImageView *)imageView
{
    if (CWPview == nil) {
        CWPview = [[CWPictureView alloc]initWithclickIndex:imageView.tag];
    } else {
        CWPview.selectIndex = imageView.tag;
    }

    CWPview.delegate = self;
    
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
    for (id view in _scrollView.scrollView.subviews) {
        if ([view isKindOfClass:[CWImageView class]]) {
            [arr addObject:view];
        }
    }
    
    CWPview.CwPictureViewClose = ^ {
        //[CWPview release], CWPview = nil;
    };
    
    [CWPview setPictureView:arr];
}

#pragma mark - CWPictureViewDelegate
- (void)cwPictureViewSetPage:(int)page
{
    [_scrollView setCurrentPage:page];
}
@end
