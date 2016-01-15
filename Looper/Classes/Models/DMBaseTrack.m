//
//  DMBaseTrack.m
//  Looper
//
//  Created by Michael Spelling on 06/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMBaseTrack.h"

@interface DMBaseTrack()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGFloat lastKnownPosition;
@end


@implementation DMBaseTrack

@synthesize player = _player;

-(instancetype)initWithBaseTrackDelegate:(id<DMBaseTrackDelegate>)baseTrackDelegate
{
//    if (self = [super initWithOffset:0]) {
        _baseTrackDelegate = baseTrackDelegate;
//    }
    return self;
}


#pragma mark - Overrides

-(void)play
{
    if (!self.player) {
        [self createPlayer];
    }
    NSLog(@"%@ play %@", self.player, self);
    [self.player play];
    
    [self startTimer];
}

-(void)stopPlayback
{
    [super stopPlayback];
    [self stopTimer];
}

-(BOOL)isBaseTrack
{
    return YES;
}


#pragma mark - Internal

-(void)createPlayer
{
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.url error:nil];
    _player.numberOfLoops = -1;
    _player.volume = 1;
}


#pragma mark - Timer

-(void)startTimer
{
    if (self.timer) {
        [self stopTimer];
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
}

-(void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

-(void)timerFired
{
    [self.baseTrackDelegate baseTrackUpdatePosition:self.player.currentTime];
    
    CGFloat currentPosition = self.player.currentTime;
    if (currentPosition < self.lastKnownPosition) {
        [self.baseTrackDelegate baseTrackDidLoop];
    }
    self.lastKnownPosition = currentPosition;
}

@end
