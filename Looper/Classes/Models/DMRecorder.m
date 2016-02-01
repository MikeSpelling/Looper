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

NSTimeInterval const DMTrackSampleRate = 44100;
NSUInteger const DMTrackNumberOfChannels = 2;
NSUInteger const DMTrackBitDepth = 16;

@interface DMRecorder() <AVAudioRecorderDelegate>
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioRecorder *preparedRecorder;
@property (nonatomic, strong) NSMutableArray *recordersToDelete;

@property (nonatomic, strong) NSDictionary *settings;

@property (nonatomic, strong) DMTrack *recordingTrack;
@property (nonatomic, strong) DMTrack *baseTrack;
@property (nonatomic, assign) BOOL stopRequested;
@property (nonatomic, assign) BOOL recordScheduled;

@property (nonatomic, weak) id<DMRecorderDelegate>recordDelegate;

@property (nonatomic, strong) NSTimer *recordTimer;
@end

@implementation DMRecorder

-(instancetype)initWithRecordDelgate:(id<DMRecorderDelegate>)recordDelegate baseTrack:(DMTrack*)baseTrack
{
    if (self = [super init]) {
        _baseTrack = baseTrack;
        _recordDelegate = recordDelegate;
        _recordersToDelete = [NSMutableArray new];
        
        _settings = @{
                      AVFormatIDKey          : @(kAudioFormatLinearPCM),
                      AVSampleRateKey        : @(DMTrackSampleRate),
                      AVNumberOfChannelsKey  : @(DMTrackNumberOfChannels),
                      AVLinearPCMBitDepthKey : @(DMTrackBitDepth)
                      };
        [self createNextRecorder];
    }
    return self;
}

-(void)createNextRecorder
{
    __weak typeof (self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!weakSelf.preparedRecorder) {
            NSArray *pathComponents = @[[DMEnvironment sharedInstance].baseFilePath, [NSString stringWithFormat:@"%f.caf", [[NSDate date] timeIntervalSince1970]]];
            weakSelf.preparedRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPathComponents:pathComponents] settings:weakSelf.settings error:nil];
            weakSelf.preparedRecorder.meteringEnabled = YES;
            [weakSelf.preparedRecorder prepareToRecord];
            if (weakSelf.preparedRecorder) {
                [weakSelf.recordersToDelete addObject:weakSelf.preparedRecorder];
            }
        }
    });
}

-(void)recordBaseTrack:(id<DMBaseTrackDelegate>)delegate
{
    if (!self.stopRequested) {
        [self startRecording];
        self.recordingTrack = [[DMTrack alloc] initAsBaseTrackWithUrl:self.recorder.url delegate:delegate];
    }
}

-(void)startRecordingNextTrack
{
    if (!self.stopRequested) {
        [self startRecording];
        self.recordingTrack = [[DMTrack alloc] initWithOffset:self.baseTrack.currentTime url:self.recorder.url baseDuration:self.baseTrack.duration];
    }
}

-(void)scheduleRecordingForNextLoop
{
    if (!self.recordScheduled) {
        self.recordScheduled = YES;
        
        __weak typeof (self)weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.baseTrack.duration-self.baseTrack.currentTime * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if (weakSelf.recordScheduled) {
                weakSelf.recordScheduled = NO;
                [weakSelf startRecordingNextTrack];
            }
        });
    }
}

-(void)startRecording
{
    self.recorder = self.preparedRecorder;
    self.preparedRecorder = nil;
    
    if (self.recorder) {
        self.recorder.delegate = self;
        
        if (self.baseTrack) {
            [self.recorder recordForDuration:self.baseTrack.duration];
        } else {
            [self.recorder record];
        }
        
        [self startRecordTimer];
    }
    
    [self createNextRecorder];
}

-(void)stopRecording
{
    self.recordScheduled = NO;
    
    if (self.recorder.isRecording) {
        self.stopRequested = YES;
        [self.recorder stop];
    }
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
    self.recordDelegate = nil;
    self.recorder.delegate = nil;
    
    [self stopRecordTimer];
    
    [self.recorder stop];
    [self.preparedRecorder stop];
    self.recorder = nil;
    self.preparedRecorder = nil;
    self.recordingTrack = nil;
    
    for (AVAudioRecorder *recorder in self.recordersToDelete) {
        [recorder deleteRecording];
    }
    self.recordersToDelete = nil;
}

-(BOOL)isRecording
{
    return self.recorder.isRecording;
}


#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    [self stopRecordTimer];
    
    DMTrack *recordedTrack = self.recordingTrack;
    BOOL stopRequested = self.stopRequested;
    
    self.stopRequested = NO;
    self.recordingTrack = nil;
    self.recorder = nil;
    self.recorder.delegate = nil;
    
    [recordedTrack createPlayers];
    [self.recordDelegate trackRecorded:recordedTrack];
    if (!self.baseTrack) {
        self.baseTrack = recordedTrack;
    }
    
    if (!stopRequested)  {
        [self startRecordingNextTrack];
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
}

-(void)recordTimerFired
{
    [self.recordDelegate updateRecordPosition:self.recorder.currentTime];
}

@end
