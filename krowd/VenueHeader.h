//
//  VenueHeader.h
//  krowd
//
//  Created by Julie Caccavo on 8/26/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VenueHeader : UIView

@property (weak, nonatomic) IBOutlet UIImageView *oVenuePictureView;
@property (weak, nonatomic) IBOutlet UILabel *oAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *oCategoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *oPhoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *oNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *oFollowersLabel;
@property (weak, nonatomic) IBOutlet UILabel *oNumberLikes;
@property (weak, nonatomic) IBOutlet UIView *oBackgroundView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;


@end
