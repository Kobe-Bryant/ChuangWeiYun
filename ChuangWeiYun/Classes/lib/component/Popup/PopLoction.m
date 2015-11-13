//
//  PopLoction.m
//  cw
//
//  Created by yunlai on 13-10-10.
//
//

#import "PopLoction.h"
#import "Common.h"

@implementation PopLoction

- (id)init
{
    UIImage *img = [UIImage imageCwNamed:@"locating_icon.png"];
    
    self = [super initWithFrame:CGRectMake(0.f, 0.f, img.size.width, img.size.height)];
    if (self) {
        
        self.center = popupView.center;
        
        _imgView = [[UIImageView alloc]initWithFrame:self.bounds];
        [self addSubview:_imgView];
        
        _label = [[UILabel alloc]initWithFrame:CGRectMake(0.f, 100.f, img.size.width, img.size.height-100.f)];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.backgroundColor = [UIColor clearColor];
        _label.numberOfLines = 2;
        _label.textColor = [UIColor whiteColor];
        _label.font = KCWSystemFont(15.f);
        [self addSubview:_label];
    }
    return self;
}

- (void)dealloc
{
    [_imgView release], _imgView = nil;
    [_label release], _label = nil;
    [super dealloc];
}

- (void)addPopupSubview
{
    [super addPopupSubview];
    
    popupView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.f];
    
    [popupView addSubview:self];
}

- (void)removeFromSuperviewSelf
{
    [self removeFromSuperview];
}

- (void)setImage:(UIImage *)img text:(NSString *)text type:(BOOL)hide isfirst:(BOOL)isfirst
{
    _imgView.image = img;
    _label.text = text;

    if (hide) {
        [self performSelector:@selector(removeFromSuperviewSelf) withObject:nil afterDelay:1.f];
    } else {
        if (!isfirst) {
            [self performSelector:@selector(removeFromSuperviewSelf) withObject:nil afterDelay:2.f];
        }
    }
}

@end
