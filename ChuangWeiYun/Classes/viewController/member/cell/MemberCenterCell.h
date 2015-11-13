//
//  MemberCenterCell.h
//  cw
//
//  Created by yunlai on 13-8-29.
//
//

#import <UIKit/UIKit.h>

@interface MemberCenterCell : UITableViewCell
{
    UIImageView *_imgView;
    UIImageView *_afterView;
    UILabel     *_labelText;

}
@property(nonatomic,retain)UIImageView  *afterView;
@property(nonatomic,retain)UIImageView  *imgView;
@property(nonatomic,retain)UILabel      *labelText;

@end
