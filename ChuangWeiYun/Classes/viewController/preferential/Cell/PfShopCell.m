//
//  PfShopCell.m
//  cw
//
//  Created by yunlai on 13-8-27.
//
//

#import "PfShopCell.h"
#import "Common.h"
#import "IconPictureProcess.h"
#import "FileManager.h"
#import "DoubleView.h"

#define PfShopBGH           200.f
#define PfShopBGLeftW       10.f
#define PfShopBGUpH         10.f
#define PfShopLeftW         10.f
#define PfShopUpH           5.f
#define PfShopImageH        20.f
#define PfShopLabelH        30.f
#define PfShopUpLableH      30.f

#define KPfShopSystemFont15 15.f

@implementation PfShopCell

@synthesize controllerDelegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        bgView = [[UIView alloc]initWithFrame:CGRectMake(PfShopLeftW, PfShopUpH, KUIScreenWidth - 2*PfShopLeftW, PfShopBGH)];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.layer.cornerRadius = 5.f;
        bgView.layer.masksToBounds = YES;
        bgView.layer.borderWidth = 0.3f;
        bgView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        [self.contentView addSubview:bgView];
        
        self.backgroundColor = [UIColor clearColor];
        
        UILabel *bgL = [[UILabel alloc]initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth - 2*PfShopLeftW, PfShopUpLableH)];
        bgL.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.03f];
        [bgView addSubview:bgL];
        [bgL release], bgL = nil;
        
        CGFloat frontWidth = 2*PfShopBGLeftW + PfShopImageH;
        
        UIImageView *titleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(PfShopBGLeftW, 5.f, PfShopImageH, PfShopImageH)];
        titleImageView.image = [UIImage imageCwNamed:@"icon_balloon_store.png"];
        [bgView addSubview:titleImageView];
        [titleImageView release], titleImageView = nil;
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(frontWidth, 0.f, 100.f, PfShopLabelH)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.font = KCWboldSystemFont(KPfShopSystemFont15);
        label.text = @"活动商品";
        [bgView addSubview:label];
        [label release], label = nil;
        
        _scrollView = [[DoubleScrollView alloc]initWithFrame:CGRectMake(5.f, PfShopUpLableH, CGRectGetWidth(bgView.frame)-10.f, CGRectGetHeight(bgView.frame) - PfShopUpLableH)];
        _scrollView.delegate = self;
        [bgView addSubview:_scrollView];
        
        partner_pics  = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"pfshopcell dealloc........");
    [_scrollView release], _scrollView = nil;
    [bgView release], bgView = nil;
    [partner_pics release], partner_pics = nil;
    //self.controllerDelegate = nil;
    
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setCellContentAndFrame:(NSMutableArray *)arr
{
    if (arr.count > 2) {
        bgView.frame = CGRectMake(PfShopLeftW, PfShopUpH, KUIScreenWidth - 2*PfShopLeftW, PfShopBGH);
    } else {
        bgView.frame = CGRectMake(PfShopLeftW, PfShopUpH, KUIScreenWidth - 2*PfShopLeftW, PfShopBGH - 20.f);
    }
    [partner_pics removeAllObjects];
    [partner_pics addObjectsFromArray:arr];
    [_scrollView reloadScrollView];
}

+ (CGFloat)getCellHeight:(NSMutableArray *)arr
{
    CGFloat heigth = 0.f;
    if (arr.count > 2) {
        heigth = PfShopBGH + 2*PfShopUpH;
    } else {
        heigth = PfShopBGH + 2*PfShopUpH - 20.f;
    }
    return heigth;
}

#pragma mark - DoubleScrollViewDelegate
- (NSInteger)numberOfPages:(DoubleScrollView *)doubleScrollView
{
    return partner_pics.count;
}

- (UIView *)pageReturnEachView:(DoubleScrollView *)doubleScrollView pageIndex:(NSInteger)index
{
    CGFloat offsetw = CGRectGetWidth(doubleScrollView.frame);
    CGFloat offseth = CGRectGetHeight(doubleScrollView.frame);
    
    CGFloat width = (offsetw - 30.f)/2;
    CGFloat height = offseth - 40.f ;
    CGFloat x = (index / 2 + 1) * 10.f + index*(width + 10.f);
    CGFloat y = 10.f;

    DoubleView *view = [[[DoubleView alloc]initWithFrame:CGRectMake(x, y, width, height)] autorelease];
    
    view.delegate = self.controllerDelegate;
    
    view.layer.borderWidth = 0.5f;
    view.layer.borderColor = [UIColor colorWithRed:221.f/255.f green:221.f/255.f blue:221.f/255.f alpha:1.f].CGColor;
    
    [view setTitleLabel:[[partner_pics objectAtIndex:index] objectForKey:@"product_name"]];
    
    view.pro_id = [[partner_pics objectAtIndex:index] objectForKey:@"product_id"];
    //图片
    NSString *picUrl = [[partner_pics objectAtIndex:index] objectForKey:@"img_path"];
    NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
    
    if (picUrl.length > 1) {
        UIImage *pic = [FileManager getPhoto:picName];
        
        if (pic.size.width > 2) {
            [view setImageView:pic];
        } else {
            [view setImageView:[UIImage imageCwNamed:@"default_320x240.png"]];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:10000];
            [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:indexPath delegate:self];
        }
    } else {
        [view setImageView:[UIImage imageCwNamed:@"default_320x240.png"]];
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
                // 保存图片
                [[IconPictureProcess sharedPictureProcess] savePhoto:iconDownloader.cardIcon url:url];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_scrollView reloadScrollView];
                });
            }
            
            [[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:url];
        }
    });
}

- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type {}
@end
