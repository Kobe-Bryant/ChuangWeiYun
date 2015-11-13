//
//  AddAddressViewController.h
//  cw
//
//  Created by yunlai on 13-8-24.
//
//

#import <UIKit/UIKit.h>
#import "HttpRequest.h"
#import "PopAddressPickerView.h"

@interface AddAddressViewController : UIViewController <HttpRequestDelegate, PopAddressPickerViewDelegate>
{
    int type;
    
    NSMutableDictionary *addressDict;
}

// type 1 为增加，type 2 为修改
@property (assign, nonatomic) int type;

@property (retain, nonatomic) NSMutableDictionary *addressDict;

@end

