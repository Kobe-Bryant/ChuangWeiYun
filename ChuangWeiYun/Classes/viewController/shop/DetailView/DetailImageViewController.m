//
//  DetailImageViewController.m
//  cw
//
//  Created by yunlai on 13-11-11.
//
//

#import "DetailImageViewController.h"
#import "Common.h"
#import "FileManager.h"
#import "IconPictureProcess.h"
#import "cloudLoadingView.h"
#import "DetailImageCell.h"

@interface DetailImageViewController ()
{
    UITableView *_scrollView;
    
    cloudLoadingView *cloudLoading;
}

@property (retain, nonatomic) UITableView *scrollView;

@end

@implementation DetailImageViewController

@synthesize scrollView = _scrollView;
@synthesize imgArr;
@synthesize loadSums;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = @"图文详情";
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = KCWViewBgColor;
    
    NSLog(@"self.imgArr = %@",self.imgArr);
    NSString *str = nil;
    if (self.imgArr.count > 0) {
        str = [self.imgArr objectAtIndex:0];
    }
    if (str.length > 5) {
        _scrollView = [[UITableView alloc]initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, KUIScreenHeight-KUpBarHeight) style:UITableViewStylePlain];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.dataSource = self;
        _scrollView.delegate = self;
        _scrollView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_scrollView];
        
        loadSums = [[NSMutableArray alloc]initWithArray:self.imgArr];
        
        //添加loading图标
        if (cloudLoading == nil) {
            cloudLoading = [[cloudLoadingView alloc]initWithFrame:CGRectMake( 0.0f , 0.0f , 64.0f , 43.0f)];
            [cloudLoading setCenter:CGPointMake(self.view.frame.size.width / 2 +10, (self.view.frame.size.height - 44.0f - 49.0f) / 2)];
        }
        [self.view addSubview:cloudLoading];
        
    } else {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0.f, 0.f, KUIScreenWidth, 50.f)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor grayColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"暂无图文详情图片";
        label.font = KCWSystemFont(15.f);
        [self.view addSubview:label];
        [label release], label = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [_scrollView release], _scrollView = nil;
    self.imgArr = nil;
    [loadSums release], loadSums = nil;
    if (cloudLoading) {
        [cloudLoading release], cloudLoading = nil;
    }
    [super dealloc];
}

// 设置loadSums的值
- (void)setLoadSumsUrl:(NSString *)url
{
    if ([loadSums containsObject:url]) {
        NSLog(@"11111111");
        [loadSums removeObject:url];
    } 
    if (loadSums.count == 0) {
        [cloudLoading removeFromSuperview];
    } 
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.imgArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str = @"cell";
    
    DetailImageCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    
    if (cell == nil) {
        cell = [[[DetailImageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    //图片
    NSString *picUrl = [self.imgArr objectAtIndex:indexPath.row];
    NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
    NSLog(@"picUrl = %@",picUrl);
    if (picUrl.length > 1) {
        UIImage *pic = [FileManager getPhoto:picName];
        if (pic.size.width > 2) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell setImgViewContent:pic];
                [self setLoadSumsUrl:picUrl];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[IconPictureProcess sharedPictureProcess] startIconDownload:picUrl forIndexPath:indexPath delegate:self];
            });
        }
    }
    
    [pool release];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.f;
    NSLog(@"99999999999999.....");
    NSString *picUrl = [self.imgArr objectAtIndex:indexPath.row];
    NSString *picName = [Common encodeBase64:(NSMutableData *)[picUrl dataUsingEncoding: NSUTF8StringEncoding]];
    if (picUrl.length > 1) {
        UIImage *pic = [FileManager getPhoto:picName];
        height = [DetailImageCell getImgViewHeight:pic];
    }
    NSLog(@"height = %f",height);
    return height;
}

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
                    [self setLoadSumsUrl:url];

                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:iconDownloader.indexPathInTableView.row inSection:0];
                    [_scrollView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                });
            }
            
            [[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:url];
        }
    });
    
    [pool release];
}

- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type
{
    [self setLoadSumsUrl:url];
}

@end
