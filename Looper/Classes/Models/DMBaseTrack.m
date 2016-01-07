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

-(instancetype)initWithDelegate:(id<DMBaseTrackDelegate>)delegate
{
    if (self = [super initWithOffset:0]) {
        _delegate = delegate;
    }
    return self;
}


#pragma mark - Overrides

-(void)play
{
    [super play];
    [self startTimer];
}

-(void)pausePlayback
{
    [super pausePlayback];
    [self stopTimer];
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

-(AVAudioPlayer*)player
{
    if (!_player) {
        _player = [super player];
        _player.numberOfLoops = -1;
    }
    return _player;
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
    [self.delegate baseTrackUpdatePosition:self.player.currentTime];
    
    CGFloat currentPosition = self.player.currentTime;
    if (currentPosition < self.lastKnownPosition) {
        [self.delegate baseTrackDidLoop];
    }
    self.lastKnownPosition = currentPosition;
}

@end