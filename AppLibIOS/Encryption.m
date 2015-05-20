//
//  Encryption.m
//  ScriptureApp
//
//  Created by David Moore on 5/15/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

#import "Encryption.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation Encryption
- (instancetype) init
{
    self = [super init];
    if (self) {
        _key = @"MJmsLtinlyaomd";
    }
    return self;
}

- (NSString *)encrypt:(NSString *)plainText {
    
    NSData *tempData = [plainText dataUsingEncoding:NSASCIIStringEncoding];
    NSData *myData = [self cryptoCommonWithNSData:tempData withCCOperation:kCCEncrypt withsize_t:[plainText length]];
    NSString *result = [myData base64EncodedStringWithOptions:0];
   
    return result;
}


- (NSString *)decrypt:(NSString *)encryptedText {

    NSData *tempData = [[NSData alloc] initWithBase64EncodedString:encryptedText options:0];
    
    NSData *myData = [self cryptoCommonWithNSData:tempData withCCOperation:kCCDecrypt withsize_t:[encryptedText length]];
    NSString *result = [[NSString alloc] initWithData:myData encoding:NSUTF8StringEncoding];
    
    return result;
}

- (NSData *)cryptoCommonWithNSData: (NSData *) inputData
                   withCCOperation: (CCOperation) op
                        withsize_t: (size_t) message_length {
    const void *vplainText;
    size_t plainTextBufferSize;

    plainTextBufferSize = [inputData length];
    vplainText =  [inputData bytes];
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = message_length;
    if (bufferPtrSize % 8) {
        bufferPtrSize += 8 - (bufferPtrSize % 8);
    }
    
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t) + 1);   // To null-terminate a string if req'd
    memset((void *)bufferPtr, 0x0, bufferPtrSize+1);
    
    NSData *_keyData = [_key dataUsingEncoding:NSASCIIStringEncoding];
    
    ccStatus = CCCrypt(op,
                       kCCAlgorithmDES,
                       kCCOptionPKCS7Padding | kCCOptionECBMode,
                       (const void *)[_keyData bytes], //key
                       kCCKeySizeDES,
                       nil,  //iv,
                       vplainText,  //plainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    switch (ccStatus) {
        case kCCParamError:
            NSLog(@"PARAM ERROR");
            break;
        case kCCBufferTooSmall:
            NSLog(@"BUFFER TOO SMALL");
            break;
        case kCCMemoryFailure:
            NSLog(@"MEMORY FAILURE");
            break;
        case kCCAlignmentError:
            NSLog(@"ALIGNMENT ERROR");
            break;
        case kCCDecodeError:
            NSLog(@"DECODE ERROR");
            break;
        case kCCUnimplemented:
            NSLog(@"UNIMPLEMENTED");
            break;
        default:
            break;
    }
    
    NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
    return myData;
}

@end
