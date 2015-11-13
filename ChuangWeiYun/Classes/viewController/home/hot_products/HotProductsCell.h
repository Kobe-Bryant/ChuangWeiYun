//
//  HotProductsCell.h
//  cw
//
//  Created by LuoHui on 13-8-26.
//
//

#import <UIKit/UIKit.h>

@protocol HotProductsCellDelegate <NSObject>

- (void)goToSee:(UIButton *)button;

@end

@interface HotProductsCell : UITableViewCell
{
    UILabel *_pNameLabel;
    UIImageView *_pImageView;
    UILabel *_pLoveLabel;
    UILabel *_pOrderLabel;
    UIWebView *_pContent;
    UILabel *_indexLabel;
    UIButton *goButton;
}
@property (nonatomic, retain) UILabel *pNameLabel;
@property (nonatomic, retain) UIImageView *pImageView;
@property (nonatomic, retain) UILabel *pLoveLabel;
@property (nonatomic, retain) UILabel *pOrderLabel;
@property (nonatomic, retain) UIWebView *pContent;
@property (nonatomic, retain) UILabel *indexLabel;
@property (nonatomic, retain) UIButton *goButton;
@property (nonatomic, assign) id<HotProductsCellDelegate> cellDelegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier with:(float)height;
@end
