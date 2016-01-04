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

@property (nonatomic, assign) NSUInteger currentPlaybackPosition;
@property (nonatomic, assign) NSUInteger currentChannelOffset;
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
    
    DMChannel *channel = [[DMChannel alloc] initWithDelegate:self index:self.channels.count offset:self.currentPlaybackPosition];
    [channel record];
    self.recordingChannel = channel;
    [self.channels addObject:channel];
}

-(void)stopRecordingLoopAndPlay
{
    [self.recordingChannel stopRecording];
    [self.recordingChannel play];
    self.recordingChannel = nil;
}

-(void)stopAllPlayback
{
    for (DMChannel *channel in self.channels) {
        [channel stopPlayback];
    }
    [self.audioSession setActive:NO error:nil];
}

-(BOOL)isRecording
{
    return self.recordingChannel != nil;
}

@end
