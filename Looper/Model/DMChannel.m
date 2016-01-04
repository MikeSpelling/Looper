//
//  DMChannel.m
//  Looper
//
//  Created by Michael Spelling on 04/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMChannel.h"
#import <AVFoundation/AVFoundation.h>

@interface DMChannel() <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
@property (nonatomic, strong) id<DMChannelDelegate> delegate;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@end

@implementation DMChannel

-(instancetype)initWithDelegate:(id<DMChannelDelegate>)delegate index:(NSUInteger)index offset:(NSUInteger)offset
{
    if (self = [super init]) {
        _delegate = delegate;
        _index = index;
        _offset = offset;
        
        NSString *baseFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSArray *pathComponents = @[baseFilePath, [NSString stringWithFormat:@"%lu.m4a", (unsigned long)index]];
        _url = [NSURL fileURLWithPathComponents:pathComponents];
        
        // Setup defaults
        _sampleRate = 44100;
        _numberOfChannels = 2; // Stereo
        _bitDepth = 16;
    }
    return self;
}

-(void)record
{
    [self.recorder record];
}

-(void)stopRecording
{
    [self.recorder stop];
}

-(void)play
{
    [self.player play];
}

-(void)stopPlayback
{
    [self.player stop];
}


#pragma mark - AVAudioRecorderDelegate

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag
{
    if ([self.delegate respondsToSelector:@selector(channel:recordFinishedSuccessfully:)]) {
        [self.delegate channel:self recordFinishedSuccessfully:flag];
    }
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error;
{
    if ([self.delegate respondsToSelector:@selector(channel:recordErrorDidOrrur:)]) {
        [self.delegate channel:self recordErrorDidOrrur:error];
    }
}


#pragma mark - AVAudioPlayerDelegate

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if ([self.delegate respondsToSelector:@selector(channel:playbackFinishedSuccessfully:)]) {
        [self.delegate channel:self playbackFinishedSuccessfully:flag];
    }
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(channel:playbackErrorDidOrrur:)]) {
        [self.delegate channel:self playbackErrorDidOrrur:error];
    }
}


#pragma mark - Overrides

-(NSUInteger)duration
{
    return self.player.duration;
}

-(BOOL)isRecording
{
    return self.recorder.recording;
}

-(BOOL)isPlaying
{
    return self.player.playing;
}

-(void)setSampleRate:(NSUInteger)sampleRate
{
    _sampleRate = sampleRate;
    _recorder = nil;
}

-(void)setNumberOfChannels:(NSUInteger)numberOfChannels
{
    _numberOfChannels = numberOfChannels;
    _recorder = nil;
}

-(void)setBitDepth:(NSUInteger)bitDepth
{
    _bitDepth = bitDepth;
    _recorder = nil;
}


#pragma mark - Internal

-(AVAudioPlayer*)player
{
    if (!_player) {
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.url error:nil];
        _player.delegate = self;
        _player.numberOfLoops = self.index == 0 ? -1 : 0;
        [_player prepareToPlay];
    }
    return _player;
}

-(AVAudioRecorder*)recorder
{
    if (!_recorder) {
        NSDictionary *settings = @{
                                   AVFormatIDKey          : @(kAudioFormatMPEG4AAC),
                                   AVSampleRateKey        : @(self.sampleRate),
                                   AVNumberOfChannelsKey  : @(self.numberOfChannels),
                                   AVLinearPCMBitDepthKey : @(self.bitDepth)
                                   };
        
        _recorder = [[AVAudioRecorder alloc] initWithURL:self.url settings:settings error:nil];
        _recorder.delegate = self;
        _recorder.meteringEnabled = YES;
        [_recorder prepareToRecord];
    }
    return _recorder;
}

@end
