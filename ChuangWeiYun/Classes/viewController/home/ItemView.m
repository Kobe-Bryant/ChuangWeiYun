//
//  ItemView.m
//  MoveTest
//
//  Created by LuoHui on 13-9-9.
//  Copyright (c) 2013年 LuoHui. All rights reserved.
//

#import "ItemView.h"
#import "UIImageScale.h"

@implementation ItemView
@synthesize itemImageView;
@synthesize nameLabel;
@synthesize removeBtn;
@synthesize delegate;
@synthesize isRemovable;
@synthesize isEditing;

- (id)initWithFrame:(CGRect)frame atIndex:(NSInteger)aIndex editable:(BOOL)removable
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        if (removable == NO) {
            itemImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - 55) * 0.5, 15, 55, 55)];
            //itemImageView.image = itemImage;
            itemImageView.backgroundColor = [UIColor clearColor];
            [self addSubview:itemImageView];
            
            nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 20.0f , self.frame.size.width, 12.0f)];
            //nameLabel.text = @"便民服务";
            nameLabel.textColor = HOME_STR_COLOR;
            nameLabel.font = [UIFont systemFontOfSize:12.0f];
            nameLabel.textAlignment = NSTextAlignmentCenter;
            nameLabel.backgroundColor = [UIColor clearColor];
            [self addSubview:nameLabel];
        }else {
            UIImage *itemImage = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"default_repair" ofType:@"png"]];
            itemImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - 55) * 0.5, 15, 55, 55)];
            [self addSubview:itemImageView];
            [itemImage release];
            
            nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 20.0f , self.frame.size.width, 12.0f)];
            nameLabel.text = @"";
            nameLabel.textColor = HOME_STR_COLOR;
            nameLabel.font = [UIFont systemFontOfSize:12.0f];
            nameLabel.textAlignment = NSTextAlignmentCenter;
            nameLabel.backgroundColor = [UIColor clearColor];
            [self addSubview:nameLabel];
            
            UIImage *closeImage = [UIImage imageNamed:@"icon_close_home.png"];
            removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            removeBtn.frame = CGRectMake(3, 3, closeImage.size.width, closeImage.size.height);
            [removeBtn setBackgroundImage:closeImage forState:UIControlStateNormal];
            [removeBtn addTarget:self action:@selector(closeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:removeBtn];
            
            removeBtn.hidden = YES;
            
            self.isEditing = NO;
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        [tap release];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGesture:)];
        [self addGestureRecognizer:longPress];
        [longPress release];
        
        self.tag = aIndex;
        
        self.isRemovable = removable;
        
    }
    return self;
}

- (void)dealloc
{
    [itemImageView release];
    [nameLabel release];
    [super dealloc];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

// 更新视图的tag值
- (void)updateTag:(int)newTag
{
    self.tag = newTag;
}

// 改变视图的大小
- (void)enableEditing:(BOOL)isbool
{
//    if (self.isEditing == isbool) {
//        CGRect rect = self.frame;
//        if (isChoose) {
//            rect.origin.x = self.frame.origin.x;
//            rect.origin.y = self.frame.origin.y ;
//            rect.size.width = self.frame.size.width ;
//            rect.size.height = self.frame.size.height;
//        }
//        [UIView animateWithDuration:0.15 animations:^{
//            self.frame = rect;
//        }];
//        return;
//    }
    
    self.isEditing = isbool;
    
//    CGRect rect = self.frame;
//    
//    if (isbool) {
//        if (isChoose) {
//            rect.origin.x = self.frame.origin.x;
//            rect.origin.y = self.frame.origin.y;
//            rect.size.width = self.frame.size.width;
//            rect.size.height = self.frame.size.height;
//        } else {
//            rect.origin.x = self.frame.origin.x ;
//            rect.origin.y = self.frame.origin.y ;
//            rect.size.width = self.frame.size.width;
//            rect.size.height = self.frame.size.height;
//        }
//    } else {
//        rect.origin.x = self.frame.origin.x ;
//        rect.origin.y = self.frame.origin.y;
//        rect.size.width = self.frame.size.width ;
//        rect.size.height = self.frame.size.height;
//    }
//    
//    [UIView animateWithDuration:0.3 animations:^{
//        self.frame = rect;
//    }];
    
    [self.removeBtn setHidden:!isbool];
}

// removeButton的触发事件
- (void)closeBtnClick:(UIButton *)btn
{
    if ([delegate respondsToSelector:@selector(itemDidDeleted:atIndex:)]) {
        [delegate itemDidDeleted:self atIndex:self.tag - 1000];
    }
}

// 手势单击触发的事件
- (void)tapGesture:(UITapGestureRecognizer *)gesture
{
    if (self.isEditing) {
        if ([delegate respondsToSelector:@selector(longPressStateBegan:)]) {
            [delegate longPressStateBegan:NO];
        }
    } else {
        if ([delegate respondsToSelector:@selector(clickItemView:)]) {
            [delegate clickItemView:self];
        }
    }
}

// 手势长按触发的事件
- (void)longPressGesture:(UILongPressGestureRecognizer *)gesture
{
    if (self.isRemovable == NO) {
        if ([delegate respondsToSelector:@selector(longPressStateBegan:)]) {
            [delegate longPressStateBegan:YES];
        }
        return;
    }
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self enableEditing:YES];
            
            point = [gesture locationInView:self];
            
            if ([delegate respondsToSelector:@selector(longPressStateBegan:)]) {
                [delegate longPressStateBegan:YES];
            }
        }
            break;
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded:
        {
            point = [gesture locationInView:self];
            
            if ([delegate respondsToSelector:@selector(longPressStateEnded:withLocation:GestureRecognizer:)]) {
                [delegate longPressStateEnded:self withLocation:point GestureRecognizer:gesture];
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if ([delegate respondsToSelector:@selector(longPressStateMoved:withLocation:GestureRecognizer:)]) {
                [delegate longPressStateMoved:self withLocation:point GestureRecognizer:gesture];
            }
        }
            break;
        default:
            break;
    }
}

@end
