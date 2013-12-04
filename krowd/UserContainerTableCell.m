//
//  ContainerTableCell.m
//  krowd
//
//  Created by Julie Caccavo on 9/24/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import "UserContainerTableCell.h"
#import "UserContainerCellView.h"
#import <QuartzCore/QuartzCore.h>

@interface UserContainerTableCell ()

@property (strong, nonatomic) UserContainerCellView *collectionView;

@end

@implementation UserContainerTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _collectionView = [[NSBundle mainBundle] loadNibNamed:@"UserContainerCellView" owner:self options:nil][0];
        _collectionView.frame = self.bounds;
        [self.contentView addSubview:_collectionView];
    }
    return self;
}

- (void)setCollectionData:(NSArray *)collectionData {
    [_collectionView setCollectionData:collectionData];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
