//
//  UserInfoViewController.m
//  cw
//
//  Created by yunlai on 13-8-29.
//
//

#import "UserInfoViewController.h"
#import "UserInfoCell.h"
#import "UserInfoCell2.h"
#import "member_info_model.h"
#import "Global.h"
#import "CityChooseViewController.h"
#import "Common.h"

@interface UserInfoViewController ()

@end

@implementation UserInfoViewController
@synthesize contentField = _contentField;
@synthesize progressHUD = _progressHUD;
@synthesize userInfoArray = _userInfoArray;
@synthesize userName = _userName;
@synthesize birthday = _birthday;
@synthesize sex = _sex;
@synthesize address = _address;
@synthesize permanent = _permanent;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _userInfoArray=[[NSArray alloc]init];
        _contentField=[[UITextField alloc]init];
        _usuallyAddress=[[UITextField alloc]init];
        _gender=[[UITextField alloc]init];
        
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
 
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"个人信息";
    self.view.backgroundColor = KCWViewBgColor;
	
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(10, 25, KUIScreenWidth-20, 150) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.layer.borderColor=[UIColor colorWithRed:213/255.0 green:213/255.0 blue:213/255.0 alpha:1].CGColor;
    _tableView.layer.borderWidth=1;
    _tableView.layer.cornerRadius=3;
    _tableView.scrollEnabled=NO;
    _tableView.tag=111;
    _tableView.separatorStyle=UITableViewCellSelectionStyleNone;
    _tableView.showsVerticalScrollIndicator=NO;
    [self.view addSubview:_tableView];
    
    
    UIButton *barBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [barBtn setFrame:CGRectMake(0, 0, 40, 40)];
    [barBtn setImage:[UIImage imageCwNamed:@"complete.png"] forState:UIControlStateNormal];
    [barBtn addTarget:self action:@selector(editClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc]initWithCustomView:barBtn];
    self.navigationItem.rightBarButtonItem=barBtnItem;
    RELEASE_SAFE(barBtnItem);
    
    member_info_model *userInfo=[[member_info_model alloc]init];
    userInfo.where=[NSString stringWithFormat:@"id=%@",[Global sharedGlobal].user_id];
    self.userInfoArray=[userInfo getList];
    
    self.usuallyAddress.text = [[self.userInfoArray objectAtIndex:0]objectForKey:@"permanent"];
    
    //[[[self.userInfoArray objectAtIndex:0]objectForKey:@"permanent"]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"usuallyAddress=%@",self.usuallyAddress.text);
    
    RELEASE_SAFE(userInfo);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (void)dealloc
{
    RELEASE_SAFE(_userInfoArray);
    RELEASE_SAFE(_tableView);
    RELEASE_SAFE(_progressHUD);
    RELEASE_SAFE(_contentField);
    RELEASE_SAFE(_usuallyAddress);
    RELEASE_SAFE(_gender);
    [super dealloc];
}
-(void)editClick{
    
    [self.contentField resignFirstResponder];
    
    [self  accessService];
    
//    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self.view];
//    progressHUDTmp.center=CGPointMake(self.view.center.x, self.view.center.y);
//    self.progressHUD = progressHUDTmp;
//    [progressHUDTmp release];
//    self.progressHUD.delegate = self;
//    self.progressHUD.labelText = @"提交中...";
//    [self.view addSubview:self.progressHUD];
//    [self.view bringSubviewToFront:self.progressHUD];
//    [self.progressHUD show:YES];
    
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [self.contentField resignFirstResponder];
    [self.usuallyAddress resignFirstResponder];
    [self.gender resignFirstResponder];

}

- (void)checkProgressHUD:(NSString *)value andImage:(UIImage *)img{
    
    MBProgressHUD *progressHUDTmp = [[MBProgressHUD alloc] initWithView:self.view];
    progressHUDTmp.center=CGPointMake(self.view.center.x, self.view.center.y+120);
    progressHUDTmp.customView= [[[UIImageView alloc] initWithImage:img] autorelease];
    progressHUDTmp.mode = MBProgressHUDModeCustomView;
    progressHUDTmp.labelText = value;
    [self.view addSubview:progressHUDTmp];
    [self.view bringSubviewToFront:progressHUDTmp];
    [progressHUDTmp show:YES];
    [progressHUDTmp hide:YES afterDelay:1];
    RELEASE_SAFE(progressHUDTmp);
}

#pragma mark - UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
 
    return 3;
 
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
        static NSString * identifier=@"ident";
        UserInfoCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell==nil) {
            cell=[[[UserInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]autorelease];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        NSDictionary *dic=nil;
         if ([self.userInfoArray count]!=0) {
            dic=[self.userInfoArray objectAtIndex:0];
         }
        switch (indexPath.row) {
            case 0:{
                cell.taglabel.text=@"姓  名";
                if ([self.userInfoArray count]!=0) {
                    cell.contentlable.text=[dic objectForKey:@"real_name"];
                    self.contentField=cell.contentlable;
                    self.contentField.delegate=self;
                }
            }break;
            case 1:{
                cell.taglabel.text=@"常居地";
            
               if ([self.userInfoArray count]!=0) {            
                   cell.contentlable.text = self.usuallyAddress.text;
                   if (cell.contentlable.text.length==0) {
                       cell.contentlable.text=[Global sharedGlobal].locationCity;
                   }
                   NSLog(@"%@",cell.contentlable.text);
               }
                cell.contentlable.enabled=NO;
                self.usuallyAddress.enabled=NO;
                self.usuallyAddress.delegate=self;
            }
                break;
            case 2:{
                cell.taglabel.text=@"性  别";
                if ([self.userInfoArray count]!=0) {
                    if ([[dic objectForKey:@"sex"]intValue]==0) {
                        cell.contentlable.text=@"男";
                    }else{
                        cell.contentlable.text=@"女";
                    }
                }
                self.gender=cell.contentlable;
                self.gender.enabled=NO;
                self.gender.delegate=self;
            } break;
            default:
                break;
        }

        
        return cell;
 
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.contentField resignFirstResponder];
    [self.usuallyAddress resignFirstResponder];
    [self.gender resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row==1) {
        CityChooseViewController *cityCtl=[[CityChooseViewController alloc]init];
        cityCtl.cwStatusType=StatusTypeMemberChooseCity;
        cityCtl.delegate=self;
        [self.navigationController pushViewController:cityCtl animated:NO];
        RELEASE_SAFE(cityCtl);
    }else if(indexPath.row ==2){
        UIActionSheet *sheet=[[UIActionSheet alloc]initWithTitle:@"选择性别" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男",@"女", nil];
        [sheet showInView:self.view];
        RELEASE_SAFE(sheet);
        
    }
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.contentField resignFirstResponder];
    [self.usuallyAddress resignFirstResponder];
    [self.gender resignFirstResponder];
    return YES;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        self.gender.text = @"男";
    }else if(buttonIndex==1) {
        self.gender.text = @"女";
    }
}
#pragma mark - CityChooseViewControllerDelegate
- (void)returnChooseCityName:(NSString *)cityName{
    
    self.usuallyAddress.text=[NSString stringWithFormat:@"%@",cityName];
    NSLog(@"cityName==%@==%@",cityName,self.usuallyAddress.text);
    
    [_tableView reloadData];

}
#pragma mark - accessService

-(void)accessService{
    NSLog(@"usuallyAddress==%@",self.usuallyAddress.text);
    int sex = 0;
    if ([self.gender.text isEqualToString:@"男"]) {
        sex = 1;
    }else{
        sex = 2;
    }

    NSMutableDictionary *jsontestDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                          [NSString stringWithFormat:@"%d",sex],@"sex",
                                                                   self.contentField.text,@"real_name",
                                                                    self.usuallyAddress.text,@"permanent",
                            [NSString stringWithFormat:@"%@",[Global sharedGlobal].user_id],@"user_id",
                                                                                                  nil];
	
	[[NetManager sharedManager]accessService:jsontestDic data:nil command:MEMBER_USERINFO_COMMAND_ID accessAdress:@"member/updatememberinfo.do?param=" delegate:self withParam:nil];
    
    //[self.usuallyAddress.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
    
}


- (void)didFinishCommand:(NSMutableArray*)resultArray cmd:(int)commandid withVersion:(int)ver{
	NSLog(@"information finish");
    if (![[resultArray lastObject] isEqual:CwRequestFail]) {
        if ([resultArray count]!=0) {
            int resultInt = [[[resultArray objectAtIndex:0] objectForKey:@"ret"]intValue];
            NSLog(@"resultInt=%d",resultInt);
            switch (commandid) {
                    
                case MEMBER_USERINFO_COMMAND_ID:
                {
                    if (resultInt==1) {
                        [self performSelectorOnMainThread:@selector(success:) withObject:resultArray waitUntilDone:NO];
                    }else if (resultInt==0){
                        [self performSelectorOnMainThread:@selector(fail) withObject:nil waitUntilDone:NO];
                    }else{
                        
                        [self checkProgressHUD:@"非法参数" andImage:nil];
                    }
                    
                    
                }break;
                    
                default:
                    break;
            }
        }else{
            [self fail];
        }
    }else{
 
        UIImage *img = [UIImage imageCwNamed:@"icon_tip_normal.png"];
        [self checkProgressHUD:@"网络不给力" andImage:img];
    }
}
- (void)success:(NSMutableArray*)resultArray{

    [self checkProgressHUD:@"修改成功" andImage:nil];
    int sex;
    if ([self.gender.text isEqualToString:@"男"]) {
        sex=0;
    }else{
        sex=1;
    }
    
    //修改提交后，更新数据库
    NSDictionary *userDic=[NSDictionary dictionaryWithObjectsAndKeys:
                                    self.contentField.text,@"real_name",
                           [NSString stringWithFormat:@"%d",sex],@"sex",
                                  self.usuallyAddress.text,@"permanent",
                                                                   nil];
    
    member_info_model *userInfo=[[member_info_model alloc]init];
    userInfo.where=[NSString stringWithFormat:@"id=%@",[Global sharedGlobal].user_id];
    [userInfo updateDB:userDic];
    RELEASE_SAFE(userInfo);
    
    [self performSelector:@selector(backCtl) withObject:nil afterDelay:1];
    
    
}
- (void)backCtl{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)fail
{
    [self checkProgressHUD:@"修改失败" andImage:nil];
}
@end
