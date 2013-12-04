//
//  Venue.m
//  krowd
//
//  Created by Julie Caccavo on 8/16/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import "Venue.h"
#import <Parse/PFObject+Subclass.h>
#import <Parse/Parse.h>
//#import

@implementation Venue

@dynamic name;
@dynamic foursquareId;
@dynamic url;
@dynamic location;
@dynamic contact;
@dynamic categories;

+ (NSString *)parseClassName {
    return @"Venue";
}

@end
