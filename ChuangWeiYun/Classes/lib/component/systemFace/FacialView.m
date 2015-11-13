//
//  FacialView.m
//  KeyBoardTest
//
//  Created by wangqiulei on 11-8-16.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FacialView.h"


@implementation FacialView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
//        faces=[EmojiEmoticons allEmoticons];
//        faces=[EmojiPictographs allPictographs];
        
        //faces=[Emoji allEmoji];  //系统表情库
        
        facesDic = [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"face" ofType:@"plist"]]retain];

    }
    return self;
}

-(void)loadFacialView:(int)page size:(CGSize)size
{
    //系统表情view
	//row number
//	for (int i=0; i<4; i++) {
//		//column numer
//		for (int y=0; y<9; y++) {
//			UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
//            [button setBackgroundColor:[UIColor clearColor]];
//            [button setFrame:CGRectMake(y*size.width, i*size.height, size.width, size.height)];
//            if (i==3&&y==8) {
//                [button setImage:[UIImage imageNamed:@"faceDelete"] forState:UIControlStateNormal];
//                button.tag=10000;
//                
//            }else{
//                [button.titleLabel setFont:[UIFont fontWithName:@"AppleColorEmoji" size:29.0]];
//                [button setTitle:[faces objectAtIndex:i*9+y+page*35] forState:UIControlStateNormal];
//                button.tag = i*9+y+page*35;
//                
//            }
//			[button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
//			[self addSubview:button];
//		}
//	}
    
    //自定义表情
    int row = 4;     //行数
    int colum = 7;   //列数
    int space = 17;  //间距
    for (int i = 0; i < row; i++) {
		//column numer
		for (int y = 0; y < colum; y++) {
			UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundColor:[UIColor clearColor]];
            [button setFrame:CGRectMake(y * size.width + y * space, i*size.height + i *space, size.width, size.height)];
            if (i == row - 1 && y == colum - 1) {
                [button setImage:[UIImage imageNamed:@"faceDelete"] forState:UIControlStateNormal];
                button.tag=10000;
            }else{
                int value = i * colum + y + page * (row * colum - 1);
                button.tag = value;
                
                [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"f%03d.png",value]] forState:UIControlStateNormal];
            }
			[button addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:button];
		}
	}
}

-(void)selected:(UIButton*)bt
{
    if (bt.tag==10000) {
        NSLog(@"点击删除");
        [delegate selectedFacialView:@"删除"];
    }else{
        //NSLog(@"tag === %d",bt.tag);
        
        //NSString *str=[faces objectAtIndex:bt.tag];   系统表情用
        
        NSString *serviceStr = [NSString stringWithFormat:@"[f%03d]",bt.tag];
        //NSString *str = [facesDic objectForKey:[NSString stringWithFormat:@"f%03d",bt.tag]];
        NSString *str = [[facesDic allKeysForObject:serviceStr] objectAtIndex:0];
        NSLog(@"点击表情%@",str);
        [delegate selectedFacialView:str];
    }	
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/
- (void)dealloc {
    [super dealloc];
}
@end
