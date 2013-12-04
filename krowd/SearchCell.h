//
//  SearchCell.h
//  krowd
//
//  Created by Julie Caccavo on 8/25/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchCell : UITableViewCell <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UILabel *oNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *oImageView;
@property (weak, nonatomic) IBOutlet UILabel *oUsernameLabel;

@end
