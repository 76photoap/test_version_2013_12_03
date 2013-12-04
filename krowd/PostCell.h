//
//  PostCell.h
//  krowd
//
//  Created by Julie Caccavo on 8/20/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostCell : UITableViewCell <UIGestureRecognizerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *oUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *oDateLabel;
@property (nonatomic) UIButton *oLikesLabel;
@property (nonatomic) UIButton *oVenueButton;
@property (weak, nonatomic) IBOutlet UIImageView *oPostImageView;
@property (weak, nonatomic) IBOutlet UIImageView *oProfilePictureView;
@property (weak, nonatomic) IBOutlet UIView *oTitleBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *oLikeButton;
@property (nonatomic) UITextView *oCaptionLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *oActivityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *oLikesStarImage;
@property (weak, nonatomic) IBOutlet UIButton *oDeleteButton;
@property (strong, nonatomic)UIColor *yellowColor;
@property (strong, nonatomic)UIColor *grayColor;

- (void)createCustomLabel:(NSString*)text;
- (void)createCustomCaptionLabel:(NSString*)text;
- (void)createCustomLikesLabel:(NSInteger)numberOfLikes;

@end
