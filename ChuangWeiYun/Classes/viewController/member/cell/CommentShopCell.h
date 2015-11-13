//
//  CommentShopCell.h
//  cw
//
//  Created by yunlai on 13-8-31.
//
//

#import <UIKit/UIKit.h>
#import "UICustomView.h"
#import "RCLabel.h"
#import "UICutLineView.h"
@interface CommentShopCell : UITableViewCell
{
    UILabel         *_commentTime;
    UILabel         *_content;
    
    UIImageView     *_shopImage;
    UILabel         *_shopAbout;
    UICustomView    *_cellView;
    UILabel         *_typeNum;
    UICutLineView   *_lineView;
}
@property (nonatomic ,retain) UILabel        *commentTime;
@property (nonatomic ,retain) UILabel        *content;
@property (nonatomic ,retain) UIImageView    *shopImage;
@property (nonatomic ,retain) UILabel        *shopAbout;
@property (nonatomic ,retain) UILabel        *typeNum;
@property (nonatomic ,retain) UICustomView   *cellView;
@property (nonatomic, retain) RCLabel        *rtLabel;
@property (nonatomic, retain) UICutLineView  *lineView;
@end
