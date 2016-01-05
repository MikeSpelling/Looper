//
//  DMHomeViewController.m
//  Looper
//
//  Created by Michael Spelling on 05/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMHomeViewController.h"
#import "DMSavedLoopCell.h"
#import "DMSavedLoopHeader.h"

@interface DMHomeViewController() <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) NSArray *savedLoops;

@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet UIView *titleView;
@end


@implementation DMHomeViewController

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _savedLoops = [NSArray new];
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerCells];
    [self fixEdgeInsets];
}


#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.savedLoops.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DMSavedLoopCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:DMSavedLoopCellKey forIndexPath:indexPath];
    return cell;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        __weak typeof (self)weakSelf = self;
        DMSavedLoopHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:DMSavedLoopHeaderKey forIndexPath:indexPath];
        [header setTapHandler:^{
            [weakSelf goToLooper];
        }];
        return header;
    }
    return nil;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout  *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self cellSize];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return [self cellSize];
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 8;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 8;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}


#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tap");
}


#pragma mark - Internal

-(void)registerCells
{
    UINib *cellNib = [UINib nibWithNibName:DMSavedLoopCellKey bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:DMSavedLoopCellKey];
    
    UINib *headerNib = [UINib nibWithNibName:DMSavedLoopHeaderKey bundle:nil];
    [self.collectionView registerNib:headerNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:DMSavedLoopHeaderKey];
}

-(CGSize)cellSize
{
    return CGSizeMake(self.collectionView.bounds.size.width, self.collectionView.bounds.size.height/6.0);
}

-(void)fixEdgeInsets
{
    UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
    edgeInsets.top = self.titleView.bounds.size.height;
    self.collectionView.contentInset = edgeInsets;
    self.collectionView.scrollIndicatorInsets = edgeInsets;
}

-(void)goToLooper
{
    [self performSegueWithIdentifier:@"DMPresentLoopViewController" sender:self];
}

@end
