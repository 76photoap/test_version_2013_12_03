//
//  TrendingCell.m
//  krowd
//
//  Created by Julie Caccavo on 8/23/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import "TrendingCell.h"

@implementation TrendingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib{
    self.contentView.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230./255.0 blue:230./255.0 alpha:1.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)createCustomLikesLabel:(NSInteger)numberOfLikes{
    
    self.oLikes.frame = CGRectMake(273, 23, 45, 18);
    self.oLikes.textColor = [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
    
    if (numberOfLikes>999 && numberOfLikes<999999) {
        self.oLikes.text = [NSString stringWithFormat:@"%.2fk",(float)numberOfLikes/1000];
        self.oLikes.font = [UIFont fontWithName:@"CenturyGothic" size:16.0];
    }
    else if (numberOfLikes>99 && numberOfLikes<999){
        self.oLikes.text = [NSString stringWithFormat:@"%i",numberOfLikes];
        self.oLikes.font = [UIFont fontWithName:@"CenturyGothic" size:18.0];
    }
    else{
        self.oLikes.text = [NSString stringWithFormat:@"%i",numberOfLikes];
        self.oLikes.font = [UIFont fontWithName:@"CenturyGothic" size:20.0];
    }
    self.oLikes.textAlignment = NSTextAlignmentCenter;
    self.oLikes.backgroundColor = [UIColor clearColor];
    [self addSubview:self.oLikes];
}

@end
