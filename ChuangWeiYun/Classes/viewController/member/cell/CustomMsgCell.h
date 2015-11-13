//
//  CustomMsgCell.h
//  cw
//
//  Created by yunlai on 13-8-31.
//
//

#import <UIKit/UIKit.h>

@interface CustomMsgCell : UITableViewCell
{
    UIImageView *_shopImage;
    UILabel     *_shopName;
    UILabel     *_shopAbout;
    UIButton    *_likeBtn;
    
}

@property(nonatomic,retain) UIImageView *shopImage;
@property(nonatomic,retain) UILabel     *shopName;
@property(nonatomic,retain) UILabel     *shopAbout;
@property(nonatomic,retain) UIButton    *likeBtn;

@end
