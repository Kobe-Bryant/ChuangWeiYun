//
//  NSString+DES.m
//  loary DES
//
//  Created by JiaYing on 13-9-5.
//  Copyright (c) 2013年 lvshouyi. All rights reserved.
//

#import "NSString+DES.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "GTMBase64CW.h"
#import "GTMDefines.h"
@implementation NSString (DES)
+ (NSString *) encryptUseDES:(NSString *)clearText key:(NSString *)key
{
    //一般对加密的字符串采用UTF-8编码  NSData存储的就是二进制数据
    NSData *data = [clearText dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //确定加密过后的字符串在内存中存放的大小，根据文档，对于块密码方式（这个库还包括流密码方式）
    //加密过后的字符串大小总是小于或等于加密之前数据的大小加上对应加密算法的块大小
    //但看到一些大牛还这样一下 & ~(kCCBlockSizeDES - 1) 目前不知道为嘛
    size_t bufferSize = ([data length] + kCCBlockSizeDES)& ~(kCCBlockSizeDES - 1);
    //void *buffer = malloc(bufferSize);//可以手动创建buffer，但之后要记得free掉
    unsigned char buffer[bufferSize]; //定义输出加密串所占内存空间
    memset(buffer, 0, sizeof(char));  //采用ios中宏定义好的方法分配空间，可免去手动free
    size_t numBytesEncrypted = 0;    //输出加密串的字节数
    
    //加密数据，采用库中的CCCrypt方法，这个方法会按次序执行CCCrytorCreate(),
    // CCCryptorUpdate(), CCCryptorFinal(), and CCCryptorRelease() 如果开发者自己create这个对象，
    //那么后面就必须执行final、release之类的函数，CCCrypt方法一次性解决
    
    // Byte iv[] = {0x12, 0x34, 0x56, 0x78, 0x90, 0xAB, 0xCD, 0xEF};
    //Byte iv[] = {1,2,3,4,5,6,7,8}; 加密所需的随机字符
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,    //加密方式，kCCEncrypt加密  kCCDecrypt解密
                                          kCCAlgorithmDES, //采用的加密算法，内置包含AES、DES、
                                          //3DES、其他还有四个，不知道是什么
                                          //后续讨论
                                          //加密额外参数，注意此处各个平台之间指定的时候要记得一样
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          [key UTF8String], //加密密匙 UTF8的字符串
                                          kCCKeySizeDES,  //密匙长度字节 各算法有对应的长度宏
                                          nil,     //随机字符，可指定也可不指定，各平台之间不绝对
                                          [data bytes], //待加密串的字节长度
                                          [data length], //待加密串的长度
                                          buffer,        //输出已加密串的内存地址
                                          bufferSize,    //已加密串的大小
                                          &numBytesEncrypted);
    
    NSString* plainText = nil;
    if (cryptStatus == kCCSuccess) {
        NSData *dataTemp = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        plainText = [GTMBase64CW stringByEncodingData:dataTemp];
    }else{
        NSLog(@"DES加密失败");
    }
    return plainText;
}

//解密
+ (NSString*) decryptUseDES:(NSString*)cipherText key:(NSString*)key {
    // 利用 GTMBase64 解碼 Base64 字串
    NSData* cipherData = [GTMBase64CW decodeString:cipherText];
    size_t bufferSize = ([cipherData length] + kCCBlockSizeDES)& ~(kCCBlockSizeDES - 1);
    //unsigned char buffer[1024];
    unsigned char buffer[bufferSize];
    memset(buffer, 0, sizeof(char));
    size_t numBytesDecrypted = 0;
    
    // IV 偏移量不需使用
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          [key UTF8String],
                                          kCCKeySizeDES,
                                          nil,
                                          [cipherData bytes],
                                          [cipherData length],
                                          buffer,
                                          bufferSize,//1024,
                                          &numBytesDecrypted);
    NSString* plainText = nil;
    if (cryptStatus == kCCSuccess) {
        NSData* data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesDecrypted];
        plainText = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    }
    return plainText;
}
@end
