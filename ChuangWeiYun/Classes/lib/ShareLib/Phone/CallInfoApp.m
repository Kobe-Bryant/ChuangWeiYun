//
//  CallSystemApp.m
//  ShareDemo
//
//  Created by yunlai on 13-7-12.
//  Copyright (c) 2013年 ios. All rights reserved.
//

#import "CallInfoApp.h"
#import "PfShare.h"

@implementation CallInfoApp

- (void)sendMessageTo:(NSString*)phone withContent:(NSString*)body
{
	BOOL canSendSMS = [MFMessageComposeViewController canSendText];
	if (canSendSMS) {
		MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
		picker.messageComposeDelegate = self;
		picker.body = body;
		NSArray *phoneArray = [NSArray arrayWithObject:phone];
		picker.recipients = phoneArray;
        [[UIApplication sharedApplication].keyWindow.rootViewController presentModalViewController:picker animated:YES];
		[picker release];
	} else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil
                                                       message:@"系统不支持短信功能"
                                                      delegate:nil
                                             cancelButtonTitle:@"确定"
                                             otherButtonTitles: nil];
        [alert show];
        [alert release];
	}
}

#pragma mark - MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
		case MessageComposeResultCancelled:
			NSLog(@"Cancelled");
			break;
		case MessageComposeResultFailed:
			NSLog(@"发短信错误");
			break;
		case MessageComposeResultSent:
			break;
			
		default:
			break;
	}
    [controller dismissModalViewControllerAnimated:YES];
}

@end
