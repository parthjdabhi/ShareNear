//
//  discoverPeopleViewController.m
//  ShareNear
//
//  Created by Ke Luo on 3/27/15.
//  Copyright (c) 2015 KeApp. All rights reserved.
//

#import "DiscoverPeopleViewController.h"
#import "DiscoverPeopleCollectionViewCell.h"

@interface DiscoverPeopleViewController() <UICollectionViewDataSource>
@end

@implementation DiscoverPeopleViewController

#pragma mark - UICollectionViewDatasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return  4;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DiscoverPeopleCollectionViewCell *cell = (DiscoverPeopleCollectionViewCell  *)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.imageView.image = [UIImage imageNamed:@"picture-wallpaper.jpg"];
    
    return cell;
}




@end
