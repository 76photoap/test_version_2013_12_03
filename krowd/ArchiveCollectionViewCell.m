//
//  PhotoCollectionViewCell.m
//  krowd
//
//  Created by Julie Caccavo on 9/24/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import "ArchiveCollectionViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation ArchiveCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.layer.borderColor = [[UIColor colorWithRed:180.0/255.0 green:180.0/255.0 blue:180.0/255.0 alpha:1.0] CGColor];
    self.layer.borderWidth = 1.0;
}


@end
