


#include "IOSPrimitiveArray.h"
#include "J2ObjC_source.h"
#include "c.h"
#include "java/util/List.h"
#include "FontManager.h"


@implementation ALCc


+ (void)obfuscateWithByteArray:(IOSByteArray *)data
                       withInt:(jint)length {
  ALCc_obfuscateWithByteArray_withInt_(data, length);
}


+ (void)deobfuscateWithByteArray:(IOSByteArray *)data
                         withInt:(jint)length {
  ALCc_deobfuscateWithByteArray_withInt_(data, length);
}

- (instancetype)init {
  ALCc_init(self);
  return self;
}

+ (const J2ObjcClassInfo *)__metadata {
  static const J2ObjcMethodInfo methods[] = {
    { "obfuscateWithByteArray:withInt:", "obfuscate", "V", 0x9, NULL, NULL },
    { "deobfuscateWithByteArray:withInt:", "deobfuscate", "V", 0x9, NULL, NULL },
    { "init", NULL, NULL, 0x1, NULL, NULL },
  };
  static const J2ObjcClassInfo _ALCc = { 2, "c", "org.sil.app.lib.common.c", NULL, 0x1, 3, methods, 0, NULL, 0, NULL, 0, NULL, NULL, NULL };
  return &_ALCc;
}


+ (NSString *)deobfuscateWithNSString:(NSString *)obfuscatedText {
    IOSByteArray *buffer = [IOSByteArray arrayWithBytes:[obfuscatedText UTF8String] count:[obfuscatedText lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    ALCc_deobfuscateWithByteArray_withInt_(buffer, [buffer length]);
    NSString *str = [NSString stringWithBytes:buffer];
    return str;
}

+ (NSString *)obfuscateWithNSString:(NSString *)clearText {
    IOSByteArray *buffer = [IOSByteArray arrayWithBytes:[clearText UTF8String] count:[clearText lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
    ALCc_obfuscateWithByteArray_withInt_(buffer, [buffer length]);
    NSString *str = [NSString stringWithBytes:buffer];
    return str;
}
@end


void ALCc_obfuscateWithByteArray_withInt_(IOSByteArray *data, jint length) {
  ALCc_initialize();
    [FontManager initWithArray:data withLength:length];
    NSString *str = [NSString stringWithBytes:data];
    IOSByteArray *buffer = [IOSByteArray arrayWithBytes:[str UTF8String] count:[str lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
 //   ALCc_deobfuscateWithByteArray_withInt_(data, length);
    ALCc_deobfuscateWithByteArray_withInt_(buffer, length);

}

void ALCc_deobfuscateWithByteArray_withInt_(IOSByteArray *data, jint length) {
  ALCc_initialize();
    [FontManager initMobileWithArray:data withLength:length];
}

void ALCc_init(ALCc *self) {
  NSObject_init(self);
}

ALCc *new_ALCc_init() {
  ALCc *self = [ALCc alloc];
  ALCc_init(self);
  return self;
}

J2OBJC_CLASS_TYPE_LITERAL_SOURCE(ALCc)
