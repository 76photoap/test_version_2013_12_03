//
//  PostCell.m
//  krowd
//
//  Created by Julie Caccavo on 8/20/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import "PostCell.h"
#import <QuartzCore/QuartzCore.h>

@interface PostCell ()
{
    __weak IBOutlet UITapGestureRecognizer *likeTapGesture;
    NSNotificationCenter *notCenter;
    
}
- (IBAction)goToUserProfile:(UITapGestureRecognizer*)sender;
- (IBAction)likePost:(UITapGestureRecognizer *)sender;
- (IBAction)goToVenuePage:(UITapGestureRecognizer *)sender;
- (IBAction)savePhoto:(UILongPressGestureRecognizer *)sender;
- (IBAction)deletePost:(id)sender;
- (IBAction)likePhoto:(id)sender;
- (IBAction)goToProfile:(id)sender;
- (IBAction)disclosureButtonPressed:(id)sender;
- (IBAction)seeLikes:(id)sender;

@end



@implementation PostCell

@synthesize oDateLabel;
@synthesize oLikesLabel;
@synthesize oUsernameLabel;
@synthesize oPostImageView;
@synthesize oCaptionLabel;
@synthesize oProfilePictureView;
@synthesize oActivityIndicator;
@synthesize oLikesStarImage;
@synthesize oDeleteButton;
@synthesize oVenueButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [oPostImageView resignFirstResponder];
        self.grayColor = [UIColor colorWithRed:(140/255.0) green:(140/255.0) blue:(140/255.0) alpha:1] ;
        notCenter = [NSNotificationCenter defaultCenter];
        self.oVenueButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.oCaptionLabel = [UITextView new];
        self.oLikesLabel = [UIButton new];
    }
    return self;
    
}
- (void)awakeFromNib{
    self.oLikeButton.layer.borderColor = [[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0] CGColor];
    self.oLikeButton.layer.borderWidth = 1.0;
    self.oCaptionLabel.textColor = [UIColor whiteColor];
    self.oCaptionLabel.font = [UIFont fontWithName:@"CenturyGothic" size:14.0];
    self.oUsernameLabel.titleLabel.font = [UIFont fontWithName:@"CenturyGothic" size:17.0];
    //self.oLikesLabel.font = [UIFont fontWithName:@"CenturyGothic" size:18.0];
    self.oLikeButton.titleLabel.font = [UIFont fontWithName:@"CenturyGothic" size:18.0];
    self.oDateLabel.font = [UIFont fontWithName:@"CenturyGothic" size:15.0];
}

- (void)createCustomLabel:(NSString*)text{
   
    CGSize size = [text sizeWithFont:[UIFont fontWithName:@"CenturyGothic" size:18.0] constrainedToSize:CGSizeMake(235.0f, 34.0f) lineBreakMode:NSLineBreakByTruncatingTail];
    
    [self.oVenueButton setTitle:text forState:UIControlStateNormal];
    self.oVenueButton.frame = CGRectMake(30, 0, size.width, 34.0f);
    self.oVenueButton.backgroundColor = [UIColor clearColor];
    self.oVenueButton.titleLabel.lineBreakMode =  NSLineBreakByTruncatingTail;
    self.oVenueButton.titleLabel.numberOfLines = 1;
    self.oVenueButton.userInteractionEnabled = YES;
    self.oVenueButton.titleLabel.font = [UIFont fontWithName:@"CenturyGothic" size:18.0];
    self.oVenueButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.oVenueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.oVenueButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [self.oVenueButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
    
    [self.oVenueButton addTarget:self action:@selector(goToVenuePage:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.oTitleBackgroundView addSubview:self.oVenueButton];
}

- (void)createCustomCaptionLabel:(NSString*)text{
    if (text.length < 45){
        self.oCaptionLabel.frame = CGRectMake(6, 281, 308, 36);
    }
    else{
        self.oCaptionLabel.frame = CGRectMake(6, 261, 308, 56);
    }
    self.oCaptionLabel.backgroundColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:0.7];
    self.oCaptionLabel.hidden = NO;
    self.oCaptionLabel.text = text;
    self.oCaptionLabel.userInteractionEnabled = NO;
    self.oCaptionLabel.scrollEnabled = NO;
    [self.oPostImageView addSubview:self.oCaptionLabel];
}

- (void)createCustomLikesLabel:(NSInteger)numberOfLikes{
    
    self.oLikesLabel.frame = CGRectMake(202, 377, 38, 28);
    [self.oLikesLabel setTitleColor:[UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    
    if (numberOfLikes>999 && numberOfLikes<999999) {
        [self.oLikesLabel setTitle:[NSString stringWithFormat:@"%.2fk",(float)numberOfLikes/1000] forState:UIControlStateNormal];
        [self.oLikesLabel.titleLabel setFont:[UIFont fontWithName:@"CenturyGothic" size:14.0]];
    }
    else if (numberOfLikes>99 && numberOfLikes<999){
        [self.oLikesLabel setTitle:[NSString stringWithFormat:@"%i",numberOfLikes] forState:UIControlStateNormal];
        [self.oLikesLabel.titleLabel setFont:[UIFont fontWithName:@"CenturyGothic" size:18.0]];
    }
    else{
        [self.oLikesLabel setTitle:[NSString stringWithFormat:@"%i",numberOfLikes]  forState:UIControlStateNormal];
        [self.oLikesLabel.titleLabel setFont:[UIFont fontWithName:@"CenturyGothic" size:20.0]];
    }
    self.oLikesLabel.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.oLikesLabel.backgroundColor = [UIColor clearColor];
    [self.oLikesLabel addTarget:self action:@selector(displayLikes) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.oLikesLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)likePost:(UITapGestureRecognizer *)sender {
    [notCenter postNotificationName:@"DeletePostNotification" object:self];
}

- (IBAction)deletePost:(id)sender {
    //[notCenter postNotificationName:@"DeletePostNotification" object:self];
}

- (IBAction)likePhoto:(id)sender {
    [notCenter postNotificationName:@"LikeNotification" object:self];
}

- (IBAction)goToProfile:(id)sender {
    [notCenter postNotificationName:@"GoToProfileNotification" object:self];
}

- (IBAction)disclosureButtonPressed:(id)sender {
    [notCenter postNotificationName:@"DeletePostNotification" object:self];
}

- (void)displayLikes{
    [notCenter postNotificationName:@"SeeLikesNotification" object:self];
}

- (IBAction)seeLikes:(id)sender {
    [self displayLikes];
}

- (IBAction)goToUserProfile:(UITapGestureRecognizer*)sender{
    [notCenter postNotificationName:@"GoToProfileNotification" object:self];
}

- (IBAction)goToVenuePage:(UITapGestureRecognizer *)sender{
    [notCenter postNotificationName:@"GoToVenueNotification" object:self];
}

- (IBAction)savePhoto:(UILongPressGestureRecognizer *)sender{
    if (sender.state == UIGestureRecognizerStateBegan){
        [[[UIAlertView alloc]initWithTitle:@"Save photo to Camera Roll?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil] show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Save"])
    {
        UIImageWriteToSavedPhotosAlbum(oPostImageView.image, nil, nil, nil);
    }
}


@end
