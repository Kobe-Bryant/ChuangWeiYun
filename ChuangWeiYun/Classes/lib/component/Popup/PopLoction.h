//
//  PopLoction.h
//  cw
//
//  Created by yunlai on 13-10-10.
//
//

#import "PopupView.h"

@interface PopLoction : PopupView
{
    UIImageView *_imgView;
    UILabel *_label;
}

- (void)setImage:(UIImage *)img text:(NSString *)text type:(BOOL)hide isfirst:(BOOL)isfirst;

@end
