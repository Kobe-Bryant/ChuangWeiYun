//
//  AfterServiceViewController.m
//  cw
//
//  Created by yunlai on 13-8-29.
//
//

#import "AfterServiceViewController.h"
#import "AfterServiceDetailViewController.h"
#import "AfterServiceCell.h"
#import "member_after_service_model.h"
#import "Common.h"
#import "Global.h"
#import "MemberLikeView.h"
#import "NetworkFail.h"
#import "PreferentialObject.h"

@interface AfterServiceViewController ()<NetworkFailDelegate>
{
    NetworkFail *failView;
}

@end


#define kcontrolHeight 44

@implementation AfterServiceViewController
@synthesize afterServiceArray=_afterServiceArray;
@synthesize cloudLoading;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"我的售后服务";
    self.view.backgroundColor = KCWViewBgColor;
	 
    _afterServiceArray = [[NSMutableArray alloc]initWithCapacity:0];
    
    [self createTableView];
    
    [self accessService];

    
}

- (void)createTableView{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KUIScreenWidth, KUIScreenHeight-55) style:UITableViewStylePlain];
    _tableView.backgroundColor = KCWViewBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tag = 16;
    [self.view addSubview:_tableView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    RELEASE_SAFE(_afterServiceArray);
    RELEASE_SAFE(_tableView);
    RELEASE_SAFE(_nullView);
    if (failView) {
        RELEASE_SAFE(failView);
    }
    [super dealloc];
}
#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.afterServiceArray count]!=0) {
        return [self.afterServiceArray count];
    }else{
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
        static NSString *CellIdentifier = @"CancelOrderCell";
        AfterServiceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[[AfterServiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        if ([self.afterServiceArray count]!=0) {
            NSDictionary *afterDic = [self.afterServiceArray objectAtIndex:indexPath.row];
            cell.orderNumLabel.text = [afterDic objectForKey:@"service_sn"];
            cell.statusLabel.text = [PreferentialObject getTheDate:[[afterDic objectForKey:@"appointment"] intValue] symbol:3];
            if ([[afterDic objectForKey:@"service_type"]intValue] == 1) {
                cell.serviceType.text = @"安装";
            }else{
                cell.serviceType.text = @"维修";
            }
            cell.serviceContent.text = [afterDic objectForKey:@"description"];
            cell.userName.text = [afterDic objectForKey:@"name"];
            cell.userMobile.text = [afterDic objectForKey:@"mobile"];
            cell.address.text = [afterDic objectForKey:@"address"];
        }
        
        return cell;
 

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dicService = [self.afterServiceArray objectAtIndex:indexPath.row];
    AfterServiceDetailViewController *detail = [[AfterServiceDetailViewController alloc]init];
    detail.serviceId = [dicService objectForKey:@"id"];
    detail.orderId = [dicService objectForKey:@"service_sn"];
    detail.mobile = [dicService objectForKey:@"mobile"];
    [self.navigationController pushViewController:detail animated:YES];
    RELEASE_SAFE(detail);
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 125.f;
}
#pragma mark - accessService

- (void)accessService{
    
    //添加loading图标
	cloudLoadingView *tempLoadingView = [[cloudLoadingView alloc]initWithFrame:CGRectMake( 0.0f , 0.0f , 64.0f , 43.0f)];
    [tempLoadingView setCenter:CGPointMake(KUIScreenWidth / 2+10, (self.view.frame.size.height - 44.0f - 49.0f) / 2)];
    self.cloudLoading = tempLoadingView;
    [self.view addSubview:self.cloudLoading];
    [tempLoadingView release];
    
    NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [Global sharedGlobal].user_id,@"user_id",
                                                                                    nil];
	
	[[NetManager sharedManager]accessService:jsontestDic data:nil command:MEMBER_AFTERSERVICE_COMMAND_ID accessAdress:@"member/aftersalesservce.do?param=" delegate:self withParam:nil];
    
}

// 创建失败视图
- (void)failViewCreate:(CwTypeView)cwTypeView
{
    failView = [NetworkFail initCreateNetworkView:self.view frame:self.view.bounds failView:failView delegate:self andType:cwTypeView];
    failView.cwNetworkFail = ^ {
        [failView release], failView = nil;
    };
}

- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
	NSLog(@"information finish");
    if (![[resultArray lastObject] isEqual:CwRequestFail]) {
        switch (commandid) {
                
            case MEMBER_AFTERSERVICE_COMMAND_ID:
            {
                [self performSelectorOnMainThread:@selector(success:) withObject:resultArray waitUntilDone:NO];
                
            }break;
                
            default:
                break;
        }
        self.cloudLoading.hidden = NO;
        
    }else{
        
        _tableView.hidden = YES;

        self.cloudLoading.hidden = YES;
        _nullView.hidden = YES;
        if (_nullView.superview) {
            [_nullView removeNullView];
        }
        
        if ([Common connectedToNetwork]) {
            // 网络繁忙，请重新再试
            [self failViewCreate:CwTypeViewNoRequest];
        } else {
            // 当前网络不可用，请重新再试
            [self failViewCreate:CwTypeViewNoNetWork];
        }
        
    }

}
- (void)success:(NSMutableArray*)resultArray{
    
    //loading图标移除
    [self.cloudLoading removeFromSuperview];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if ([[resultArray objectAtIndex:0] isEqual:@"cwRequestTimeout"]) {
            
            //服务器繁忙
            [self failViewCreate:CwTypeViewNoService];

            if (_tableView) {
                _tableView.hidden = YES;
            }

        }else{
            
            member_after_service_model *afterMod = [[member_after_service_model alloc]init];
            afterMod.orderBy = @"id";
            afterMod.orderType = @"desc";
            self.afterServiceArray = [afterMod getList];
            RELEASE_SAFE(afterMod);
            
            NSLog(@"afterServiceListArray==%@",self.afterServiceArray);
            
            dispatch_async(dispatch_get_main_queue(), ^{
               
                _nullView.hidden = NO;
                if ([self.afterServiceArray count]!=0) {
                    if (_nullView.superview!=NULL) {
                        [_nullView removeNullView];
                    }
                    [self createTableView];
                    _tableView.hidden = NO;
                }else{
                    
                    _nullView = [[NullstatusView alloc]initNullStatusImage:[UIImage imageCwNamed:@"icon_service_default.png"] andText:@"您还没有预约过售后服务哦~"];
                    [self.view addSubview:_nullView];
                    
                }
            });
        }
    });
}

// 联网失败后，点击重试
#pragma mark - NetworkFailDelegate
- (void)networkFailAgain
{
    [self accessService];

}


@end
