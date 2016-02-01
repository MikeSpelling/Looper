//
//  DMTracksViewController.m
//  Looper
//
//  Created by Michael Spelling on 05/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMTracksViewController.h"
#import "DMLooperService.h"
#import "UIViewController+DMHelpers.h"
#import "DMTrackCell.h"

@interface DMTracksViewController () <DMLooperDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) DMLooperService *looperService;
@property (nonatomic, strong) DMLooper *looper;
@property (nonatomic, strong) NSArray *tracks;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UIButton *pauseButton;
@property (nonatomic, weak) IBOutlet UIButton *stopButton;
@property (nonatomic, weak) IBOutlet UIButton *finishRecordingButton;
@property (nonatomic, weak) IBOutlet UIButton *startRecordingButton;
@property (nonatomic, weak) IBOutlet UIButton *nextRecordingButton;
@end


@implementation DMTracksViewController

-(instancetype)initWithLooper:(DMLooper*)looper
{
    if (self = [super initWithNibName:@"DMTracksView" bundle:nil]) {
        _looperService = [DMLooperService sharedInstance];
        _looper = looper;
        _looper.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerCells];
    
    self.playButton.alpha = self.looper ? 1 : 0;
    self.pauseButton.alpha = 0;
    self.stopButton.alpha = 0;
    self.startRecordingButton.alpha = 1;
    self.finishRecordingButton.alpha = 0;
    self.nextRecordingButton.alpha = 0;
    
    [self startTimer];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tracks = self.looper.allTracks;
    [self.collectionView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.looper tearDown];
}


#pragma mark - DMTracksViewController

-(void)saveLooperWithTitle:(NSString*)title
{
    NSString *originalTitle = self.looper.title;
    self.looper.title = title;
    
    DMLooper *savedLooper = [self.looperService looperWithTitle:title];
    if (savedLooper && ![savedLooper isEqualToLooper:self.looper]) {
        __weak typeof (self)weakSelf = self;
        [self dm_presentAlertWithTitle:[NSString stringWithFormat:@"Overwriting %@", title]
                               message:@"Are you sure you want to continue?"
                           cancelTitle:@"No"
                           cancelBlock:^{
                               weakSelf.looper.title = originalTitle;
                           }
                            otherTitle:@"Yes"
                            otherBlock:^{
                                [weakSelf.looperService saveLooper:weakSelf.looper];
                            }
                            otherStyle:UIAlertActionStyleDefault];
    }
    else {
        [self.looperService saveLooper:self.looper];
    }
}

-(BOOL)hasUnsavedChanges
{
    DMLooper *savedLooper = [self.looperService looperWithTitle:self.looper.title];
    if (savedLooper) {
        return ![savedLooper isEqualToLooper:self.looper];
    }
    return [self.looper recordedTracks].count>0;
}


#pragma mark - Actions

-(IBAction)playTapped
{
    [self.looper play];
    
    self.playButton.alpha = 0;
    self.pauseButton.alpha = 1;
    self.stopButton.alpha = 1;
}

-(IBAction)stopTapped
{
    [self.looper stopPlayback];
    
    self.playButton.alpha = 1;
    self.pauseButton.alpha = 0;
    self.stopButton.alpha = 0;
}

-(IBAction)finishRecordingTapped
{
    [self.looper stopRecording];
    
    self.playButton.alpha = 0;
    self.pauseButton.alpha = 1;
    self.stopButton.alpha = 1;
    
    self.startRecordingButton.alpha = 1;
    self.finishRecordingButton.alpha = 0;
    self.nextRecordingButton.alpha = 0;
}

-(IBAction)startRecordingTapped
{
    [self.looper startRecording];
    
    self.startRecordingButton.alpha = 0;
    self.finishRecordingButton.alpha = 1;
    self.nextRecordingButton.alpha = 1;
}

-(IBAction)nextRecordingTapped
{
    [self.looper stopRecording];
    [self.looper startRecording];
    
    self.playButton.alpha = 1;
    self.pauseButton.alpha = 0;
    self.stopButton.alpha = 0;
    
    self.startRecordingButton.alpha = 0;
    self.finishRecordingButton.alpha = 1;
    self.nextRecordingButton.alpha = 1;
}


#pragma mark - DMLooperDelegate

-(void)looperTracksChanged
{
    self.tracks = self.looper.allTracks;
    [self.collectionView reloadData];
}


#pragma mark - UICollectionViewDataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.tracks.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DMTrackCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:DMTrackCellKey forIndexPath:indexPath];
    
    __weak typeof (DMTrack*) track = self.tracks[indexPath.item];
    __weak typeof (self)weakSelf = self;
    [cell updateForTrack:track currentTime:self.looper.baseTrack.currentTime deleteBlock:^{
        NSUInteger trackIndex = [[weakSelf.looper allTracks] indexOfObject:track];
        [weakSelf.looper deleteTrack:track];
        weakSelf.tracks = weakSelf.looper.allTracks;
        [weakSelf.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:trackIndex inSection:0]]];
    }];
    return cell;
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
    DMTrack *track = self.tracks[indexPath.item];
    [self.looper muteTrack:track muted:!track.isMuted];
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
}


#pragma mark - Timer

-(void)startTimer
{
    self.timer = [NSTimer timerWithTimeInterval:0.02 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes]; // So collection view scrolling doesnt interfere
}

-(void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

-(void)timerFired
{
    [self updateVisibleCellsForTime];
}


#pragma mark - Internal

-(void)registerCells
{
    UINib *cellNib = [UINib nibWithNibName:DMTrackCellKey bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:DMTrackCellKey];
}

-(CGSize)cellSize
{
    return CGSizeMake(self.collectionView.bounds.size.width, self.collectionView.bounds.size.height/6.0);
}

-(void)updateVisibleCellsForTime
{
    for (DMTrackCell *cell in [self.collectionView visibleCells]) {
        [cell updateForTime:self.looper.baseTrack.currentTime];
    }
}

@end
