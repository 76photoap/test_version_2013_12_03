//
//  SearchCell.m
//  krowd
//
//  Created by Julie Caccavo on 8/25/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import "SearchCell.h"

@interface SearchCell ()
{
    
}
@end

@implementation SearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib{
    self.oNameLabel.font = [UIFont fontWithName:@"CenturyGothic" size:17.0];
    self.oUsernameLabel.font = [UIFont fontWithName:@"CenturyGothic" size:13.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
