//
//  IOSFactory.m
//  ScriptureApp
//
//  Created by David Moore on 5/28/15.
//  Copyright (c) 2015 David Moore. All rights reserved.
//

#import "IOSFactory.h"
#include "Encryption.h"
@implementation IOSFactory


- (NSString *)decryptWithNSString:(NSString *)encryptedString {
    Encryption *encryptor = [[Encryption alloc] init];
    NSString *decryptedString = [encryptor decryptWithNSString: encryptedString];

    return decryptedString;
}


@end

