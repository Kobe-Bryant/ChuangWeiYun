//
//  CityLoction.h
//  cw
//
//  Created by yunlai on 13-11-24.
//
//

#import <Foundation/Foundation.h>
#import "CityChooseViewController.h"

@class PopLoction;

@interface CityLoction : NSObject <CityChooseViewControllerDelegate>
{
    PopLoction *loctionView;
}

+ (CityLoction *)defaultSingle;

- (BOOL)showLoctionView;

@end
