//
//  GCDSingleton.h

/**
 Ussage:
 Then to implement in the .h
 
 @interface MyClass : NSObject
 + (MyClass *) sharedMyClass;
 @end
 
 and in the .m
 
 #import "MyClass.h"
 
 @implementation MyClass
 
 SINGLETON_GCD(MyClass);
 
 - (id) init {
 if ( (self = [super init]) ) {
 // Initialization code here.
 }
 return self;
 }
 
 @end
 
 **/

/*!
 * @function Singleton GCD Macro
 */

#ifndef GCDSingleton
#define GCDSingleton(classname)                        \
\
+(classname*)sharedInstance{                      \
\
static dispatch_once_t pred;                        \
__strong static classname * instance = nil;\
dispatch_once( &pred, ^{                            \
instance = [[self alloc] init]; });    \
return instance;                           \
}
#endif

