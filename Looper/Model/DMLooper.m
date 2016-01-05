//
//  DMLooper.m
//  Looper
//
//  Created by Michael Spelling on 04/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMLooper.h"
#import "DMChannel.h"
#import <AVFoundation/AVFoundation.h>

@interface DMLooper() <DMChannelDelegate>
@property (nonatomic, strong) NSMutableArray *channels;
@property (nonatomic, strong) DMChannel *recordingChannel;
@property (nonatomic, strong) AVAudioSession *audioSession;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGFloat lastKnownPosition;
@end

@implementation DMLooper

-(instancetype)init
{
    if (self = [super init]) {
        _channels = [NSMutableArray new];
        
        _audioSession = [AVAudioSession sharedInstance];
        [_audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    return self;
}

-(void)recordNewLoop
{
    [self.audioSession setActive:YES error:nil];
    
    DMChannel *channel = [[DMChannel alloc] initWithDelegate:self index:self.channels.count offset:self.lastKnownPosition];
    [channel record];
    self.recordingChannel = channel;
    
    [self.channels addObject:channel];
}

-(void)stopRecordingLoop
{
    [self.recordingChannel stopRecording];
    
    if (self.recordingChannel.index == 0) {
        [self.recordingChannel play];
        [self startLoopTimer];
    }
    
    self.recordingChannel = nil;
}

-(void)stopAllPlayback
{
    for (DMChannel *channel in self.channels) {
        [channel stopPlayback];
    }
    
    [self.audioSession setActive:NO error:nil];
    [self stopTimer];
}

-(BOOL)isRecording
{
    return self.recordingChannel != nil;
}


#pragma mark - Internal

-(DMChannel*)baseChannel
{
    return [self.channels firstObject];
}

-(void)startLoopTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
}

-(void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

-(void)timerFired
{
    CGFloat currentPosition = [self baseChannel].currentTime;
    BOOL looped = currentPosition < self.lastKnownPosition;
    if (looped) {
        NSLog(@"Loop");
    }
    self.lastKnownPosition = currentPosition;
    
    for (NSUInteger i=1; i<self.channels.count; i++) {
        DMChannel *channel = self.channels[i];
        [channel playIfNeededAtOffset:currentPosition looped:looped];
    }
}

@end
