//
//  UserAccount.h
//  krowd
//
//  Created by Julie Caccavo on 8/16/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import <Parse/Parse.h>

@interface User : PFUser

//Inherits properties "username", "password", "email" from PFUser

@property (strong, nonatomic)NSString *name;
@property (strong, nonatomic)NSDictionary *profile;
@property (strong, nonatomic)NSString *profilePictureURL;
@property (strong, nonatomic)NSString *currentLocation;
@property (strong, nonatomic)NSString *cityOfResidence;

@end
