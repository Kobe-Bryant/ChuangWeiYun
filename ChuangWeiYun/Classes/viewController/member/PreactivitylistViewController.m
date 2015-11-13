//
//  PreactivitylistViewController.m
//  cw
//
//  Created by yunlai on 13-8-29.
//
//

#import "PreactivitylistViewController.h"

@interface PreactivitylistViewController ()

@end

@implementation PreactivitylistViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"我的优惠券";
    self.view.backgroundColor = KCWViewBgColor;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
