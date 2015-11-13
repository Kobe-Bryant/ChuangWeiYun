//
//  DetailImageCell.h
//  cw
//
//  Created by yunlai on 13-11-21.
//
//

#import <UIKit/UIKit.h>

@interface DetailImageCell : UITableViewCell
{
    UIImageView *imgView;
}

- (void)setImgViewContent:(UIImage *)img;

+ (CGFloat)getImgViewHeight:(UIImage *)img;

@end
