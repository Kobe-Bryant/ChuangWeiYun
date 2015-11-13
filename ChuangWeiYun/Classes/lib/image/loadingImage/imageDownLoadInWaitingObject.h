//
//  imageDownLoadInWaitingObject.h
//  云来
//
//  Created by 掌商 on 11-5-26.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface imageDownLoadInWaitingObject : NSObject {
	NSString *imageURL;
	NSIndexPath *indexPath;
	int imageType;
    id delegate;
}
@property (nonatomic, assign) int imageType;
@property (nonatomic, retain) NSString *imageURL;
@property (nonatomic, retain) NSIndexPath *indexPath;
@property (nonatomic, retain) id delegate;
- (id) init:(NSString*)url withIndexPath:(NSIndexPath *)index withImageType:(int)Type delegate:(id)adelegate;
@end
