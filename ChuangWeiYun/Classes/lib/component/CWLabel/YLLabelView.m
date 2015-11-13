//
//  YLLabelView.m
//  cw
//
//  Created by yunlai on 13-12-12.
//
//

#import "YLLabelView.h"
#import <CoreText/CoreText.h>

@implementation YLLabelView

//- (void)dealloc
//{
//    [_text release];
//    [super dealloc];
//}
//
//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        self.font = 14;
//        self.text = @"请给YLView.text赋值";
//        self.line = 0.5;
//        self.paragraph = 3;
//        self.character = 1;
//    }
//    return self;
//}
//
//- (void)drawRect:(CGRect)rect
//{
//    [super drawRect:rect];
//    
//    //创建AttributeStringfdsa
//    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]
//                                         initWithString:self.text];
//    //创建字体以及字体大小
//    CTFontRef helvetica = CTFontCreateWithName(CFSTR("ArialMT"), self.font, NULL);
//    CTFontRef helveticaBold = CTFontCreateWithName(CFSTR("ArialMT"), self.font, NULL);
//    //字体，把helvetica 样式加到整个，string上
//    [string addAttribute:(id)kCTFontAttributeName
//                   value:(id)helvetica
//                   range:NSMakeRange(0, [string length])];
//    
//    //字体样式 ,把helveticaBold 样式加到整个，string上
//    [string addAttribute:(id)kCTFontAttributeName
//                   value:(id)helveticaBold
//                   range:NSMakeRange(0, [string length])];
//    
//    //颜色,此处为黑色，你可以自己改颜色，[UIColor redColor]
//    [string addAttribute:(id)kCTForegroundColorAttributeName
//                   value:(id)[UIColor darkGrayColor].CGColor
//                   range:NSMakeRange(0, [string length])];
//    
//    //创建文本对齐方式
//    CTTextAlignment alignment = kCTJustifiedTextAlignment;//左右对齐
//    CTParagraphStyleSetting alignmentStyle;
//    alignmentStyle.spec=kCTParagraphStyleSpecifierAlignment;
//    alignmentStyle.valueSize=sizeof(alignment);
//    alignmentStyle.value=&alignment;
//    
//    
//    //设置字体间距
//    double number = self.character;
//    CFNumberRef num = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, &number);
//    [string addAttribute:(id)kCTKernAttributeName value:(id)num range:NSMakeRange(0, [string length])];
//    CFRelease(num);
//    
//    //创建文本,行间距
//    CGFloat lineSpace=self.line;//间距数据
//    CTParagraphStyleSetting lineSpaceStyle;
//    lineSpaceStyle.spec=kCTParagraphStyleSpecifierLineSpacing;
//    lineSpaceStyle.valueSize=sizeof(lineSpace);
//    lineSpaceStyle.value=&lineSpace;
//    
//    //设置  段落间距
//    CGFloat paragraph = self.paragraph;
//    CTParagraphStyleSetting paragraphStyle;
//    paragraphStyle.spec = kCTParagraphStyleSpecifierParagraphSpacing;
//    paragraphStyle.valueSize = sizeof(CGFloat);
//    paragraphStyle.value = &paragraph;
//    
//    //创建样式数组
//    CTParagraphStyleSetting settings[]={
//        alignmentStyle,lineSpaceStyle,paragraphStyle
//    };
//    
//    //设置样式
//    CTParagraphStyleRef paragraphStyle1 = CTParagraphStyleCreate(settings, sizeof(settings));
//    
//    //给字符串添加样式attribute
//    [string addAttribute:(id)kCTParagraphStyleAttributeName
//                   value:(id)paragraphStyle1
//                   range:NSMakeRange(0, [string length])];
//    
//    // layout master
//    CTFramesetterRef  framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);
//    //计算文本绘制size ，这里300是文字宽度，你可以自己更改为247，但是要记得，在height 方法里的这个位置，也改为247
//    CGSize tmpSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,0), NULL, CGSizeMake(300, MAXFLOAT), NULL);
//    //创建textBoxSize以设置view的frame
//    CGSize textBoxSize = CGSizeMake((int)tmpSize.width + 1, (int)tmpSize.height + 1);
//    //    NSLog(@"textBoxSize0  == %f,%f,%f",textBoxSize.width,textBoxSize.height,textBoxSize.width / textBoxSize.height);
//    self.frame = CGRectMake(0, 0, textBoxSize.width , textBoxSize.height);
//
//    RELEASE_SAFE(string);
//
//    
//    CGMutablePathRef leftColumnPath = CGPathCreateMutable();
//    CGPathAddRect(leftColumnPath, NULL,
//                  CGRectMake(0, 0,
//                             self.bounds.size.width,
//                             self.bounds.size.height));
//    
//    CTFrameRef leftFrame = CTFramesetterCreateFrame(framesetter,
//                                                    CFRangeMake(0, 0),
//                                                    leftColumnPath, NULL);
//    
//    //    NSLog(@"textBoxSize1  == %f,%f",self.frame.size.width,self.frame.size.height);
//    // flip the coordinate system
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    
//    CGContextClearRect(context, self.frame);
//    CGContextSetFillColorWithColor(context, [[UIColor clearColor]CGColor]);
//    CGContextFillRect(context, CGRectMake(0, 0, 320, self.frame.size.height));
//    
//    
//    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
//    CGContextTranslateCTM(context, 0, self.bounds.size.height);
//    CGContextScaleCTM(context, 1.0, -1.0);
//    
//    // draw
//    CTFrameDraw(leftFrame, context);
//    
//    // cleanup
//    
//    CGPathRelease(leftColumnPath);
//    CFRelease(framesetter);
////    CFRelease(helvetica);
////    CFRelease(helveticaBold);
//    
//    UIGraphicsPushContext(context);
//}

#pragma mark  - 计算高度的方法
/*
 character 字间距
 line 行间距
 pragraph 段间距
 */
+ (CGSize)height:(NSString *)text Font:(CGFloat)font Character:(CGFloat)character Line:(CGFloat)line Pragraph:(CGFloat)pragraph
{
    //创建AttributeStringfdsa
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]
                                         initWithString:text];
    //创建字体以及字体大小
    CTFontRef helvetica = CTFontCreateWithName(CFSTR("ArialMT"), font, NULL);
    CTFontRef helveticaBold = CTFontCreateWithName(CFSTR("ArialMT"), font, NULL);
    //添加字体目标字符串从下标0开始到字符串结尾
    [string addAttribute:(id)kCTFontAttributeName
                   value:(id)helvetica
                   range:NSMakeRange(0, [string length])];
    
    CFRelease(helvetica);
    
    //添加字体目标字符串从下标0开始，截止到4个单位的长度
    [string addAttribute:(id)kCTFontAttributeName
                   value:(id)helveticaBold
                   range:NSMakeRange(0, [string length])];
    
    CFRelease(helveticaBold);
    
    
    [string addAttribute:(id)kCTForegroundColorAttributeName
                   value:(id)[UIColor clearColor].CGColor
                   range:NSMakeRange(0, [string length])];
    
    CTTextAlignment alignment = kCTJustifiedTextAlignment;//这种对齐方式会自动调整，使左右始终对齐
    CTParagraphStyleSetting alignmentStyle;
    alignmentStyle.spec=kCTParagraphStyleSpecifierAlignment;//指定为对齐属性
    alignmentStyle.valueSize=sizeof(alignment);
    alignmentStyle.value=&alignment;
    
    //设置字体间距
    double number = character;
    CFNumberRef num = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, &number);
    [string addAttribute:(id)kCTKernAttributeName value:(id)num range:NSMakeRange(0, [string length])];
    CFRelease(num);
    
    //创建文本行间距
    CGFloat lineSpace=line;//间距数据
    CTParagraphStyleSetting lineSpaceStyle;
    lineSpaceStyle.spec=kCTParagraphStyleSpecifierLineSpacing;//指定为行间距属性
    lineSpaceStyle.valueSize=sizeof(lineSpace);
    lineSpaceStyle.value=&lineSpace;
    
    //设置段落间距
    CGFloat paragraph = pragraph;
    CTParagraphStyleSetting paragraphStyle;
    paragraphStyle.spec = kCTParagraphStyleSpecifierParagraphSpacing;
    paragraphStyle.valueSize = sizeof(CGFloat);
    paragraphStyle.value = &paragraph;
    
    //创建样式数组
//    CTParagraphStyleSetting settings[]={
//        alignmentStyle,lineSpaceStyle,paragraphStyle
//    };
    
    //设置样式
//    CTParagraphStyleRef paragraphStyle1 = CTParagraphStyleCreate(settings, sizeof(settings));
//    //给字符串添加样式attribute
//    [string addAttribute:(id)kCTParagraphStyleAttributeName
//                   value:(id)paragraphStyle1
//                   range:NSMakeRange(0, [string length])];
//    
//    CFRelease(paragraphStyle1);
    
    // layout master
    CTFramesetterRef  framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);
    //计算文本绘制size
    CGSize tmpSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,0), NULL, CGSizeMake(280, MAXFLOAT), NULL);
    //创建textBoxSize以设置view的frame
    CGSize textBoxSize = CGSizeMake((int)tmpSize.width + 1, (int)tmpSize.height + 1);
    
    RELEASE_SAFE(string);
    CFRelease(framesetter);

    return textBoxSize;
}

@end
