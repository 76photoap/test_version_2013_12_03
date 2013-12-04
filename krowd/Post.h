//
//  Post.h
//  krowd
//
//  Created by Julie Caccavo on 8/16/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import <Parse/Parse.h>
#import "User.h"
#import "Venue.h"

@interface Post : PFObject<PFSubclassing>

@property (strong, nonatomic)NSString *caption;
@property (strong, nonatomic)PFFile *postImage;
@property (strong, nonatomic)User *user;
@property (strong, nonatomic)NSMutableArray *likes;
@property (strong, nonatomic)Venue *venue;
@property (strong, nonatomic)NSNumber *numberOfLikes;
@property (assign, nonatomic)BOOL likeable;
@property (strong, nonatomic)NSDate *week;
@property (strong, nonatomic)NSString *city;

+ (NSString *)parseClassName;

@end
