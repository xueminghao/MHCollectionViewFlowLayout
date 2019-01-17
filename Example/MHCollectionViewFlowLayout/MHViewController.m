//
//  MHViewController.m
//  MHCollectionViewFlowLayout
//
//  Created by 薛明浩 on 01/17/2019.
//  Copyright (c) 2019 薛明浩. All rights reserved.
//

#import "MHViewController.h"
#import "MHCollectionViewFlowLayout.h"

@interface MHViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, MHCollectionViewFlowLayoutDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<NSArray *> *dataSource;

@end

@implementation MHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self generateDatas];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
}

#pragma mark - Private methods

- (void)generateDatas {
    NSMutableArray *array = [NSMutableArray new];
    for (NSInteger i = 0; i < 2; i++) {
        NSMutableArray *subArray = [NSMutableArray new];
        for (NSInteger j = 0; j<10; j++) {
            CGFloat randomWidth = [self randomLength];
            CGFloat randomHeight = [self randomLength];
            CGSize size = CGSizeMake(randomWidth, randomHeight);
            [subArray addObject:[NSValue valueWithCGSize:size]];
        }
        [array addObject:[subArray copy]];
    }
    self.dataSource = [array copy];
}

- (CGFloat)randomLength {
    return arc4random_uniform(100) + 50;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataSource.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource[section].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor orangeColor];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - MHCollectionViewFlowLayoutDelegate

- (MHCollectionViewFlowLayoutType)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout layoutTypeForSectionAtIndex:(NSInteger)section {
    if (section == 0) {
        return MHCollectionViewFlowLayoutTypeFlow;
    }
    return MHCollectionViewFlowLayoutTypeWaterFall;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(8, 8, 8, 8);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout interitemSpacingForSectionAtIndex:(NSInteger)section {
    return 8;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout lineSpacingForSectionAtIndex:(NSInteger)section {
    return 8;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSValue *value = self.dataSource[indexPath.section][indexPath.row];
    return [value CGSizeValue];
}

@end
