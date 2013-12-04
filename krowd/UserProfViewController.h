//
//  UserProfViewController.h
//  krowd
//
//  Created by Julie Caccavo on 9/25/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"


@interface UserProfViewController : UITableViewController
@property (strong, nonatomic)User *userToShow;
@property (strong, nonatomic) NSMutableData *imageData;
@property (strong, nonatomic) id tracker;


@end
