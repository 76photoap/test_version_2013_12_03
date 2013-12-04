//
//  ProfileHeader.h
//  krowd
//
//  Created by Julie Caccavo on 8/22/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileHeader : UIView <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *oProfilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *oNumberPostsLabel;
@property (weak, nonatomic) IBOutlet UILabel *oNumberFollowersLabel;
@property (weak, nonatomic) IBOutlet UILabel *oNumberFollowingLabel;
@property (weak, nonatomic) IBOutlet UILabel *oNameLabel;
@property (weak, nonatomic) IBOutlet UIView *oBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *oNumberLikesLabel;

@end
