//
//  ProductListCell.m
//  SideSlip
//
//  Created by yunlai on 13-8-14.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import "ProductListCell.h"
#import "CrossLabel.h"
#import "Common.h"

#define PLCImageW   120.f  // 图片的高度和宽度
#define PLCImageH   90.f  // 图片的高度和宽度
#define PLCSpaceLW  10.f  // 左边距
#define PLCSpaceUH  10.f  // 上边距
#define PLCSpaceRW  10.f  // 右边距
#define PLCSpaceDH  10.f  // 下边距

#define KPLCFontSize 14.f

@implementation ProductListCell

@synthesize statusType;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        pImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:pImageView];
        
        pTitleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        pTitleLabel.backgroundColor = [UIColor colorWithRed:130.f/255.f green:130.f/255.f blue:130.f/255.f alpha:0.8f];
        pTitleLabel.textColor = [UIColor whiteColor];
        pTitleLabel.textAlignment = NSTextAlignmentCenter;
        pTitleLabel.font = KCWSystemFont(14.f);
        [self.contentView addSubview:pTitleLabel];

        pMoneyLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        pMoneyLabel.backgroundColor = [UIColor clearColor];
        pMoneyLabel.textColor = [UIColor colorWithRed:51.f/255.f green:51.f/255.f blue:51.f/255.f alpha:1.f];
        pMoneyLabel.font = KCWSystemFont(15.f);
        [self.contentView addSubview:pMoneyLabel];
        
        UIColor *loseColor = [UIColor colorWithRed:183.f/255.f green:183.f/255.f blue:183.f/255.f alpha:1.f];
        pLoseMoneyLabel = [[CrossLabel alloc]initWithFrame:CGRectZero textColor:loseColor lineColor:loseColor];
        pLoseMoneyLabel.backgroundColor = [UIColor clearColor];
        pLoseMoneyLabel.font = KCWSystemFont(12.f);
        [self.contentView addSubview:pLoseMoneyLabel];
        
        pLoveImage = [[UIImageView alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:pLoveImage];
        
        pLoveLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        pLoveLabel.backgroundColor = [UIColor clearColor];
        pLoveLabel.textColor = [UIColor colorWithRed:119.f/255.f green:119.f/255.f blue:119.f/255.f alpha:1.f];
        pLoveLabel.font = KCWSystemFont(12.f);
        [self.contentView addSubview:pLoveLabel];
        
        pContentLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        pContentLabel.backgroundColor = [UIColor clearColor];
        pContentLabel.textColor = [UIColor blackColor];
        pContentLabel.numberOfLines = 2;
        pContentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        pContentLabel.font = KCWSystemFont(13.f);
        [self.contentView addSubview:pContentLabel];
        
        line = [[UILabel alloc]initWithFrame:CGRectZero];
        line.backgroundColor = [UIColor colorWithRed:239.f/255.f green:239.f/255.f blue:239.f/255.f alpha:1.f];
        [self.contentView addSubview:line];
    }
    return self;
}

- (void)setCellContentAndFrame:(NSDictionary *)dict
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    
    CGFloat height = PLCSpaceUH;
    
    pImageView.frame = CGRectMake(PLCSpaceLW, height, PLCImageW, PLCImageH);

    //CGSize lableSize = CGSizeMake(KUIScreenWidth - PLCImageW - 4*PLCSpaceLW, 1000.f);
    
    CGFloat frontWidth = CGRectGetMaxX(pImageView.frame) + PLCSpaceLW;

    pTitleLabel.text = [dict objectForKey:@"name"];
    pTitleLabel.frame = CGRectMake(0.f, PLCSpaceUH/2, 100.f, 20.f);
    
    NSString *content = [dict objectForKey:@"content"];
    pContentLabel.text = [content isEqual:[NSNull null]] ? @"" : content;
    pContentLabel.frame = CGRectMake(frontWidth, height, KUIScreenWidth - frontWidth - PLCSpaceLW , 40.f);
    
    height += 40.f;
    
    if (self.statusType == StatusTypeFromCenter) {
        pMoneyLabel.text = nil;
        pLoseMoneyLabel.text = nil;
    } else {
        if ([Common isLoctionAndEqual]) {
            pMoneyLabel.text = [NSString stringWithFormat:@"￥%0.2f",[[dict objectForKey:@"price"] doubleValue]];
            CGSize csize = [pMoneyLabel.text sizeWithFont:pMoneyLabel.font];
            pMoneyLabel.frame = CGRectMake(frontWidth, height, csize.width, 30.f);
            
            CGFloat fffwidth = frontWidth + csize.width + 10.f;
            
            pLoseMoneyLabel.text = [NSString stringWithFormat:@"￥%0.2f",[[dict objectForKey:@"market_price"] doubleValue]];
            csize = [pLoseMoneyLabel.text sizeWithFont:pLoseMoneyLabel.font];
            pLoseMoneyLabel.frame = CGRectMake(fffwidth, height, csize.width, 30.f);
            
            if ([[dict objectForKey:@"market_price"] intValue] == 0) {
                pLoseMoneyLabel.hidden = YES;
            } else {
                pLoseMoneyLabel.hidden = NO;
            }
        } else {
            pMoneyLabel.text = nil;
            pLoseMoneyLabel.text = nil;
        }
    }
    
    height += 30.f;
    
    pLoveImage.frame = CGRectMake(frontWidth, height, 20.f, 20.f);
    pLoveImage.image = [UIImage imageCwNamed:@"icon_like_store.png"];
    
    pLoveLabel.text = [NSString stringWithFormat:@"%d",[[dict objectForKey:@"like_sum"] intValue]];
    CGSize csize = [pLoveLabel.text sizeWithFont:pLoveLabel.font];
    pLoveLabel.frame = CGRectMake(frontWidth + 30.f, height, csize.width, 20.f);
    
    //height += 20.f;
    
    line.frame = CGRectMake(0.f, PLCImageH + 2*PLCSpaceLW - 1.f, KUIScreenWidth, 1.f);
    
    [pool release];
}

- (void)setCellViewImage:(UIImage *)image
{
    pImageView.image = image;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

+ (CGFloat)getCellHeight
{
    return PLCImageH + 2*PLCSpaceLW;
}

- (void)dealloc
{
    [pImageView release], pImageView = nil;
    [pTitleLabel release], pTitleLabel = nil;
    [pMoneyLabel release], pMoneyLabel = nil;
    [pLoseMoneyLabel release], pLoseMoneyLabel = nil;
    [pLoveImage release], pLoveImage = nil;
    [pLoveLabel release], pLoveLabel = nil;
    [pTitleLabel release], pTitleLabel = nil;
    
    [super dealloc];
}

@end
