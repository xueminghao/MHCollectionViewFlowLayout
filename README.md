# MHCollectionViewFlowLayout

[![CI Status](https://img.shields.io/travis/薛明浩/MHCollectionViewFlowLayout.svg?style=flat)](https://travis-ci.org/薛明浩/MHCollectionViewFlowLayout)
[![Version](https://img.shields.io/cocoapods/v/MHCollectionViewFlowLayout.svg?style=flat)](https://cocoapods.org/pods/MHCollectionViewFlowLayout)
[![License](https://img.shields.io/cocoapods/l/MHCollectionViewFlowLayout.svg?style=flat)](https://cocoapods.org/pods/MHCollectionViewFlowLayout)
[![Platform](https://img.shields.io/cocoapods/p/MHCollectionViewFlowLayout.svg?style=flat)](https://cocoapods.org/pods/MHCollectionViewFlowLayout)
## Feature

1. Set different layout for each section.
```
- (MHCollectionViewFlowLayoutType)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout layoutTypeForSectionAtIndex:(NSInteger)section;
```
2. Current suport flow and water fall layout method.
```
typedef NS_ENUM(NSUInteger, MHCollectionViewFlowLayoutType) {
    MHCollectionViewFlowLayoutTypeFlow,
    MHCollectionViewFlowLayoutTypeWaterFall,
};
```
3. Respect the exact line and interitem spacing you set versus the UIKit default behavior.
```
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout lineSpacingForSectionAtIndex:(NSInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout interitemSpacingForSectionAtIndex:(NSInteger)section;
```
## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

MHCollectionViewFlowLayout is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MHCollectionViewFlowLayout', :git => 'git@github.com:Minghao2017/MHCollectionViewFlowLayout.git'
```

## Author

薛明浩, xue_minghao@qq.com

## License

MHCollectionViewFlowLayout is available under the MIT license. See the LICENSE file for more info.
