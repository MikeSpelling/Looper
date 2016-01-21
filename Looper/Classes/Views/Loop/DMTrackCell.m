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
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leftTrackLeadingConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leftTrackWidthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *rightTrackWidthConstraint;
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

-(void)updateProgressViewsForTime:(NSTimeInterval)time
{
    [self layoutIfNeeded];
    CGFloat width = self.progressView.bounds.size.width;
    CGFloat position = (time / self.baseDuration) * width;
    
    if (self.track.isBaseTrack)
    {
        if (self.baseDuration)
        {
            // Base track recorded
            self.leftTrackLeadingConstraint.constant = 0;
            self.leftTrackWidthConstraint.constant = width;
            self.leftProgressWidthConstraint.constant = position;
            self.rightTrackWidthConstraint.constant = 0;
            self.rightProgressWidthConstraint.constant = 0;
        }
        else
        {
            // Base track while recording
            self.leftTrackLeadingConstraint.constant = 0;
            self.leftTrackWidthConstraint.constant = width;
            self.leftProgressWidthConstraint.constant = 0;
            self.rightTrackWidthConstraint.constant = 0;
            self.rightProgressWidthConstraint.constant = 0;
        }
    }
    else
    {
        // Get bounded time within track
        CGFloat timeWithinTrack = time - self.track.offset;
        if (timeWithinTrack<0) timeWithinTrack = self.baseDuration - self.track.offset + time;
        if (timeWithinTrack>self.track.duration) timeWithinTrack = self.track.duration;
        
        if (self.track.duration)
        {
            if (self.track.offset + self.track.duration >= self.baseDuration)
            {
                // Recorded Split track
                CGFloat trackWidth = (self.track.duration / self.baseDuration) * width;
                CGFloat rightTrackWidth = width - ((self.track.offset / self.baseDuration) * width);
                self.rightTrackWidthConstraint.constant = rightTrackWidth;
                CGFloat rightProgressWidth = (timeWithinTrack / self.track.duration) * trackWidth;
                self.rightProgressWidthConstraint.constant = rightProgressWidth > rightTrackWidth ? rightTrackWidth : rightProgressWidth;

                self.leftTrackLeadingConstraint.constant = 0;
                self.leftTrackWidthConstraint.constant = trackWidth - rightTrackWidth;
                self.leftProgressWidthConstraint.constant = rightProgressWidth >= rightTrackWidth ? rightProgressWidth-rightTrackWidth : 0;
            }
            else
            {
                // Recorded Confined track
                self.leftTrackLeadingConstraint.constant = (self.track.offset / self.baseDuration) * width;
                CGFloat trackWidth = (self.track.duration / self.baseDuration) * width;
                self.leftTrackWidthConstraint.constant = trackWidth;
                self.leftProgressWidthConstraint.constant = (timeWithinTrack / self.track.duration) * trackWidth;
                self.rightTrackWidthConstraint.constant = 0;
                self.rightProgressWidthConstraint.constant = 0;
            }
        }
        else
        {
            self.leftTrackLeadingConstraint.constant = 0;
            self.leftTrackWidthConstraint.constant = 0;
            self.leftProgressWidthConstraint.constant = 0;
            self.rightTrackWidthConstraint.constant = 0;
            self.rightProgressWidthConstraint.constant = 0;
        }
    }
    
    [self layoutIfNeeded];
}

@end
