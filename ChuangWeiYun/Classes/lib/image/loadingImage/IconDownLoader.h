//
//  IconDownLoader.h
//  MBSNSBrowser
//
//  Created by 掌商 on 11-1-24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

Class object_getClass(id object);

@class GroupInfo;
@class CardGroupViewController;

@protocol IconDownloaderDelegate 

@optional
- (void)appImageDidLoad:(NSString *)url withImageType:(int)Type;
- (void)appImageFailLoad:(NSString *)url withImageType:(int)Type;

@end

@interface IconDownLoader : NSObject
{
	NSString *downloadURL;
    NSIndexPath *indexPathInTableView;
    id <IconDownloaderDelegate> delegate;
    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
	UIImage *cardIcon;
	int imageType;
    Class requestClass;
}
@property (nonatomic, assign) int imageType;
@property (nonatomic, retain) NSString *downloadURL;
@property (nonatomic, retain) NSIndexPath *indexPathInTableView;
@property (nonatomic, assign) id <IconDownloaderDelegate> delegate;
@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;
@property (nonatomic, retain) UIImage *cardIcon;
@property (nonatomic, retain) Class requestClass;

- (void)startDownload;
- (void)cancelDownload;

@end

