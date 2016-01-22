//
//  DMTrackCell.m
//  Looper
//
//  Created by Michael Spelling on 07/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMTrackCell.h"

NSString *const DMTrackCellKey = @"DMTrackCell";

@interface DMTrackCell()
@property (nonatomic, strong) DMTrack *track;
@property (nonatomic, assign) NSTimeInterval baseDuration;
@property (nonatomic, copy) void (^deleteTappedBlock)();

@property (nonatomic, weak) IBOutlet UIButton *deleteButton;
@property (nonatomic, weak) IBOutlet UIView *progressView;
@property (nonatomic, weak) IBOutlet UIView *leftTrack;
@property (nonatomic, weak) IBOutlet UIView *rightTrack;
@property (nonatomic, weak) IBOutlet UIView *leftProgress;
@property (nonatomic, weak) IBOutlet UIView *rightProgress;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leftTrackWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *rightTrackWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *rightTrackTrailingConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leftProgressWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *rightProgressWidthConstraint;

-(IBAction)deleteTapped;
@end


@implementation DMTrackCell

-(void)updateForTrack:(DMTrack*)track
          currentTime:(NSTimeInterval)currentTime
         baseDuration:(NSTimeInterval)baseDuration
          deleteBlock:(void (^)())deleteBlock
{
    self.track = track;
    self.baseDuration = baseDuration;
    self.deleteTappedBlock = deleteBlock;
    self.deleteButton.alpha = track.isBaseTrack ? 0 : 1;
    
    [self setColorsForTrack];
    [self setupTrackViews];
    [self updateProgressViewsForTime:currentTime];
}

-(void)updateForTime:(NSTimeInterval)time
{
    [self updateProgressViewsForTime:time];
}


#pragma mark - Actions

-(IBAction)deleteTapped
{
    if (self.deleteTappedBlock) {
        self.deleteTappedBlock();
    }
}


#pragma mark - Internal

-(void)setColorsForTrack
{
    UIColor *trackColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
    UIColor *progressColor = [UIColor colorWithRed:0.5 green:0 blue:0.5 alpha:1];
    if (self.track.isMuted) {
        trackColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
        progressColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
    }
    self.leftTrack.backgroundColor = trackColor;
    self.rightTrack.backgroundColor = trackColor;
    self.leftProgress.backgroundColor = progressColor;
    self.rightProgress.backgroundColor = progressColor;
}

-(void)setupTrackViews
{
    [self layoutIfNeeded];
    
    CGFloat width = self.progressView.bounds.size.width;
    CGFloat timeToWidthMult = width / self.baseDuration;
    
    if (self.track.isBaseTrack)
    {
        self.leftTrackWidthConstraint.constant = 0;
        self.rightTrackWidthConstraint.constant = width;
        self.rightTrackTrailingConstraint.constant = 0;
    }
    else if (self.baseDuration)
    {
        if (self.track.duration)
        {
            if (self.track.offset + self.track.duration >= self.baseDuration)
            {
                // Recorded Split track
                CGFloat trackWidth = self.track.duration * timeToWidthMult;
                CGFloat rightTrackWidth = width - (self.track.offset  * timeToWidthMult);
                self.rightTrackWidthConstraint.constant = rightTrackWidth;
                self.rightTrackTrailingConstraint.constant = 0;
                
                self.leftTrackWidthConstraint.constant = trackWidth - rightTrackWidth;
            }
            else
            {
                // Recorded Confined track
                self.rightTrackTrailingConstraint.constant = (self.baseDuration - self.track.offset - self.track.duration) * timeToWidthMult;
                self.rightTrackWidthConstraint.constant = self.track.duration * timeToWidthMult;
                self.leftTrackWidthConstraint.constant = 0;
            }
        }
        else
        {
            // Unrecorded track
            self.leftTrackWidthConstraint.constant = 0;
            self.rightTrackWidthConstraint.constant = 0;
            self.rightTrackTrailingConstraint.constant = 0;
        }
    }
    
    [self layoutIfNeeded];
}

-(void)updateProgressViewsForTime:(NSTimeInterval)time
{
    CGFloat width = self.progressView.bounds.size.width;
    CGFloat timeToWidthMult = width / self.baseDuration;
    
    if (self.track.isBaseTrack)
    {
        if (self.baseDuration)
        {
            // Base track recorded
            self.leftProgressWidthConstraint.constant = 0;
            self.rightProgressWidthConstraint.constant = time * timeToWidthMult;
        }
        else
        {
            // Base track while recording
            self.leftProgressWidthConstraint.constant = 0;
            self.rightProgressWidthConstraint.constant = width;
        }
    }
    else if (self.baseDuration)
    {
        if (self.track.duration)
        {
            BOOL trackWrapped = self.track.offset + self.track.duration >= self.baseDuration;
            
            if (trackWrapped)
            {
                NSTimeInterval wrappedEndTime = fabs(self.baseDuration - (self.track.offset + self.track.duration));
                if (time >= self.track.offset) {
                    self.rightProgressWidthConstraint.constant = (time - self.track.offset) * timeToWidthMult;
                    self.leftProgressWidthConstraint.constant = wrappedEndTime * timeToWidthMult;
                }
                else {
                    self.rightProgressWidthConstraint.constant = 0;
                    CGFloat boundedTime = time > wrappedEndTime ? wrappedEndTime : time;
                    self.leftProgressWidthConstraint.constant = boundedTime  * timeToWidthMult;
                }
            }
            else
            {
                self.leftProgressWidthConstraint.constant = 0;
                CGFloat boundedTime = time - self.track.offset;
                if (boundedTime < 0) boundedTime = 0;
                else if (boundedTime > self.track.duration) boundedTime = self.track.duration;
                self.rightProgressWidthConstraint.constant = boundedTime * timeToWidthMult;
            }
        }
        else
        {
            // Recording
            self.leftProgressWidthConstraint.constant = 0;
            self.rightProgressWidthConstraint.constant = 0;
        }
    }
    
    [self layoutIfNeeded];
}

@end
