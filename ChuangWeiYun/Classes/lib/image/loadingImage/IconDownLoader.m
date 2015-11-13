//
//  IconDownLoader.m
//  MBSNSBrowser
//
//  Created by 掌商 on 11-1-24.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IconDownLoader.h"
#import "Common.h"
#import "IconPictureProcess.h"

#define kCardIconHeight 48

@implementation IconDownLoader

@synthesize imageType;
@synthesize downloadURL;
@synthesize indexPathInTableView;
@synthesize delegate;
@synthesize activeDownload;
@synthesize imageConnection;
@synthesize cardIcon;
@synthesize requestClass;

#pragma mark
/*-(id)init{

	if (self = [super init]) {
        delegateExist = YES;
    }
    return self;
}*/
- (void)dealloc
{
	[Common setActivityIndicator:NO];
    [downloadURL release];
    [indexPathInTableView release];
    
    [activeDownload release];
    
    [imageConnection cancel];
    [imageConnection release];
    [cardIcon release];
    [super dealloc];
}

- (void)startDownload
{
    self.activeDownload = [NSMutableData data];
    NSURLRequest *request = [[NSURLRequest alloc]
                             initWithURL:[NSURL URLWithString:downloadURL]
                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                             timeoutInterval:10];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.imageConnection = conn;
    [conn release];
    [request release];
    
	[Common setActivityIndicator:YES];
}

- (void)cancelDownload
{
	[Common setActivityIndicator:NO];
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}

#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.activeDownload = nil;
    [Common setActivityIndicator:NO];
	self.imageConnection = nil;
    self.cardIcon = nil;
    //NSLog(@"didFailWithError  self.downloadURL = %@",self.downloadURL);
    [[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:self.downloadURL];
    if (object_getClass(delegate) == requestClass) {
        [delegate appImageFailLoad:self.downloadURL withImageType:imageType];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connectionyin
{
    //NSLog(@"image download finish");
	[Common setActivityIndicator:NO];
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];

    if(image.size.width > 2.0) {
        self.cardIcon = image;
	} else {
		self.cardIcon = nil;
	}
    
    self.activeDownload = nil;
    [image release];

    self.imageConnection = nil;

    if (object_getClass(delegate) == requestClass) {
        [delegate appImageDidLoad:self.downloadURL withImageType:imageType];
    } else {
        [[IconPictureProcess sharedPictureProcess] removeImageDownloadsProgress:self.downloadURL];
    }
}

@end

