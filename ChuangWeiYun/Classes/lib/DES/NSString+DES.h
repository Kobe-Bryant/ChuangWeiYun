//
//  NSString+DES.h
//  loary DES
//
//  Created by JiaYing on 13-9-5.
//  Copyright (c) 2013年 lvshouyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DES)
+ (NSString *) encryptUseDES:(NSString *)clearText key:(NSString *)key;
+ (NSString*) decryptUseDES:(NSString*)cipherText key:(NSString*)key;
@end
