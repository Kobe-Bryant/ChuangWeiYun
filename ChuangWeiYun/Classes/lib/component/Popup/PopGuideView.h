//
//  PopGuideView.h
//  cw
//
//  Created by yunlai on 13-9-23.
//
//

#import "PopupView.h"

typedef enum
{
    Guide_Enum_ShopList,    // 商品列表
    Guide_Enum_ShopLR,      // 商品详情左右
    Guide_Enum_PfLR,        // 优惠详情左右
    Guide_Enum_HotShop,     // 热销商品上下
    Guide_Enum_Info,        // 资讯详情左右
} Guide_Enum;

@interface PopGuideView : PopupView
{
    Guide_Enum guideEnum;
}

- (id)initWithImage:(UIImage *)img index:(Guide_Enum)guide;

// 返回yes表示已经插入  相反则没有
+ (BOOL)isInsertTable:(Guide_Enum)guide;

@end

