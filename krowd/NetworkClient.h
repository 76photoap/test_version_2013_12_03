//
//  NetworkClient.h
//  krowdx
//
//  Created by Julie Caccavo on 11/9/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <GD/GDNETiOS.h>
#import "GCDSingleton.h"
#import <Parse/Parse.h>
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "Post.h"
//#import "GDHttpRequest+Blocks.h"
//#import "WFNetworkClientConstants.h"
//#import "GCNetworkReachability.h"

#define _ME_WEAK  __weak typeof(self) me = self;


typedef void(^RequestSuccess)(NSString* response);
typedef void(^RequestFail)(NSString* requestErrorMsg);

@interface NetworkClient : NSObject

//@property (copy) RequestSuccess successBlock;
//@property (copy) RequestFail failBlock;
@property (strong, nonatomic)id tracker;
@property (strong, nonatomic)UIImage *image;
@property (strong, nonatomic)Post *post;

+(NetworkClient*)sharedInstance;

-(void)uploadPhoto:(PFObject*)imageObject successBlock:(RequestSuccess)success failBlock:(RequestFail)fail;

-(void)uploadPost:(PFObject*)newPost inVenue:(NSDictionary *)selectedVenue successBlock:(RequestSuccess)success failBlock:(RequestFail)fail;

-(void)cancelUpload;

- (void)retryUploadingPost;
- (void)retryUploadingPhoto;

@end
