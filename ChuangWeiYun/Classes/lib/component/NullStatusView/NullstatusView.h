//
//  NullstatusView.h
//  cw
//
//  Created by yunlai on 13-9-16.
//
//

#import <UIKit/UIKit.h>

@protocol NullstatusViewDelegate <NSObject>

- (NSString *)setStatusText;

@end

@interface NullstatusView : UIView
{
    id<NullstatusViewDelegate>delegate;
    UILabel *reminderText;
}
@property(nonatomic , retain)NSString *textValue;
@property(nonatomic , assign)id<NullstatusViewDelegate>delegate;

- (id)initNullStatusImage:(UIImage *)images andText:(NSString *)reminder;

- (void)setNullStatusText:(NSString *)reminder;

- (void)removeNullView;

@end

