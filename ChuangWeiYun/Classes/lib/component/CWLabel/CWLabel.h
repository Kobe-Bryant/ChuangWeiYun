//
//  CWLabel.h
//  cw
//
//  Created by yunlai on 13-12-5.
//
//

#import <UIKit/UIKit.h>

@interface CWLabel : UIView
{
    NSMutableAttributedString* _string;
    UIFont* _font;
    UIColor* _textColor;
}

@property (nonatomic, strong)NSMutableAttributedString* string;
@property (nonatomic, strong)UIFont* font;
@property (nonatomic, strong)UIColor* textColor;

- (void)setText:(NSString*)text;
@end
