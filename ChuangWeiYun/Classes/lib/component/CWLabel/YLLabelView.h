//
//  YLLabelView.h
//  cw
//
//  Created by yunlai on 13-12-12.
//
//

#import <UIKit/UIKit.h>

@interface YLLabelView : UIView

//@property(nonatomic,retain)NSString *text; //要画的文字
//
//@property(nonatomic,assign)CGFloat font; //字体大小
//
//@property(nonatomic,assign)CGFloat character; //字间距
//
//@property(nonatomic,assign)CGFloat line; //行间距
//
//@property(nonatomic,assign)CGFloat paragraph;//段落间距

+ (CGSize)height:(NSString *)text Font:(CGFloat)font Character:(CGFloat)character Line:(CGFloat)line Pragraph:(CGFloat)pragraph;

@end
