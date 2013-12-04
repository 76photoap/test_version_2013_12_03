

#import "OperationSingleton.h"

@interface OperationSingleton ()

@property (nonatomic, strong) NSOperationQueue *privateQueue;
@property (nonatomic, strong) void (^operationBlock)(NSData *completionData);

@end

@implementation OperationSingleton

+(instancetype)sharedOperation {
    static OperationSingleton *sharedOperation;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedOperation = [OperationSingleton new];
        sharedOperation.privateQueue = [NSOperationQueue new];
    });
    return sharedOperation;
}

-(void)performBlockOnPrivateQueue:(void (^)())performBlock {
    [self.privateQueue addOperationWithBlock:performBlock];
}

@end
