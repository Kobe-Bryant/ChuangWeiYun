//
//  main.m
//  cw
//
//  Created by siphp on 13-8-7.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    @try {
        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
        int retVal = UIApplicationMain(argc, argv, nil, nil);
        [pool release];
        return retVal;
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception reason]);
        
    }
    @finally {
        
    }
    
}
