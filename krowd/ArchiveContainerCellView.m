//
//  ContainerCellView.m
//  krowd
//
//  Created by Julie Caccavo on 9/24/13.
//  Copyright (c) 2013 Juliana Caccavo. All rights reserved.
//

#import "ArchiveContainerCellView.h"
#import "ArchiveCollectionViewCell.h"

@interface ArchiveContainerCellView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *collectionData;

@end

@implementation ArchiveContainerCellView 

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    self.collectionView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:238.0/255.0 blue:239.0/255.0 alpha:1.0];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemSize = CGSizeMake(130.0, 155.0);
    [flowLayout setSectionInset:UIEdgeInsetsMake(0, 5, 0, 0)];
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    // Register the colleciton cell
    [_collectionView registerNib:[UINib nibWithNibName:@"ArchiveCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"ArchiveCollectionViewCell"];
}

- (void)setCollectionData:(NSArray *)collectionData {
    _collectionData = collectionData;
    [_collectionView setContentOffset:CGPointZero animated:NO];
    [_collectionView reloadData];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
   return self.collectionData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *cellData = [self.collectionData objectAtIndex:[indexPath row]];
    
    ArchiveCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ArchiveCollectionViewCell" forIndexPath:indexPath];
    cell.photoTitle.font = [UIFont fontWithName:@"CenturyGothic" size:18.0];
    //cell.photoTitle.textColor = [UIColor colorWithRed:27.0/255.0 green:160.0/255.0 blue:206.0/255.0 alpha:1.0];
    cell.photoTitle.textColor = [UIColor colorWithRed:70/255.0 green:70/255.0 blue:70/255.0 alpha:1.0];
    cell.photoTitle.text = [cellData objectForKey:@"title"];
    if (cellData[@"image"] && [cellData[@"imageLoaded"] boolValue]) {
        ((ArchiveCollectionViewCell *)cell).imageView.image = [cellData objectForKey:@"image"];
    }
    else{
        ((ArchiveCollectionViewCell *)cell).imageView.image = nil;
        
    }

    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *cellData = [self.collectionData objectAtIndex:[indexPath row]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectItemFromCollectionView" object:cellData];
}


@end
