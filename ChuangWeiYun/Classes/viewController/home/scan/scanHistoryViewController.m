//
//  scanHistoryViewController.m
//  scanHistory
//
//  Created by siphp on 13-01-05.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "scanHistoryViewController.h"
#import "Common.h"
#import "DBOperate.h"
#import "scanResultViewController.h"
#import "scanHistoryCellViewController.h"
#import "scan_history_model.h"
#import <UniversalResultParser.h>
#import <ParsedResult.h>

@implementation scanHistoryViewController

@synthesize myTableView;
@synthesize historyItems;
@synthesize spinner;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    self.title = @"历史记录";
    
    NSMutableArray *tempHistoryItems = [[NSMutableArray alloc] init];
	self.historyItems = tempHistoryItems;
	[tempHistoryItems release];
    
    //返回按钮
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];  
    backButton.frame = CGRectMake(0.0f, 0.0f, 40.0f, 40.0f);
    [backButton addTarget:self action:@selector(backHome) forControlEvents:UIControlEventTouchDown];
    UIImage *img = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"return" ofType:@"png"]];
    [backButton setBackgroundImage:img forState:UIControlStateNormal];
    [img release], img = nil;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton]; 
    self.navigationItem.leftBarButtonItem = backItem;
    [backItem release], backItem = nil;
    
    //背景
    self.view.backgroundColor = KCWViewBgColor;
    
    [self addNoItemView];
    
    //添加loading图标
    UIActivityIndicatorView *tempSpinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
    [tempSpinner setCenter:CGPointMake(self.view.frame.size.width / 3, self.view.frame.size.height / 2.0 - 20.0f)];
    self.spinner = tempSpinner;
    
    UILabel *loadingLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, 100, 20)];
    loadingLabel.font = [UIFont systemFontOfSize:14];
    loadingLabel.textColor = [UIColor colorWithRed:0.5 green: 0.5 blue: 0.5 alpha:1.0];
    loadingLabel.text = @"加载中...";		
    loadingLabel.textAlignment = UITextAlignmentCenter;
    loadingLabel.backgroundColor = [UIColor clearColor];
    [self.spinner addSubview:loadingLabel];
    [loadingLabel release];
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
    [tempSpinner release];
    
    //从数据库获取数据
    scan_history_model *scanHistoryMod = [[scan_history_model alloc] init];
    scanHistoryMod.orderBy = @"created";
    scanHistoryMod.orderType = @"desc";
    self.historyItems = [scanHistoryMod getList];
    [scanHistoryMod release];
    
    if (self.historyItems.count > 0) {
        //清空按钮
        UIImage *cancelImageNormal = [UIImage imageCwNamed:@"recycle.png"];
        UIImage *cancelImageClick = [UIImage imageCwNamed:@"recycle_click.png"];
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake( 0.0f , 0.0f ,cancelImageNormal.size.width, cancelImageNormal.size.height);
        [cancelButton addTarget:self action:@selector(delHistory) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setImage:cancelImageNormal forState:UIControlStateNormal];
        [cancelButton setImage:cancelImageClick forState:UIControlStateHighlighted];
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
        self.navigationItem.rightBarButtonItem = cancelItem;
        [cancelItem release];
        
        //添加表
        [self addTableView];
    }else {
        noItemView.hidden = NO;
    }
    
    //回归常态
    [self backNormal];
    
}

-(void) viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
}

- (void)addNoItemView
{
    noItemView = [[UIView alloc] initWithFrame:self.view.frame];
    noItemView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:noItemView];
    
    int yValue;
    if (KUIScreenHeight > 480) {
        yValue = 120;
    }else {
        yValue = 80;
    }
    
    UIImage *img = [UIImage imageCwNamed:@"icon_code_default.png"];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((320 - img.size.width) * 0.5, yValue, img.size.width, img.size.height)];
    imgView.image = img;
    [noItemView addSubview:imgView];
    [imgView release];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imgView.frame) + 10, 320, 25)];
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.textColor = [UIColor colorWithRed:0.7529 green:0.7529 blue:0.7529 alpha:1.0f];
    tipLabel.text = @"您还没有历史记录哦～";
    tipLabel.font = [UIFont systemFontOfSize:14.0f];
    tipLabel.textAlignment = UITextAlignmentCenter;
    [noItemView addSubview:tipLabel];
    [tipLabel release];
    
    UIImage *btnImage = [UIImage imageNamed:@"blue-button.png"];
    UIButton *goButton = [UIButton buttonWithType:UIButtonTypeCustom];
    goButton.frame = CGRectMake(70, CGRectGetMaxY(tipLabel.frame) + 40, 180, 40);
    [goButton setBackgroundImage:[btnImage stretchableImageWithLeftCapWidth:30 topCapHeight:15] forState:UIControlStateNormal];
    [goButton addTarget:self action:@selector(backHome) forControlEvents:UIControlEventTouchUpInside];
    [noItemView addSubview:goButton];
    
    UILabel *strLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, goButton.frame.size.width, goButton.frame.size.height)];
    strLabel.backgroundColor = [UIColor clearColor];
    strLabel.textColor = [UIColor whiteColor];
    strLabel.text = @"快去拍一下";
    strLabel.font = [UIFont systemFontOfSize:16.0f];
    strLabel.textAlignment = UITextAlignmentCenter;
    [goButton addSubview:strLabel];
    [strLabel release];
    
    noItemView.hidden = YES;
}

//添加数据表视图
-(void)addTableView;
{
	UITableView *tempTableView = [[UITableView alloc] initWithFrame:CGRectMake( 0.0f , 0.0f , self.view.frame.size.width , self.view.frame.size.height - 44.0f)];
    [tempTableView setDelegate:self];
    [tempTableView setDataSource:self];
    tempTableView.scrollsToTop = YES;
    self.myTableView = tempTableView;
    [tempTableView release];
    self.myTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.myTableView];
    [self.myTableView reloadData];
    
    //分割线
    self.myTableView.separatorColor = [UIColor clearColor];
    
}

//返回首页
- (void)backHome
{
    [self.navigationController popViewControllerAnimated:NO];
}

//清空记录
- (void)delHistory
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"确定要清空记录?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    [alertView show];
}

//回归常态
-(void)backNormal
{
    //移出loading
    [self.spinner removeFromSuperview];
}

#pragma mark -
#pragma mark UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1)
    {
        //清空数据
        scan_history_model *scanHistoryMod = [[scan_history_model alloc] init];
        [scanHistoryMod deleteDBdata];
        [scanHistoryMod release];
        
        self.historyItems = nil;
        //[self.myTableView reloadData];
        [self.myTableView removeFromSuperview];
        self.navigationItem.rightBarButtonItem = nil;
        
        noItemView.hidden = NO;
    }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([self.historyItems count] == 0)
    {
        return 1;
    }
    else
    {
        return [self.historyItems count];
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.historyItems != nil && [self.historyItems count] > 0)
    {
        //记录
        return 80.0f;
    }
    else
    {
        //没有记录
        return 50.0f;
    }
	
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"";
	UITableViewCell *cell;
	
	int historyItemsCount =  [self.historyItems count];
    int cellType;
    if (self.historyItems != nil && historyItemsCount > 0)
    {
        //记录
        CellIdentifier = @"listCell";
        cellType = 1;
    }
    else
    {
        //没有记录
        CellIdentifier = @"noneCell";
        cellType = 0;
    }
	
	cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) 
	{
        switch(cellType)
		{
            //没有记录
			case 0:
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                self.myTableView.separatorColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
//                UILabel *noneLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 300, 30)];
//				noneLabel.tag = 101;
//				[noneLabel setFont:[UIFont systemFontOfSize:12.0f]];
//				noneLabel.textColor = [UIColor colorWithRed:1.0f green: 1.0f blue: 1.0f alpha:1.0];
//				noneLabel.text = @"您还没有扫描任何二维码哦";			
//				noneLabel.textAlignment = UITextAlignmentCenter;
//				noneLabel.backgroundColor = [UIColor clearColor];
//				[cell.contentView addSubview:noneLabel];
//				[noneLabel release];
            }
                break;
            //记录
			case 1:
            {
                cell = [[[scanHistoryCellViewController alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                
                
            }
				break;
			default:   ;
		}
        
        cell.backgroundColor = [UIColor clearColor];
	}
	
	if (cellType == 1)
    {
        //数据填充
        NSDictionary *historyDic = [self.historyItems objectAtIndex:[indexPath row]];
        
        scanHistoryCellViewController *scanHistoryCell = (scanHistoryCellViewController *)cell;
        
        //标题
        scanHistoryCell.titleLabel.text = [historyDic objectForKey:@"type"];
        
        //时间
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:[[historyDic objectForKey:@"created"] intValue]];
        NSDateFormatter *outputFormat = [[NSDateFormatter alloc] init];
        [outputFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateString = [outputFormat stringFromDate:date];
        [outputFormat release];
        scanHistoryCell.timeLabel.text = dateString;
        
        //内容
        scanHistoryCell.infoLabel.text = [historyDic objectForKey:@"info"];
        
        return scanHistoryCell;
        
	}
    
    return cell; 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
    int countItems = [self.historyItems count];
	
	if (countItems > [indexPath row]) 
    {
        NSDictionary *historyDic = [self.historyItems objectAtIndex:[indexPath row]];
        scanResultViewController *scanResultView = [[scanResultViewController alloc] init];
        
        ParsedResult *pResult = [UniversalResultParser parsedResultForString:[historyDic objectForKey:@"result"]];
        scanResultView.result = pResult;
        scanResultView.resultString = [historyDic objectForKey:@"result"];
        scanResultView.dataFromScan = NO;
        [self.navigationController pushViewController:scanResultView animated:YES];
        [scanResultView release];
    }
    
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.myTableView.delegate = nil;
	self.myTableView = nil;
    self.historyItems = nil;
	self.spinner = nil;
}


- (void)dealloc {
	self.myTableView.delegate = nil;
	self.myTableView = nil;
    self.historyItems = nil;
    self.spinner = nil;
    [noItemView release];
    [super dealloc];
}

@end
