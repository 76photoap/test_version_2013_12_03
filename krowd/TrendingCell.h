//
//  TrendingCell.h
//  krowd
//
//  Created by Julie Caccavo on 8/23/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrendingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *oImageView;
@property (weak, nonatomic) IBOutlet UILabel *oNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *oLikes;
@property (weak, nonatomic) IBOutlet UIImageView *oStarView;
@property (weak, nonatomic) IBOutlet UILabel *oRankingLabel;

- (void)createCustomLikesLabel:(NSInteger)numberOfLikes;

@end
