//
//  IOSFileManager.m
//  ScriptureApp
//
//  Created by David Moore on 7/17/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

#import "IOSFileManager.h"
#include "Encryption.h"

@implementation IOSFileManager


- (NSString *)decryptWithNSString:(NSString *)encryptedString {
    Encryption *encryptor = [[Encryption alloc] init];
    NSString *decryptedString = [encryptor decryptWithNSString: encryptedString];

    return decryptedString;
}

@end

