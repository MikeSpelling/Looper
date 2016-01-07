//
//  DMTrack.m
//  Looper
//
//  Created by Michael Spelling on 04/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMTrack.h"

NSString *const DMTrackUrlCodingKey = @"DMTrackUrlCodingKey";
NSString *const DMTrackOffsetCodingKey = @"DMTrackOffsetCodingKey";

CGFloat const DMTrackSampleRate = 44100;
NSUInteger const DMTrackNumberOfChannels = 2;
NSUInteger const DMTrackBitDepth = 16;

@interface DMTrack()
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@end


@implementation DMTrack

-(instancetype)initWithOffset:(CGFloat)offset
{
    if (self = [super init]) {
        _offset = offset;
    }
    return self;
}

-(void)startRecording
{
    self.hasPlayedInLoop = YES;
    [self.recorder record];
}

-(void)stopRecording
{
    [self.recorder stop];
}

-(void)play
{
    self.hasPlayedInLoop = YES;
    [self.player play];
    NSLog(@"Play %@", self.url.absoluteString);
}

-(void)stopPlayback
{
    [self.player stop];
}

-(void)pausePlayback
{
    [self.player pause];
}

-(void)deleteTrack
{
    [[NSFileManager defaultManager] removeItemAtURL:self.url error:nil];
    _url = nil;
    _player = nil;
    _recorder = nil;
    _offset = 0;
    _hasPlayedInLoop = NO;
}


#pragma mark - Overrides

-(CGFloat)duration
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

-(BOOL)isBaseTrack
{
    return NO;
}

-(AVAudioPlayer*)player
{
    if (!_player) {
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.url error:nil];
        _player.numberOfLoops = 0;
        _player.volume = 0.8;
        [_player prepareToPlay];
    }
    return _player;
}


#pragma mark - Internal

-(AVAudioRecorder*)recorder
{
    if (!_recorder) {
        NSDictionary *settings = @{
                                   AVFormatIDKey          : @(kAudioFormatMPEG4AAC),
                                   AVSampleRateKey        : @(DMTrackSampleRate),
                                   AVNumberOfChannelsKey  : @(DMTrackNumberOfChannels),
                                   AVLinearPCMBitDepthKey : @(DMTrackBitDepth)
                                   };
        
        _recorder = [[AVAudioRecorder alloc] initWithURL:self.url settings:settings error:nil];
        _recorder.meteringEnabled = YES;
        [_recorder prepareToRecord];
    }
    return _recorder;
}

-(NSURL*)url
{
    if (!_url) {
        NSString *baseFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSArray *pathComponents = @[baseFilePath, [NSString stringWithFormat:@"%f.m4a", [[NSDate date] timeIntervalSince1970]]];
        _url = [NSURL fileURLWithPathComponents:pathComponents];
    }
    return _url;
}


#pragma mark - NSCoding

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.url forKey:DMTrackUrlCodingKey];
    [encoder encodeFloat:self.offset forKey:DMTrackOffsetCodingKey];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        _url = [decoder decodeObjectForKey:DMTrackUrlCodingKey];
        _offset = [decoder decodeFloatForKey:DMTrackOffsetCodingKey];
    }
    return self;
}

@end
