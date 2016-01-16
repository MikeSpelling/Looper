//
//  DMRecorder.m
//  Looper
//
//  Created by Michael Spelling on 10/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import "DMEnvironment.h"

CGFloat const DMTrackSampleRate = 44100;
NSUInteger const DMTrackNumberOfChannels = 2;
NSUInteger const DMTrackBitDepth = 16;

@interface DMRecorder()
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioRecorder *preparedRecorder;
@property (nonatomic, strong) NSMutableArray *recordersToDelete;

@property (nonatomic, strong) NSDictionary *settings;

@property (nonatomic, strong) DMTrack *recordingTrack;

@property (nonatomic, weak) id<DMRecorderDelegate>recordDelegate;

@property (nonatomic, strong) NSTimer *recordTimer;
@end

@implementation DMRecorder

-(instancetype)initWithRecordDelgate:(id<DMRecorderDelegate>)recordDelegate
{
    if (self = [super init]) {
        _recordDelegate = recordDelegate;
        _recordersToDelete = [NSMutableArray new];
        
        _settings = @{
                     AVFormatIDKey          : @(kAudioFormatMPEG4AAC),
                     AVSampleRateKey        : @(DMTrackSampleRate),
                     AVNumberOfChannelsKey  : @(DMTrackNumberOfChannels),
                     AVLinearPCMBitDepthKey : @(DMTrackBitDepth)
                     };
        [self createNextRecorder];
    }
    return self;
}

-(void)toggleRecordAt:(CGFloat)offset
{
    if (self.recordingTrack) {
        [self stopRecording];
    } else {
        [self startRecordingAt:offset];
    }
}

-(void)createNextRecorder
{
    __weak typeof (self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *pathComponents = @[[DMEnvironment sharedInstance].baseFilePath, [NSString stringWithFormat:@"%f.m4a", [[NSDate date] timeIntervalSince1970]]];
        weakSelf.preparedRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPathComponents:pathComponents] settings:weakSelf.settings error:nil];
        weakSelf.preparedRecorder.meteringEnabled = YES;
        [weakSelf.preparedRecorder prepareToRecord];
        [weakSelf.recordersToDelete addObject:weakSelf.preparedRecorder];
    });
}

-(void)startRecordingAt:(CGFloat)offset
{
    if (self.preparedRecorder) {
        self.recorder = self.preparedRecorder;
        self.preparedRecorder = nil;
        [self.recorder record];
        self.recordingTrack = [[DMTrack alloc] initWithOffset:offset url:self.recorder.url];
        [self startRecordTimer];
        [self createNextRecorder];
    }
}

-(void)stopRecording
{
    [self.recorder stop];
    [self stopRecordTimer];
    self.recordingTrack = nil;
}

-(BOOL)isRecording
{
    return self.recorder.isRecording;
}

-(void)saveRecordings
{
    self.recordersToDelete = [NSMutableArray new];
    if (self.preparedRecorder) {
        [self.recordersToDelete addObject:self.preparedRecorder];
    }
}

-(void)tearDown
{
    [self stopRecording];
    self.recorder = nil;
    self.preparedRecorder = nil;
    self.recordDelegate = nil;
    
    for (AVAudioRecorder *recorder in self.recordersToDelete) {
        [recorder deleteRecording];
    }
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
