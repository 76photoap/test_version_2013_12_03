//
//  ProfileHeader.m
//  krowd
//
//  Created by Julie Caccavo on 8/22/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import "ProfileHeader.h"

@interface ProfileHeader ()

- (IBAction)showFollowers:(UITapGestureRecognizer*)sender;
- (IBAction)showFollowing:(UITapGestureRecognizer *)sender;

@end

@implementation ProfileHeader

@synthesize oNameLabel;
@synthesize oNumberFollowersLabel;
@synthesize oNumberFollowingLabel;
@synthesize oNumberPostsLabel;
@synthesize oProfilePictureView;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)showFollowers:(UITapGestureRecognizer*)sender{
    NSNotificationCenter *notCenter = [NSNotificationCenter defaultCenter];
    [notCenter postNotificationName:@"showFollowersNotification" object:nil];
}


- (IBAction)showFollowing:(UITapGestureRecognizer *)sender{
    NSNotificationCenter *notCenter = [NSNotificationCenter defaultCenter];
    [notCenter postNotificationName:@"showFollowingNotification" object:nil];}


@end
