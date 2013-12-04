

#import <Foundation/Foundation.h>

@interface OperationSingleton : NSObject

typedef void(^performBlock)();

+(instancetype)sharedOperation;

-(void)performBlockOnPrivateQueue:(void (^)())performBlock;

@end
