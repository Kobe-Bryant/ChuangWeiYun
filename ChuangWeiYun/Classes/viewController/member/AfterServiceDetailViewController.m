//
//  AfterServiceDetailViewController.m
//  cw
//
//  Created by yunlai on 13-9-4.
//
//

#import "AfterServiceDetailViewController.h"
#import "AfterServiceDetailCell.h"
#import "callSystemApp.h"
#import "afterservice_detail_model.h"
#import "Common.h"
#import "PreferentialObject.h"

@interface AfterServiceDetailViewController ()

@end

@implementation AfterServiceDetailViewController
@synthesize serviceId = _serviceId;
@synthesize orderId = _orderId;
@synthesize mobile = _mobile;
@synthesize serviceDataArray = _serviceDataArray;
@synthesize cloudLoading;

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = [NSString stringWithFormat:@"单号：%@",self.orderId];
    
    [self createTableView];
    
    [self accessService];
}


- (void)createTableView{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KUIScreenWidth, KUIScreenHeight-40) style:UITableViewStylePlain];
    _tableView.backgroundColor = KCWViewBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tag = 16;
    [self.view addSubview:_tableView];
    
    
    UIButton *barBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [barBtn setFrame:CGRectMake(0, 0, 40, 40)];
    [barBtn setBackgroundImage:[UIImage imageNamed:@"phone.png"] forState:UIControlStateNormal];
    [barBtn addTarget:self action:@selector(phoneClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc]initWithCustomView:barBtn];
    self.navigationItem.rightBarButtonItem = barBtnItem;
    RELEASE_SAFE(barBtnItem);
    
}

//拨打电话
- (void)phoneClick{
    NSLog(@"%@",self.mobile);
    [callSystemApp makeCall:self.mobile];
}

- (void)dealloc
{
    RELEASE_SAFE(_serviceDataArray);
    self.serviceId=nil;
    self.orderId=nil;
    self.mobile=nil;
    RELEASE_SAFE(cloudLoading);
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
  
}

//动态获取行高
- (CGFloat)getTheCellHeight:(int) row{

    UIFont *font = [UIFont fontWithName:@"Arial" size:13];
    CGSize size = CGSizeMake(230,2000);
    NSString *str;
    
    NSDictionary *dic=[self.serviceDataArray objectAtIndex:row];
    str=[dic objectForKey:@"track_log"];
    
    CGSize labelsize = [str sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    
    return labelsize.height;
}
//动态获取内容的高度
- (CGFloat)getTheHeight:(NSString *)contentStr
{
    UIFont *font = [UIFont fontWithName:@"Arial" size:13];
    CGSize size = CGSizeMake(230,2000);
    CGSize labelsize = [contentStr sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
    
    return labelsize.height;
}
#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.serviceDataArray count]!=0) {
        return [self.serviceDataArray count];
    }else{
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row==0) {
        static NSString *CellId = @"indter";
        AfterServiceDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
        
        if (cell == nil) {
            cell = [[[AfterServiceDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId] autorelease];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = [UIColor whiteColor];
        
       
        
        if ([self.serviceDataArray count]!=0) {
            NSDictionary *dic = [self.serviceDataArray objectAtIndex:0];
            cell.contentLabel.text = [dic objectForKey:@"track_log"];
            cell.serviceTime.text = [PreferentialObject getTheDate:[[dic objectForKey:@"track_time"]intValue] symbol:3];
        }
        
        [cell.contentLabel setFrame:CGRectMake(65, 10, 230, [self getTheHeight:cell.contentLabel.text])];
        [cell.serviceTime setFrame:CGRectMake(65, [self getTheHeight:cell.contentLabel.text]+15, 230, 20)];
        
        cell.imgView.image = [UIImage imageCwNamed:@"current_member.png"];
        cell.line.frame = CGRectMake(cell.imgView.center.x, cell.imgView.center.y, 2, 50.f+[self getTheHeight:cell.contentLabel.text]-cell.imgView.center.y);
        
        return cell;
    }else{
        static NSString *CellIdentifier = @"CancelOrderCell";
        AfterServiceDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[AfterServiceDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
       
        if ([self.serviceDataArray count]!=0) {
            NSDictionary *dic = [self.serviceDataArray objectAtIndex:indexPath.row];
            cell.contentLabel.text = [dic objectForKey:@"track_log"];
            cell.serviceTime.text = [PreferentialObject getTheDate:[[dic objectForKey:@"track_time"]intValue] symbol:3];;
        }
        

        [cell.contentLabel setFrame:CGRectMake(65, 10, 230, [self getTheHeight:cell.contentLabel.text])];
        [cell.serviceTime setFrame:CGRectMake(65, [self getTheHeight:cell.contentLabel.text]+15, 230, 20)];
        
       if (indexPath.row == [self.serviceDataArray count]-1) {
            cell.line.frame = CGRectMake(cell.imgView.center.x, 0, 2, cell.imgView.center.y);
            
        }else{
            cell.line.frame = CGRectMake(cell.imgView.center.x, 0, 2, 50.0f+[self getTheHeight:cell.contentLabel.text]);
        }
        
        return cell;
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.row==0) {
        return 40.f+[self getTheCellHeight:0];
    }else{
        return 40.f+[self getTheCellHeight:indexPath.row];
    }
}

#pragma mark - accessService

- (void)accessService{
    
    //添加loading图标
	cloudLoadingView *tempLoadingView = [[cloudLoadingView alloc]initWithFrame:CGRectMake( 0.0f , 0.0f , 64.0f , 43.0f)];
    [tempLoadingView setCenter:CGPointMake(KUIScreenWidth / 2 +10, (self.view.frame.size.height - 44.0f - 49.0f) / 2)];
    self.cloudLoading = tempLoadingView;
    [self.view addSubview:self.cloudLoading];
    [tempLoadingView release];
    
    NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                       self.serviceId,@"service_sale_id",
                                                              self.orderId,@"service_sn",
                                                                                    nil];
	
	[[NetManager sharedManager]accessService:jsontestDic data:nil command:MEMBER_AFTERSERVICE_DETAIL_COMMAND_ID accessAdress:@"member/aftersaledetail.do?param=" delegate:self withParam:nil];
    
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
	NSLog(@"information finish");
    
    if (![[resultArray lastObject] isEqual:CwRequestFail]) {
        switch (commandid) {
                
            case MEMBER_AFTERSERVICE_DETAIL_COMMAND_ID:
            {
                [self performSelectorOnMainThread:@selector(success:) withObject:resultArray waitUntilDone:NO];
                
            }break;
                
            default:
                break;
        }
    }
}
- (void)success:(NSMutableArray*)resultArray{
    
    //loading图标移除
	[self.cloudLoading removeFromSuperview];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        afterservice_detail_model *servicdMod = [[afterservice_detail_model alloc]init];
        
        self.serviceDataArray = [servicdMod getList];
        NSLog(@"serviceDataArray==%@",self.serviceDataArray);
        NSLog(@"serviceDataArray count==%d",[self.serviceDataArray count]);
        RELEASE_SAFE(servicdMod);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
        });
        
    });

    
}



@end
