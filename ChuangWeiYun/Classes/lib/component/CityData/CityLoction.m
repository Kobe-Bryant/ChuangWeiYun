//
//  CityLoction.m
//  cw
//
//  Created by yunlai on 13-11-24.
//
//

#import "CityLoction.h"
#import "PopLoction.h"
#import "Common.h"
#import "Global.h"
#import "cwAppDelegate.h"

static CityLoction *cityLoction = nil;

@implementation CityLoction

- (id)init
{
    self = [super init];
    
    if (self) {
        loctionView = [[PopLoction alloc]init];
    }
    return self;
}

- (void)dealloc
{
    [loctionView release], loctionView = nil;
    [super dealloc];
}

+ (CityLoction *)defaultSingle
{
    @synchronized(self) {
        if (cityLoction == nil) {
            cityLoction = [[CityLoction alloc]init];
        }
    }
    return cityLoction;
}

- (BOOL)showLoctionView
{
    if ([Global sharedGlobal].locationCity.length == 0 && [Global sharedGlobal].currCity.length == 0) {
        [loctionView addPopupSubview];
        
//        if ([Global sharedGlobal].currCity.length == 0) {
//            [loctionView setImage:[UIImage imageCwNamed:@"locating_icon.png"]
//                             text:@"正在定位..."
//                             type:NO
//                          isfirst:YES];
//        } else {
            [loctionView setImage:[UIImage imageCwNamed:@"locating_icon.png"]
                             text:@"正在定位..."
                             type:NO
                          isfirst:NO];
//        }
        
        [Global sharedGlobal].locManager.delegate = (cwAppDelegate *)[UIApplication sharedApplication].delegate;
        [[Global sharedGlobal].locManager startUpdatingLocation];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressLocation:) name:@"CityLocation" object:nil];
        
        return NO;
    } else {
        [self releaseSelf];
    }
    
    return YES;
}

#pragma mark - NSNotification
// 定位通知
- (void)addressLocation:(NSNotification *)notification
{
    if ([Global sharedGlobal].locationCity.length != 0) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CityLocation" object:nil];
        
        [loctionView addPopupSubview];
        
        [loctionView setImage:[UIImage imageCwNamed:@"locating_success_icon.png"]
                         text:[NSString stringWithFormat:@"定位成功\n我在这里：%@",[Global sharedGlobal].locationCity]
                         type:YES
                      isfirst:NO];
        
        [self performSelector:@selector(releaseSelf) withObject:nil afterDelay:1.f];
    } else {
//        [Global sharedGlobal].locManager.delegate = (cwAppDelegate *)[UIApplication sharedApplication].delegate;
//        [[Global sharedGlobal].locManager startUpdatingLocation];
        CityChooseViewController *city = [[CityChooseViewController alloc]init];
        CustomNavigationController *nav = ((cwAppDelegate *)[UIApplication sharedApplication].delegate).navController;
//        UINavigationController *nacc =[[ UINavigationController alloc]init];
        city.delegate = self;
        [nav pushViewController:city animated:YES];
        [city release], city = nil;
    }
}

#pragma mark - CityChooseViewControllerDelegate
- (void)returnChooseCityName:(NSString *)cityName
{
    [Global sharedGlobal].currCity = cityName;
    [Global sharedGlobal].locationCity = cityName;
}

- (void)releaseSelf
{
    if (cityLoction) {
        [cityLoction release], cityLoction = nil;
    }
}

@end
