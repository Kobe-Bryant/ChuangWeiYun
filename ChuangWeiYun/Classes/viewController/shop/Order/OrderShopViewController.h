//
//  OrderShopViewController.h
//  cw
//
//  Created by yunlai on 13-8-23.
//
//

#import <UIKit/UIKit.h>
#import "HttpRequest.h"
#import "InvoiceViewController.h"
#import "PopAddressPickerView.h"
#import "CouponsViewController.h"
#import "ChooseAddressViewController.h"
#import "PopBookSucceedView.h"

@protocol OrderShopViewControllerDelegate;

@interface OrderShopViewController : UIViewController <HttpRequestDelegate,InvoiceViewControllerDelegate,PopAddressPickerViewDelegate,CouponsViewControllerDelegate, UITextViewDelegate, ChooseAddressViewControllerDelegate, PopBookSucceedViewDelegate, UIActionSheetDelegate>
{
    UIScrollView *_scrollViewC;
    
    NSDictionary *shopDict;
    
    NSMutableArray *shopList;
    
    id <OrderShopViewControllerDelegate> delegate;
}

@property (retain, nonatomic) UIScrollView *scrollViewC;
@property (retain, nonatomic) NSDictionary *shopDict;
@property (retain, nonatomic) NSMutableArray *shopList;
@property (assign, nonatomic) id <OrderShopViewControllerDelegate> delegate;

@end


@protocol OrderShopViewControllerDelegate <NSObject>

@optional
- (void)orderShopViewSuccessNum;

@end