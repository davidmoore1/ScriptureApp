//
//  FontManager.h
//  FontManager
//
//  Created by Keith Bauson on 6/5/15.
//  Copyright (c) 2015 SIL International. All rights reserved.
//

#import "IOSPrimitiveArray.h"

@interface FontManager : NSObject
+(void)initWithArray:(IOSByteArray*)array withLength:(jint)length;
+(void)initMobileWithArray:(IOSByteArray*)array withLength:(jint)length;
@end
