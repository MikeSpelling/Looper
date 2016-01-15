//
//  DMAudioController.m
//  Looper
//
//  Created by Michael Spelling on 12/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMAudioController.h"
#import "TheAmazingAudioEngine.h"
#import "AERecorder.h"
#import "DMTrack.h"
#import "DMEnvironment.h"
#import "DMChannel.h"

@interface DMAudioController() <AEAudioTimingReceiver>
@property (nonatomic, strong) AEAudioController *audioController;
@property (nonatomic, assign) AEChannelGroupRef group;
@property (nonatomic, strong) NSMutableDictionary *players;

@property (nonatomic, strong) AERecorder *recorder;
@property (nonatomic, strong) AERecorder *preparedRecorder;
@property (nonatomic, strong) DMTrack *recordingTrack;
@property (nonatomic, strong) DMTrack *baseTrack;
@property (nonatomic, strong) NSMutableArray *extraTracks;

@property (nonatomic, strong) DMEnvironment *environment;
@end


@implementation DMAudioController

@synthesize timingReceiverCallback = _timingReceiverCallback;

-(instancetype)initWithTracks:(NSArray*)tracks
{
    if (self = [super init]) {
        _environment = [DMEnvironment sharedInstance];
        
        _audioController = [[AEAudioController alloc] initWithAudioDescription:AEAudioStreamBasicDescriptionNonInterleaved16BitStereo
                                                                  inputEnabled:YES];
        _audioController.preferredBufferDuration = 0.001;
        _audioController.useMeasurementMode = YES;
        [_audioController addTimingReceiver:self];
        [_audioController start:nil];
        
        _group = [_audioController createChannelGroup];
        
        _players = [NSMutableDictionary new];
        _extraTracks = [NSMutableArray new];
        
        for (DMTrack *track in tracks) {
            [self createPlayerForTrack:track];
        }
        [self prepareNextRecorder];
    }
    return self;
}

-(void)tearDown
{
    [self stopRecording];
    
    [self.audioController stop];
    [self.audioController removeTimingReceiver:self];
    self.audioController = nil;
}

-(void)prepareNextRecorder
{
    self.preparedRecorder = [[AERecorder alloc] initWithAudioController:self.audioController];
    
    NSString *filePath = [self.environment.baseFilePath stringByAppendingString:[NSString stringWithFormat:@"/%f.caf", [[NSDate date] timeIntervalSince1970]]];
    NSError *error = nil;
    BOOL prepared = [self.preparedRecorder prepareRecordingToFileAtPath:filePath fileType:kAudioFileCAFType bitDepth:16 error:&error];
    if (prepared && !error) {
        [self.audioController addInputReceiver:self.preparedRecorder];
    }
    else {
        self.preparedRecorder = nil;
    }
}

#pragma mark - Recording

-(void)toggleRecord
{
    if (self.recordingTrack) {
        [self stopRecording];
    } else {
        [self startRecording];
    }
}

-(void)startRecording
{
    if (self.preparedRecorder) {
        self.recorder = self.preparedRecorder;
        AERecorderStartRecording(self.recorder);
        self.recordingTrack = [[DMTrack alloc] initWithOffset:self.basePlayer.currentTime filePath:self.recorder.path];
        [self prepareNextRecorder];
    }
}

-(void)stopRecording
{
    if (self.recorder) {
        [self.recorder finishRecording];
        [self.audioController removeInputReceiver:self.recorder];
        self.recorder = nil;
        
        [self createPlayerForTrack:self.recordingTrack];
        self.recordingTrack = nil;
    }
}


#pragma mark - Internal

-(void)createPlayerForTrack:(DMTrack*)track
{
    NSError *error = nil;
    DMChannel *player = [DMChannel audioFilePlayerWithURL:track.url error:&error];
    
    if (player && error == nil) {
        player.volume = 0.8;
        
        if (self.baseTrack == nil) {
            self.baseTrack = track;
            __weak typeof (self)weakSelf = self;
            [player setCompletionBlock:^{
//                [weakSelf baseTrackReachedEnd];
            }];
        }
        else {
            [self.extraTracks addObject:track];
            player.channelIsPlaying = NO;
        }
        [self.audioController addChannels:@[player] toChannelGroup:self.group];
        self.players[track.url] = player;
    }
}

-(void)baseTrackReachedEnd
{
    self.basePlayer.currentTime = 0;
    self.basePlayer.channelIsPlaying = YES;
    
    for (DMTrack *track in self.extraTracks) {
        DMChannel *player = self.players[track.url];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(track.offset * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            player.currentTime = 0;
//            player.channelIsPlaying = YES;
//        });
        [player playAtTime:track.offset];
        NSLog(@"Play in %f", track.offset);
    }
}

-(AEAudioFilePlayer*)basePlayer
{
    return self.players[self.baseTrack.url];
}


#pragma mark - AEAudioTimingReceiver

-(AEAudioTimingCallback)timingReceiverCallback {
    return timingReceiverCallback;
}

static void timingReceiverCallback(__unsafe_unretained DMAudioController    *this,
                                   __unsafe_unretained AEAudioController    *audioController,
                                   const AudioTimeStamp                     *time,
                                   UInt32 const                             frames,
                                   AEAudioTimingContext                     context) {
//    if (this->_basePlayer) {
//        AEAudioControllerSendAsynchronousMessageToMainThread(audioController, timeUpdated, &this, sizeof(DMAudioController*));
//    }
}

//static void timeUpdated(void *userInfo, int userInfoLength)
//{
//    DMAudioController *audioController = (__bridge_transfer id)*(void **)userInfo;
//    if (audioController.playbackPosition != audioController.basePlayer.currentTime) {
//        if (audioController.basePlayer.currentTime < audioController.playbackPosition) {
//            [audioController baseTrackLooped];
//        }
//        audioController.playbackPosition = audioController.basePlayer.currentTime;
//        [audioController baseTrackPositionUpdated];
//    }
//}
//
//-(void)baseTrackLooped
//{
//    NSLog(@"LOOP %f on %@", self.playbackPosition, [NSThread currentThread]);
//}
//
//-(void)baseTrackPositionUpdated
//{
//    NSLog(@"%f %@", self.playbackPosition, [NSThread currentThread]);
//}

@end
