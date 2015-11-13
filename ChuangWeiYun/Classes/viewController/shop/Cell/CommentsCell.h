//
//  CommentsCell.h
//  cw
//
//  Created by yunlai on 13-8-17.
//
//

#import <UIKit/UIKit.h>
#import "RCLabel.h"

@interface CommentsCell : UITableViewCell
{
    UIImageView *_bgView;
    UIImageView *_imageV;
    UILabel *_namelabel;
    UILabel *_timeLabel;
}
@property (nonatomic, retain) RCLabel *rtLabel;

- (void)setCellContentAndFrame:(NSDictionary *)dic imgFlag:(BOOL)flag;

- (void)setImageView:(UIImage *)img;

+ (CGFloat)getCellHeight:(NSDictionary *)dict;

@end
