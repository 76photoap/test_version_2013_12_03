//
//  ContainerTableCell.m
//  krowd
//
//  Created by Julie Caccavo on 9/24/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import "ArchiveContainerTableCell.h"
#import "ArchiveContainerCellView.h"

@interface ArchiveContainerTableCell ()

@property (strong, nonatomic) ArchiveContainerCellView *collectionView;

@end

@implementation ArchiveContainerTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _collectionView = [[NSBundle mainBundle] loadNibNamed:@"ArchiveContainerCellView" owner:self options:nil][0];
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
