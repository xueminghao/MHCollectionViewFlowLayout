//
//  MHCollectionViewFlowLayout.h
//  MHCollectionViewFlowLayout
//
//  Created by Minghao Xue on 2019/1/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MHCollectionViewFlowLayoutType) {
    MHCollectionViewFlowLayoutTypeFlow,
    MHCollectionViewFlowLayoutTypeWaterFall,
};

@protocol MHCollectionViewFlowLayoutDelegate <UICollectionViewDelegate>
@optional
- (MHCollectionViewFlowLayoutType)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout layoutTypeForSectionAtIndex:(NSInteger)section;
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout lineSpacingForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout interitemSpacingForSectionAtIndex:(NSInteger)section;
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface MHCollectionViewFlowLayout : UICollectionViewLayout

@end

NS_ASSUME_NONNULL_END
