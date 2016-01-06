//
//  DMChannel.m
//  Looper
//
//  Created by Michael Spelling on 04/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMChannel.h"
#import <AVFoundation/AVFoundation.h>

NSString *const DMChannelUrlCodingKey = @"DMChannelUrlCodingKey";
NSString *const DMChannelSampleRateCodingKey = @"DMChannelSampleRateCodingKey";
NSString *const DMChannelBitDepthCodingKey = @"DMChannelBitDepthCodingKey";
NSString *const DMChannelNumberOfChannelsCodingKey = @"DMChannelNumberOfChannelsCodingKey";

@interface DMChannel() <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
@property (nonatomic, weak) id<DMChannelDelegate> delegate;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, assign) BOOL playedInLoop;
@end


@implementation DMChannel

-(instancetype)initWithDelegate:(id<DMChannelDelegate>)delegate index:(NSUInteger)index offset:(CGFloat)offset
{
    if (self = [super init]) {
        _delegate = delegate;
        _index = index;
        _offset = offset;
        
        NSString *baseFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSArray *pathComponents = @[baseFilePath, [NSString stringWithFormat:@"%f.m4a", [[NSDate date] timeIntervalSince1970]]];
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
    self.playedInLoop = YES;
}

-(void)stopRecording
{
    [self.recorder stop];
}

-(void)play
{
    [self.player play];
    self.playedInLoop = YES;
    NSLog(@"Play %ld", self.index);
}

-(void)playIfNeededAtOffset:(CGFloat)offset looped:(BOOL)looped
{
    if (looped && !self.isPlaying) {
        self.playedInLoop = NO;
    }
    if (!self.playedInLoop &&
        !self.isRecording &&
        offset > self.offset)
    {
        [self play];
    }
}

-(void)stopPlayback
{
    [self.player stop];
    self.playedInLoop = NO;
}

-(void)pausePlayback
{
    [self.player pause];
}

-(void)deleteFile
{
    [[NSFileManager defaultManager] removeItemAtURL:self.url error:nil];
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

-(CGFloat)duration
{
    return self.player.duration;
}

-(CGFloat)currentTime
{
    return self.player.currentTime;
}

-(BOOL)isRecording
{
    return self.recorder.recording;
}

-(BOOL)isPlaying
{
    return self.player.playing;
}

-(void)setSampleRate:(CGFloat)sampleRate
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


#pragma mark - NSCoding

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.url forKey:DMChannelUrlCodingKey];
    [encoder encodeFloat:self.sampleRate forKey:DMChannelSampleRateCodingKey];
    [encoder encodeInteger:self.bitDepth forKey:DMChannelBitDepthCodingKey];
    [encoder encodeInteger:self.numberOfChannels forKey:DMChannelNumberOfChannelsCodingKey];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        _url = [decoder decodeObjectForKey:DMChannelUrlCodingKey];
        _sampleRate = [decoder decodeFloatForKey:DMChannelSampleRateCodingKey];
        _bitDepth = [decoder decodeIntegerForKey:DMChannelBitDepthCodingKey];
        _numberOfChannels = [decoder decodeIntegerForKey:DMChannelNumberOfChannelsCodingKey];
    }
    return self;
}

@end
