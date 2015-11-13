//
//  AfterServiceDetailCell.h
//  cw
//
//  Created by yunlai on 13-9-4.
//
//

#import <UIKit/UIKit.h>

@interface AfterServiceDetailCell : UITableViewCell
{
    UIImageView *_imgView;
    UILabel     *_line;
    
    UILabel     *_contentLabel;
    UILabel     *_serviceTime;
    
    UILabel     *_normalCycle;
    UILabel     *_beyondCycle;
    
}
@property(nonatomic ,retain) UIImageView *imgView;
@property(nonatomic ,retain) UILabel     *line;
@property(nonatomic ,retain) UILabel     *contentLabel;
@property(nonatomic ,retain) UILabel     *serviceTime;
@property(nonatomic ,retain) UILabel     *normalCycle;
@property(nonatomic ,retain) UILabel     *beyondCycle;


@end
