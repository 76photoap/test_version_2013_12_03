//
//  Venue.h
//  krowd
//
//  Created by Julie Caccavo on 8/16/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import <Parse/Parse.h>

@interface Venue : PFObject<PFSubclassing>

@property (strong, nonatomic)NSString *name;
@property (strong, nonatomic)NSString *foursquareId;
@property (strong, nonatomic)NSString *url;
@property (strong, nonatomic)NSDictionary *location;
@property (strong, nonatomic)NSDictionary *contact;
@property (strong, nonatomic)NSDictionary *categories;


+ (NSString *)parseClassName;

@end
