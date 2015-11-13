//
//  imageDownLoadInWaitingObject.m
//  云来
//
//  Created by 掌商 on 11-5-26.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "imageDownLoadInWaitingObject.h"

@implementation imageDownLoadInWaitingObject

@synthesize imageURL;
@synthesize indexPath;
@synthesize imageType;
@synthesize delegate;

- (id) init:(NSString*)url withIndexPath:(NSIndexPath *)index withImageType:(int)Type delegate:(id)adelegate 
{
	self = [super init];//调用父类初始化函数
	if (self != nil)
	{
		imageType = Type;
		self.imageURL = url;
		self.indexPath = index;     //初始化成员变量
        self.delegate = adelegate;
	}
	return self;//返回自身
}

-(void)dealloc
{
	self.imageURL = nil;
	self.indexPath = nil;
    self.delegate = nil;
	[super dealloc];
}
@end
