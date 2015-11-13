//
//  PfCommonViewController.h
//  cw
//
//  Created by yunlai on 13-8-28.
//
//

#import <UIKit/UIKit.h>
#import "DoubleScrollView.h"
#import "IconDownLoader.h"
#import "DoubleView.h"

@interface PfCommonViewController : UIViewController <DoubleScrollViewDelegate, IconDownloaderDelegate, DoubleViewDelegate>
{
    NSString *codeID;
    NSString *codeUrl;
    NSDictionary *dict;
    NSMutableArray *relationArr;
    
    DoubleScrollView *_scrollView;
    int pfCommon;
}

@property (retain, nonatomic) NSString *codeID;
@property (retain, nonatomic) NSString *codeUrl;
@property (retain, nonatomic) NSDictionary *dict;
@property (retain, nonatomic) NSMutableArray *relationArr;
@property (assign, nonatomic) int pfCommon;
@property (retain, nonatomic) NSString *intro;


@end
