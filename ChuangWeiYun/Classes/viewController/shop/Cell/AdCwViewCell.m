//
//  AdCwViewCell.m
//  cw
//
//  Created by yunlai on 13-8-17.
//
//

#import "AdCwViewCell.h"
#import "IconPictureProcess.h"
#import "shop_list_pics_model.h"
#import "Common.h"
#import "FileManager.h"
#import "productsCenter_list_pics_model.h"

#define KAdCwViewCellHeight     240.f

@implementation AdCwViewCell

@synthesize scrollViewC = _scrollViewC;
@synthesize picsArr;
@synthesize statusType;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _scrollViewC = [[SingleScrollView alloc] initWithFrame:CGRectMake(0.f,0.f, KUIScreenWidth, KAdCwViewCellHeight)];
        _scrollViewC.delegate = self;
        [self.contentView addSubview:_scrollViewC];
        
        _modelLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _modelLabel.backgroundColor = [UIColor colorWithRed:130.f/255.f green:130.f/255.f blue:130.f/255.f alpha:0.8f];
        _modelLabel.textColor = [UIColor whiteColor];
        _modelLabel.font = [UIFont systemFontOfSize:14.f];
        _modelLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_modelLabel];
        
        _maskView = [[UIView alloc]initWithFrame:CGRectZero];
        _maskView.frame = CGRectMake(0.f, CGRectGetMaxY(_scrollViewC.frame) - 30.f, KUIScreenWidth, 30.f);
        _maskView.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:0.3f];
        [self.contentView addSubview:_maskView];
        
        _likeImage = [[UIImageView alloc]initWithFrame:CGRectZero];
        _likeImage.image = [UIImage imageCwNamed:@"icon_like_store.png"];
        _likeImage.frame = CGRectMake(70.f, 5.f, 20.f, 20.f);
        [_maskView addSubview:_likeImage];
        
        _likeLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _likeLabel.frame = CGRectMake(95.f, 0.f, 100.f, 30.f);
        _likeLabel.backgroundColor = [UIColor clearColor];
        _likeLabel.textColor = [UIColor grayColor];
        _likeLabel.font = KCWSystemFont(12.f);
        _likeLabel.tag = 'l';
        [_maskView addSubview:_likeLabel];
        
        _orderImage = [[UIImageView alloc]initWithFrame:CGRectZero];
        _orderImage.image = [UIImage imageCwNamed:@"icon_cart_store.png"];
        _orderImage.frame = CGRectMake(220.f, 5.f, 20.f, 20.f);
        [_maskView addSubview:_orderImage];
        
        _orderLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _orderLabel.frame = CGRectMake(245.f, 0.f, 100.f, 30.f);
        _orderLabel.backgroundColor = [UIColor clearColor];
        _orderLabel.textColor = [UIColor grayColor];
        _orderLabel.font = KCWSystemFont(12.f);
        _orderLabel.tag = 'o';
        [_maskView addSubview:_orderLabel];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"AdCwViewCell...");
    [_modelLabel release], _modelLabel = nil;
    [_likeImage release], _likeImage = nil;
    [_likeLabel release], _likeLabel = nil;
    [_orderImage release], _orderImage = nil;
    [_orderLabel release], _orderLabel = nil;
    [_maskView release], _maskView = nil;
    [_scrollViewC release], _scrollViewC = nil;
    if (CWPview) {
        [CWPview release], CWPview = nil;
    }
    self.picsArr = nil;
    
    [super dealloc];
}

- (void)scrollinvalidate
{
    [_scrollViewC invalidateSingle];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setCellContentAndFrame:(NSDictionary *)dict index:(int)index state:(BOOL)state from:(BOOL)_isFromProCenter
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    _modelLabel.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
    CGSize size = [_modelLabel.text sizeWithFont:_modelLabel.font constrainedToSize:CGSizeMake(300.f, 100.f)];
    _modelLabel.frame = CGRectMake(0.f, KCellUpW/2, size.width+20.f, 20.f);

    _likeLabel.text = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"like_sum"] intValue]];
        
    _orderLabel.text = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"sale_sum"] intValue]];
    
    // 判断取图片数据
    if (state) {
        if (index > 20) {
            NSMutableArray *arr = [dict objectForKey:@"pics"];
            self.picsArr = arr;
        } else {
//            if (_isFromProCenter == YES) {
//                productsCenter_list_pics_model *slpMod = [[productsCenter_list_pics_model alloc]init];
//                slpMod.where = [NSString stringWithFormat:@"id = '%@'",[dict objectForKey:@"product_id"]];
//                NSMutableArray *arr = [slpMod getList];
//                self.picsArr = arr;
//                [slpMod release], slpMod = nil;
//            }else {
                shop_list_pics_model *slpMod = [[shop_list_pics_model alloc]init];
                slpMod.where = [NSString stringWithFormat:@"id = '%@'",[dict objectForKey:@"product_id"]];
                NSMutableArray *arr = [slpMod getList];
                self.picsArr = arr;
                [slpMod release], slpMod = nil;
//            }
        }
    } else {
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[dict objectForKey:@"pics"]];
        self.picsArr = arr;
    }
    NSLog(@"self.picsArr = %@",self.picsArr);
    dispatch_async(dispatch_get_main_queue(), ^{
        [_scrollViewC reloadScrollView];
    });
    
    [pool release];
}

+ (CGFloat)getCellHeight
{
    return KAdCwViewCellHeight;
}

#pragma mark - SingleScrollViewDelegate
- (NSInteger)numberOfPagesSingle:(SingleScrollView *)singleScrollView
{
    return self.picsArr.count;
}

- (CWImageView *)pageSingleReturnEachView:(SingleScrollView *)singleScrollView pageIndex:(NSInteger)index
{
    CWImageView *view = [[[CWImageView alloc]initWithFrame:CGRectMake(index*KUIScreenWidth , 0.f , KUIScreenWidth , KAdCwViewCellHeight)] autorelease];
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    NSDictionary *adDic = [self.picsArr objectAtIndex:index];
    
    //图片
    view.delegate = self;
    
    NSString *picUrl = [adDic objectForKey:@"thumb_pic"];
    NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];

    if (picUrl.length > 1) {
        UIImage *pic = [FileManager getPhoto:picName];
        if (pic.size.width > 2) {
            CGSize size = [UIImage fitsize:pic.size size:CGSizeMake(KUIScreenWidth, KAdCwViewCellHeight)];
            CGFloat x = index*KUIScreenWidth + (KUIScreenWidth-size.width) / 2;
            CGFloat y = (KAdCwViewCellHeight - size.height) / 2;
            view.frame = CGRectMake(x, y, size.width, size.height);
            view.image = pic;
        } else {
            UIImage *defaultPic = [UIImage imageCwNamed:@"default_320x240.png"];
            view.image = defaultPic;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:20000];
            [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:indexPath delegate:self];
        }
    } else {
        UIImage *defaultPic = [UIImage imageCwNamed:@"default_320x240.png"];
        view.image = defaultPic;
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
                    [_scrollViewC reloadScrollViewImage:iconDownloader.cardIcon index:iconDownloader.indexPathInTableView.row];
                });
            }
            
            [[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:url];
        }
    });
    
    [pool release];
}
- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type {}
#pragma mark - CWImageViewDelegate
- (NSMutableArray *)getScrollViewCWImageView
{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
    for (id view in _scrollViewC.scrollView.subviews) {
        if ([view isKindOfClass:[CWImageView class]]) {
            [arr addObject:view];
        }
    }
    return arr;
}

- (void)touchCWImageView:(CWImageView *)imageView
{
    NSLog(@"touchCWImageView.......");
    if (CWPview == nil) {
        CWPview = [[CWPictureView alloc]initWithclickIndex:imageView.tag];
    } else {
        CWPview.selectIndex = imageView.tag;
    }
    
    CWPview.delegate = self;
    
    NSMutableArray *arr = [self getScrollViewCWImageView];
    
    CWPview.CwPictureViewClose = ^ {
        //[CWPview release], CWPview = nil;
    };
    
    [CWPview setPictureView:arr];
}

#pragma mark - CWPictureViewDelegate
- (void)cwPictureViewSetPage:(int)page
{
    [_scrollViewC setCurrentPage:page];
}

@end
