


#include "IOSPrimitiveArray.h"
#include "J2ObjC_source.h"
#include "c.h"
#include "java/util/List.h"


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

/*static inline NSArray *ArrayWithJavaUtilList(id<JavaUtilList> list) {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    id <JavaUtilIterator> iterator = [list iterator];
    
}*/

+ (NSString *)deobfuscateWithNSString:(NSString *)obfuscatedText {
    IOSByteArray *buffer = [IOSByteArray arrayWithLength:obfuscatedText.length];
    [buffer replaceBytes:[obfuscatedText UTF8String] length:obfuscatedText.length offset:0];
    ALCc_deobfuscateWithByteArray_withInt_(buffer, obfuscatedText.length);
    NSString *str = [NSString stringWithBytes:buffer];
    return str;
}

+ (NSString *)obfuscateWithNSString:(NSString *)clearText {
    IOSByteArray *buffer = [IOSByteArray arrayWithLength:clearText.length];
    [buffer replaceBytes:[clearText UTF8String] length:clearText.length offset:0];
    ALCc_deobfuscateWithByteArray_withInt_(buffer, clearText.length);
    NSString *str = [NSString stringWithBytes:buffer];
    return str;
}
@end


void ALCc_obfuscateWithByteArray_withInt_(IOSByteArray *data, jint length) {
  ALCc_initialize();

}

void ALCc_deobfuscateWithByteArray_withInt_(IOSByteArray *data, jint length) {
  ALCc_initialize();
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
