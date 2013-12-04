//
//  VenueHeader.m
//  krowd
//
//  Created by Julie Caccavo on 8/26/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import "VenueHeader.h"

@interface VenueHeader ()
{
    
    __weak IBOutlet UILabel *followersTitle;
    __weak IBOutlet UILabel *phoneTitle;
    __weak IBOutlet UILabel *categoryTitle;
    __weak IBOutlet UILabel *addressTitle;
}
- (IBAction)segmentedControlPressed:(id)sender;

@end

@implementation VenueHeader

@synthesize oNameLabel;
@synthesize oCategoryLabel;
@synthesize oPhoneLabel;
@synthesize oAddressLabel;
@synthesize oVenuePictureView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib{
    self.oAddressLabel.font = [UIFont fontWithName:@"CenturyGothic" size:13.0];
    self.oCategoryLabel.font = [UIFont fontWithName:@"CenturyGothic" size:13.0];
    self.oNameLabel.font = [UIFont fontWithName:@"CenturyGothic" size:21.0];
    self.oNumberLikes.font = [UIFont fontWithName:@"CenturyGothic" size:30.0];
    self.oPhoneLabel.font = [UIFont fontWithName:@"CenturyGothic" size:13.0];
    self.oFollowersLabel.font = [UIFont fontWithName:@"CenturyGothic-Bold" size:21.0];
    followersTitle.font = [UIFont fontWithName:@"CenturyGothic" size:12.0];
    phoneTitle.font = [UIFont fontWithName:@"CenturyGothic" size:13.0];
    categoryTitle.font = [UIFont fontWithName:@"CenturyGothic" size:13.0];
    addressTitle.font = [UIFont fontWithName:@"CenturyGothic" size:13.0];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)segmentedControlPressed:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeFeedNotification" object:self];

}
@end
