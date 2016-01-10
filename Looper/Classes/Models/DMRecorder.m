//
//  DMRecorder.m
//  Looper
//
//  Created by Michael Spelling on 10/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMRecorder.h"
#import <AVFoundation/AVFoundation.h>

CGFloat const DMTrackSampleRate = 44100;
NSUInteger const DMTrackNumberOfChannels = 2;
NSUInteger const DMTrackBitDepth = 16;

@interface DMRecorder()
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSDictionary *settings;

@property (nonatomic, weak) id<DMRecorderDelegate>recordDelegate;

@property (nonatomic, strong) NSTimer *recordTimer;
@end

@implementation DMRecorder

-(instancetype)initWithRecordDelgate:(id<DMRecorderDelegate>)recordDelegate
{
    if (self = [super init]) {
        _recordDelegate = recordDelegate;
        
        _settings = @{
                     AVFormatIDKey          : @(kAudioFormatMPEG4AAC),
                     AVSampleRateKey        : @(DMTrackSampleRate),
                     AVNumberOfChannelsKey  : @(DMTrackNumberOfChannels),
                     AVLinearPCMBitDepthKey : @(DMTrackBitDepth)
                     };
        
        
    }
    return self;
}

-(DMBaseTrack*)recordBaseTrackWithDelegate:(id<DMBaseTrackDelegate>)delegate
{
    DMBaseTrack *track = [[DMBaseTrack alloc] initWithBaseTrackDelegate:delegate];
    if ([self startRecordingTrack:track]) {
        return track;
    }
    return nil;
}

-(DMTrack*)recordNewTrackAt:(CGFloat)offset
{
    DMTrack *track = [[DMTrack alloc] initWithOffset:offset];
    if ([self startRecordingTrack:track]) {
        return track;
    }
    return nil;
}

-(BOOL)startRecordingTrack:(DMTrack*)track
{
    NSError *error = nil;
    self.recorder = [[AVAudioRecorder alloc] initWithURL:track.url settings:self.settings error:&error];
    if (self.recorder && !error) {
        self.recorder.meteringEnabled = YES;
        
        if (self.isRecording) {
            [self.recorder stop];
        }
        
        _recordingTrack = track;
        [self.recorder record];
        [self startRecordTimer];
        
        return YES;
    }
    return NO;
}

-(void)stopRecording
{
    [self.recorder stop];
    [self stopRecordTimer];
}

-(BOOL)isRecording
{
    return self.recorder.isRecording;
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

@end
