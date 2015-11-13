//
//  InvoiceViewController.h
//  cw
//
//  Created by yunlai on 13-8-26.
//
//

#import <UIKit/UIKit.h>

@protocol InvoiceViewControllerDelegate;

@interface InvoiceViewController : UIViewController <UIAlertViewDelegate>
{
    id <InvoiceViewControllerDelegate> delegate;
    
    NSString *invoiceTitle;
}

@property (assign, nonatomic) id <InvoiceViewControllerDelegate> delegate;

@property (retain, nonatomic) NSString *invoiceTitle;

@end


@protocol InvoiceViewControllerDelegate <NSObject>

@optional
- (void)getInvoiceInfo:(NSString *)text typeText:(NSString *)typeText type:(int)type;

@end