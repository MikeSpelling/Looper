//
//  DMTrack.m
//  Looper
//
//  Created by Michael Spelling on 04/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMTrack.h"
#import "DMEnvironment.h"

NSString *const DMTrackUrlCodingKey = @"DMTrackUrlCodingKey";
NSString *const DMTrackOffsetCodingKey = @"DMTrackOffsetCodingKey";

CGFloat const DMTrackSampleRate = 44100;
NSUInteger const DMTrackNumberOfChannels = 2;
NSUInteger const DMTrackBitDepth = 16;

@interface DMTrack()
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSTimer *recordTimer;
@property (nonatomic, strong) id<DMTrackRecordDelegate>recordDelegate;
@end


@implementation DMTrack

-(instancetype)initWithOffset:(CGFloat)offset recordDelgate:(id<DMTrackRecordDelegate>)recordDelegate
{
    if (self = [super init]) {
        _offset = offset;
        _recordDelegate = recordDelegate;
        
        NSArray *pathComponents = @[[DMEnvironment sharedInstance].baseFilePath, [NSString stringWithFormat:@"%f.m4a", [[NSDate date] timeIntervalSince1970]]];
        _url = [NSURL fileURLWithPathComponents:pathComponents];
    }
    return self;
}

-(void)startRecording
{
    self.hasPlayedInLoop = YES;
    [self.recorder record];
    
    [self startRecordTimer];
}

-(void)stopRecording
{
    [self stopRecordTimer];
    
    [self.recorder stop];
}

-(void)play
{
    if (!self.recorder.isRecording) {
        self.hasPlayedInLoop = YES;
        [self.player play];
    }
}

-(void)stopPlayback
{
    [self stopRecording];
    [self.player stop];
}

-(void)pausePlayback
{
    [self stopRecording];
    [self.player pause];
}

-(NSString*)filename
{
    return [_url lastPathComponent];
}

-(BOOL)isRecording
{
    return self.recorder.isRecording;
}


#pragma mark - Overrides

-(AVAudioPlayer*)player
{
    if (!_player) {
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.url error:nil];
        _player.numberOfLoops = 0;
        _player.volume = 1;
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


#pragma mark - Record timer

-(void)startRecordTimer
{
    if (self.recordTimer) {
        [self stopRecordTimer];
    }
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(recordTimerFired) userInfo:nil repeats:YES];
}

-(void)stopRecordTimer
{
    [self.recordTimer invalidate];
    self.recordTimer = nil;
    [self.recordDelegate updateRecordPosition:self.recorder.currentTime];
}

-(void)recordTimerFired
{
    [self.recordDelegate updateRecordPosition:self.recorder.currentTime];
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


#pragma mark - Equality

-(BOOL)isEqualToTrack:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[DMTrack class]]) {
        return NO;
    }
    
    DMTrack *track = object;
    
    // Precision lost when serialized
    if (fabs(track.offset-self.offset) > 0.0001) {
        return NO;
    }
    
    BOOL urlsSame = (!track.url && !self.url) || [track.url.absoluteString isEqualToString:self.url.absoluteString];
    if (!urlsSame) {
        return NO;
    }
    
    return YES;
}

@end
