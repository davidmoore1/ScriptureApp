//
//  FontManager.h
//  FontManager
//
//  Created by Keith Bauson on 6/5/15.
//  Copyright (c) 2015 SIL International. All rights reserved.
//

#import "IOSArray.h"

@interface FontManager : NSObject
+(void)initWithArray:(IOSArray*)array withLength:(jint)length;
+(void)initMobileWithArray:(IOSArray*)array withLength:(jint)length;
@end
