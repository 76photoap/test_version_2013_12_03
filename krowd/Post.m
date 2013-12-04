//
//  Post.m
//  krowd
//
//  Created by Julie Caccavo on 8/16/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import "Post.h"
#import <Parse/PFObject+Subclass.h>
#import <Parse/Parse.h>

@implementation Post

@dynamic caption;
@dynamic postImage;
@dynamic user;
@dynamic likes;
@dynamic venue;
@dynamic numberOfLikes;
@dynamic likeable;
@dynamic city;
@dynamic week;

+ (NSString *)parseClassName {
    return @"Post";
}

@end

