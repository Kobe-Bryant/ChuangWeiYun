//
//  PopPfShareFail.h
//  cw
//
//  Created by yunlai on 13-9-26.
//
//

#import "PopupView.h"

typedef void (^CwPfShareClosingBlock)(void);

@interface PopPfShareFail : PopupView
{
    CwPfShareClosingBlock pfShareClosingBlock;
}

@property (copy, nonatomic) CwPfShareClosingBlock pfShareClosingBlock;

- (id)initType:(int)type;

@end
