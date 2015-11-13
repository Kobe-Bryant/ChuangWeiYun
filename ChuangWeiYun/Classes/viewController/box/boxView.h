//
//  boxView.h
//  cw
//
//  Created by yunlai on 13-12-3.
//
//

#import <UIKit/UIKit.h>

@protocol boxBtnDelegate <NSObject>

- (void)clickBtn:(int)tagB;

@end

@interface boxView : UIView
{
    id<boxBtnDelegate>delegate;
}
@property (nonatomic,assign) id<boxBtnDelegate>delegate;

- (id)initWithFrame:(CGRect)frame andIcon:(NSString *)imageStr andText:(NSString *)textStr andTag:(int)tag delegate:(id<boxBtnDelegate>)delegate;


@end
