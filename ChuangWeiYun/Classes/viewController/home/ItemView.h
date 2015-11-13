//
//  ItemView.h
//  MoveTest
//
//  Created by LuoHui on 13-9-9.
//  Copyright (c) 2013年 LuoHui. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ItemViewDelegate;

@interface ItemView : UIView <UIGestureRecognizerDelegate>
{
    UIImageView *itemImageView;
    UILabel *nameLabel;
    
    BOOL isRemovable;
    BOOL isEditing;
    
    CGPoint point;//long press point
}
@property (nonatomic, retain) UIImageView *itemImageView;
@property (nonatomic, retain) UILabel *nameLabel;
@property (retain, nonatomic) UIButton *removeBtn;
@property (assign, nonatomic) id <ItemViewDelegate> delegate;
@property (assign, nonatomic) BOOL isRemovable;
@property (assign, nonatomic) BOOL isEditing;

- (id)initWithFrame:(CGRect)frame atIndex:(NSInteger)aIndex editable:(BOOL)removable;
- (void)enableEditing:(BOOL)isbool;
- (void)updateTag:(int)newTag;
@end


@protocol ItemViewDelegate <NSObject>

@required
- (void)longPressStateBegan:(BOOL)isbool;

- (void)longPressStateEnded:(ItemView *)item withLocation:(CGPoint)point GestureRecognizer:(UILongPressGestureRecognizer *)recognizer;
- (void)longPressStateMoved:(ItemView *)item withLocation:(CGPoint)point GestureRecognizer:(UILongPressGestureRecognizer *)recognizer;

- (void)itemDidDeleted:(ItemView *) gridItem atIndex:(NSInteger)index;
- (void)clickItemView:(ItemView *)item;
@end