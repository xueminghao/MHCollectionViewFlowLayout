//
//  MHCollectionViewFlowLayout.m
//  MHCollectionViewFlowLayout
//
//  Created by Minghao Xue on 2019/1/17.
//

#import "MHCollectionViewFlowLayout.h"

@interface MHCollectionViewFlowLayout ()

@property (nonatomic, strong) NSArray<NSArray<UICollectionViewLayoutAttributes *> *> *cache;
@property (nonatomic, assign) CGFloat contentWidth;
@property (nonatomic, assign) CGFloat contentHeight;

@property (nonatomic, weak) id<UICollectionViewDataSource> dataSource;
@property (nonatomic, weak) id<MHCollectionViewFlowLayoutDelegate> layoutDelegate;

@end

@implementation MHCollectionViewFlowLayout

#pragma mark - Life cycles

- (void)prepareLayout {
    [super prepareLayout];
    
    self.contentWidth = CGRectGetWidth(self.collectionView.frame) - self.collectionView.contentInset.left - self.collectionView.contentInset.right;
    
    //set dataSource and delegate
    self.dataSource = self.collectionView.dataSource;
    self.layoutDelegate = nil;
    if ([self.collectionView.delegate conformsToProtocol:@protocol(MHCollectionViewFlowLayoutDelegate)]) {
        self.layoutDelegate = (id<MHCollectionViewFlowLayoutDelegate>)self.collectionView.delegate;
    }
    
    NSMutableArray<NSMutableArray<UICollectionViewLayoutAttributes *> *> *attributes = [NSMutableArray new];
    CGFloat totalHeight = [self prepareLayoutAttributes:attributes];
    self.cache = [attributes copy];
    self.contentHeight = totalHeight;
}

- (void)invalidateLayout {
    [super invalidateLayout];
    
    self.cache = nil;
    self.contentWidth = 0;
    self.contentHeight = 0;
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.contentWidth, self.contentHeight);
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray<UICollectionViewLayoutAttributes *> *temp = [NSMutableArray new];
    for (NSMutableArray<UICollectionViewLayoutAttributes *> *sectionAttributes in self.cache) {
        for (UICollectionViewLayoutAttributes *attributes in sectionAttributes) {
            if (CGRectIntersectsRect(attributes.frame, rect)) {
                [temp addObject:attributes];
            }
        }
    }
    return [temp copy];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.cache[indexPath.section][indexPath.item];
}

#pragma mark - Private methods

- (CGFloat)prepareLayoutAttributes:(NSMutableArray<NSMutableArray<UICollectionViewLayoutAttributes *> *> *)attributes {
    //numberOfSections. defaults to 1
    NSInteger numberOfSections = 1;
    if ([self.dataSource respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
        numberOfSections = [self.dataSource numberOfSectionsInCollectionView:self.collectionView];
    }
    CGFloat totalHeight = 0;
    for (NSInteger section = 0; section < numberOfSections; section++) {
        MHCollectionViewFlowLayoutType layoutType = MHCollectionViewFlowLayoutTypeFlow;
        if ([self.layoutDelegate respondsToSelector:@selector(collectionView:layout:layoutTypeForSectionAtIndex:)]) {
            layoutType = [self.layoutDelegate collectionView:self.collectionView layout:self layoutTypeForSectionAtIndex:section];
        }
        UIEdgeInsets sectionInsets = UIEdgeInsetsZero;
        if ([self.layoutDelegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
            sectionInsets = [self.layoutDelegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
        }
        CGFloat lineSpacing = 0;
        if ([self.layoutDelegate respondsToSelector:@selector(collectionView:layout:lineSpacingForSectionAtIndex:)]) {
            lineSpacing = [self.layoutDelegate collectionView:self.collectionView layout:self lineSpacingForSectionAtIndex:section];
        }
        CGFloat itemSpacing = 0;
        if ([self.layoutDelegate respondsToSelector:@selector(collectionView:layout:interitemSpacingForSectionAtIndex:)]) {
            itemSpacing = [self.layoutDelegate collectionView:self.collectionView layout:self interitemSpacingForSectionAtIndex:section];
        }
        NSMutableArray<UICollectionViewLayoutAttributes *> *sectionAttributes = [NSMutableArray new];
        CGFloat sectionHeight = 0;
        switch (layoutType) {
            case MHCollectionViewFlowLayoutTypeFlow:
            {
                sectionHeight = [self prepareFlowSectionLayout:section
                                         withSectionInsets:sectionInsets
                                        sectionItemSpacing:itemSpacing
                                        sectionLineSpacing:lineSpacing
                                                   yOffset:totalHeight
                                         sectionAttributes:sectionAttributes];
                break;
            }
            case MHCollectionViewFlowLayoutTypeWaterFall:
            {
                sectionHeight = [self prepareWaterFallSectionLayout:section
                                             withSectionInsets:sectionInsets
                                            sectionItemSpacing:itemSpacing
                                            sectionLineSpacing:lineSpacing
                                                       yOffset:totalHeight
                                             sectionAttributes:sectionAttributes];
                break;
            }
        }
        [attributes addObject:[sectionAttributes copy]];
        totalHeight += (sectionHeight + sectionInsets.top + sectionInsets.bottom);
    }
    return totalHeight;
}

- (CGFloat)prepareFlowSectionLayout:(NSInteger)section
           withSectionInsets:(UIEdgeInsets)sectionInsets
          sectionItemSpacing:(CGFloat)itemSpacing
          sectionLineSpacing:(CGFloat)lineSpacing
                     yOffset:(CGFloat)yOffset
           sectionAttributes:(NSMutableArray<UICollectionViewLayoutAttributes *> *)sectionAttributes {
    NSInteger numberOfItems = 0;
    if ([self.dataSource respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
        numberOfItems = [self.dataSource collectionView:self.collectionView numberOfItemsInSection:section];
    }
    NSMutableArray<UICollectionViewLayoutAttributes *> *attrituesOfLastLine = [NSMutableArray new];
    CGFloat y = (yOffset + sectionInsets.top);
    for (NSInteger item = 0; item < numberOfItems; item++) {
        CGSize itemSize = CGSizeZero;
        if ([self.layoutDelegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
            itemSize = [self.layoutDelegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
        }
        CGFloat x = 0;
        UICollectionViewLayoutAttributes *lastAttributes = attrituesOfLastLine.lastObject;
        CGFloat expectedX = 0;
        if (lastAttributes) {
            expectedX = CGRectGetMaxX(lastAttributes.frame) + itemSpacing;
        } else {
            expectedX = sectionInsets.left;
        }
        CGFloat widthLeft = self.contentWidth - expectedX - sectionInsets.right;
        if (widthLeft < itemSize.width) {
            CGFloat maxY = [self maxYOffAttributes:attrituesOfLastLine];
            x = sectionInsets.left;
            y = (maxY + lineSpacing);
            [attrituesOfLastLine removeAllObjects];
        } else {
            x = expectedX;
        }

        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
        attributes.frame = CGRectMake(x, y, itemSize.width, itemSize.height);
        [attrituesOfLastLine addObject:attributes];
        [sectionAttributes addObject:attributes];
    }
    CGFloat maxY = [self maxYOffAttributes:attrituesOfLastLine];
    CGFloat sectionHeight = (maxY - yOffset - sectionInsets.top);
    return sectionHeight;
}

- (CGFloat)prepareWaterFallSectionLayout:(NSInteger)section
                  withSectionInsets:(UIEdgeInsets)sectionInsets
                 sectionItemSpacing:(CGFloat)itemSpacing
                 sectionLineSpacing:(CGFloat)lineSpacing
                            yOffset:(CGFloat)yOffset
                  sectionAttributes:(NSMutableArray<UICollectionViewLayoutAttributes *> *)sectionAttributes {
    NSInteger numberOfItems = 0;
    if ([self.dataSource respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
        numberOfItems = [self.dataSource collectionView:self.collectionView numberOfItemsInSection:section];
    }
    NSMutableArray<UICollectionViewLayoutAttributes *> *attrituesOfLastLine = [NSMutableArray new];
    BOOL firstLineFulled = NO;
    CGFloat y = (yOffset + sectionInsets.top);
    for (NSInteger item = 0; item < numberOfItems; item++) {
        CGSize itemSize = CGSizeZero;
        if ([self.layoutDelegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
            itemSize = [self.layoutDelegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
        }
        CGFloat x = 0;
        if (!firstLineFulled) {
            UICollectionViewLayoutAttributes *lastAttributes = attrituesOfLastLine.lastObject;
            CGFloat expectedX = 0;
            if (lastAttributes) {
                expectedX = CGRectGetMaxX(lastAttributes.frame) + itemSpacing;
            } else {
                expectedX = sectionInsets.left;
            }
            CGFloat widthLeft = self.contentWidth - expectedX - sectionInsets.right;
            if (widthLeft < itemSize.width) {
                x = sectionInsets.left;
                y = (CGRectGetMaxY(attrituesOfLastLine.firstObject.frame) + lineSpacing);
                firstLineFulled = YES;
            } else {
                x = expectedX;
            }
            if (!firstLineFulled) {
                UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
                attributes.frame = CGRectMake(x, y, itemSize.width, itemSize.height);
                [attrituesOfLastLine addObject:attributes];
                [sectionAttributes addObject:attributes];
            }
        }
        if (firstLineFulled) {
            UICollectionViewLayoutAttributes *lowestYAttributes = [self lowestLayoutAttributesByY:attrituesOfLastLine];
            x = CGRectGetMinX(lowestYAttributes.frame);
            y = CGRectGetMaxY(lowestYAttributes.frame) + lineSpacing;
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
            attributes.frame = CGRectMake(x, y, lowestYAttributes.frame.size.width, itemSize.height);
            NSUInteger index = [attrituesOfLastLine indexOfObject:lowestYAttributes];
            if (index != NSNotFound) {
                [attrituesOfLastLine replaceObjectAtIndex:index withObject:attributes];
            }
            [sectionAttributes addObject:attributes];
        }
    }
    CGFloat maxY = [self maxYOffAttributes:attrituesOfLastLine];
    CGFloat sectionHeight = (maxY - yOffset - sectionInsets.top);
    return sectionHeight;
    
}

- (CGFloat)maxYOffAttributes:(NSMutableArray<UICollectionViewLayoutAttributes *> *)attributesArray {
    CGFloat maxY = 0;
    for (UICollectionViewLayoutAttributes *attributes in attributesArray) {
        CGFloat temp = CGRectGetMaxY(attributes.frame);
        if (temp > maxY) {
            maxY = temp;
        }
    }
    return maxY;
}

- (UICollectionViewLayoutAttributes *)lowestLayoutAttributesByY:(NSArray<UICollectionViewLayoutAttributes *> *)attributesArray {
    UICollectionViewLayoutAttributes *temp = attributesArray.firstObject;
    for (UICollectionViewLayoutAttributes *attr in attributesArray) {
        CGFloat maxY = CGRectGetMaxY(temp.frame);
        if (CGRectGetMaxY(attr.frame) < maxY) {
            temp = attr;
        }
    }
    return temp;
}

@end
