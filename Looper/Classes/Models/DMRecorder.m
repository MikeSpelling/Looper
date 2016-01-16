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

@property (nonatomic, weak) id<DMRecorderDelegate>recordDelegate;

@property (nonatomic, strong) NSTimer *recordTimer;

@property (nonatomic, assign) NSTimeInterval baseDuration;
@property (nonatomic, assign) BOOL stopping;
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

-(void)recordBaseTrack:(id<DMBaseTrackDelegate>)delegate
{
    [self startRecording];
    self.recordingTrack = [[DMTrack alloc] initAsBaseTrackWithUrl:self.recorder.url delegate:delegate];
}

-(void)startRecordingWithOffset:(NSTimeInterval)offset
{
    [self startRecording];
    self.recordingTrack = [[DMTrack alloc] initWithOffset:offset url:self.recorder.url];
}

-(void)startRecording
{
    self.recorder = self.preparedRecorder;
    self.preparedRecorder = nil;
    if (self.baseDuration) {
        [self.recorder recordForDuration:self.baseDuration];
    } else {
        [self.recorder record];
    }
    
    [self createNextRecorder];
    
    [self startRecordTimer];
}

-(void)stopRecording
{
    self.stopping = YES;
    __weak typeof (self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (weakSelf.recordingTrack.isBaseTrack) {
            weakSelf.baseDuration = weakSelf.recorder.currentTime;
        }
        
        [weakSelf.recorder stop];
    });
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

-(NSTimeInterval)recordPosition
{
    return self.recorder.currentTime;
}

#pragma mark - Record timer

-(void)startRecordTimer
{
    if (self.recordTimer) {
        [self stopRecordTimer];
    }
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(recordTimerFired) userInfo:nil repeats:YES];
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


#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if (self.stopping)
    {
        [self stopRecordTimer];
        
        if (self.recordingTrack.isBaseTrack) {
            [self.recordDelegate baseTrackRecorded:self.recordingTrack];
        }
        else {
        }
        
        self.recordingTrack = nil;
        self.stopping = NO;
    }
    else
    {
        [self.recordDelegate trackRecorded:self.recordingTrack];
        [self startRecordingWithOffset:self.recordingTrack.offset];
    }
}


#pragma mark - Internal

-(void)createNextRecorder
{
    __weak typeof (self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *pathComponents = @[[DMEnvironment sharedInstance].baseFilePath, [NSString stringWithFormat:@"%f.m4a", [[NSDate date] timeIntervalSince1970]]];
        weakSelf.preparedRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPathComponents:pathComponents] settings:weakSelf.settings error:nil];
        weakSelf.preparedRecorder.meteringEnabled = YES;
        weakSelf.preparedRecorder.delegate = weakSelf;
        [weakSelf.preparedRecorder prepareToRecord];
        [weakSelf.recordersToDelete addObject:weakSelf.preparedRecorder];
    });
}

@end
