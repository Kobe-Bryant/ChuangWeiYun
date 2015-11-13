//
//  CallSystemApp.h
//  ShareDemo
//
//  Created by yunlai on 13-7-12.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface CallInfoApp : NSObject <MFMessageComposeViewControllerDelegate>

- (void)sendMessageTo:(NSString*)phone withContent:(NSString*)body;

@end
