//
//  DMLooper.m
//  Looper
//
//  Created by Michael Spelling on 04/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "DMLooper.h"
#import "DMRecorder.h"
#import "DMFileService.h"

NSString *const DMLooperTitleCodingKey = @"DMLooperTitleCodingKey";
NSString *const DMLooperBaseTrackCodingKey = @"DMLooperBaseTrackCodingKey";
NSString *const DMLooperExtraTracksCodingKey = @"DMLooperExtraTracksCodingKey";

@interface DMLooper() <DMBaseTrackDelegate, DMRecorderDelegate>
@property (nonatomic, strong) DMRecorder *recorder;
@property (nonatomic, strong) DMFileService *fileService;
@property (nonatomic, strong) AVAudioSession *audioSession;
@end


@implementation DMLooper

-(instancetype)init
{
    if (self = [super init]) {
        _extraTracks = [NSMutableArray new];
        [self commonInit];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        _title = [decoder decodeObjectForKey:DMLooperTitleCodingKey];
        _baseTrack = [decoder decodeObjectForKey:DMLooperBaseTrackCodingKey];
        _extraTracks = [decoder decodeObjectForKey:DMLooperExtraTracksCodingKey];
        [self commonInit];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.title forKey:DMLooperTitleCodingKey];
    [encoder encodeObject:self.baseTrack forKey:DMLooperBaseTrackCodingKey];
    [encoder encodeObject:self.extraTracks forKey:DMLooperExtraTracksCodingKey];
}

-(void)commonInit
{
    _audioSession = [AVAudioSession sharedInstance];
    _fileService = [DMFileService sharedInstance];
    _baseTrack.baseTrackDelegate = self;
}

-(void)dealloc
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}


#pragma mark - DMLooper

-(void)setupForRecording
{
    // Changing stuff on session seems to take too long
    [self.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [self.audioSession setActive:YES error:nil];
    
    _recorder = [[DMRecorder alloc] initWithRecordDelgate:self];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

-(void)startRecording
{
    if (self.baseTrack) {
        if (!self.baseTrack.isPlaying) {
            [self play];
        }
        [self.recorder startRecordingNextTrack];
    }
    else {
        [self.recorder recordBaseTrack:self];
    }
}

-(void)stopRecording
{
    [self.recorder stopRecording];
}

-(void)scheduleRecordingForNextLoop
{
    [self.recorder scheduleRecordingForNextLoop];
}

-(void)play
{    
    [self.baseTrack playAtTime:0];
    [self scheduleExtraTracksForPlayback];
}

-(void)stopPlayback
{
    for (DMTrack *track in [[self recordedTracks] copy]) {
        [track stopPlayback];
    }
}

-(void)muteTrack:(DMTrack*)track muted:(BOOL)muted
{
    track.isMuted = muted;
}

-(void)saveRecordings
{
    [self.recorder saveRecordings];
}

-(void)deleteRecordings
{
    for (DMTrack *track in [[self allTracks] copy]) {
        [self.fileService deleteFileAtUrl:track.url];
    }
}

-(void)deleteTrack:(DMTrack*)track
{
    if ([self.extraTracks containsObject:track]) {
        [track stopPlayback];
        [self.fileService deleteFileAtUrl:track.url];
        [self.extraTracks removeObject:track];
    }
}

-(void)tearDown
{
    for (DMTrack *track in [self allTracks]) {
        [track stopPlayback];
    }
    [self.recorder tearDown];
    
    [self.audioSession setActive:NO error:nil];
}

-(NSArray*)recordedTracks
{
    NSMutableArray *recordedTracks = [NSMutableArray new];
    if (self.baseTrack) {
        [recordedTracks addObject:self.baseTrack];
        if (self.extraTracks) {
            [recordedTracks addObjectsFromArray:self.extraTracks];
        }
    }
    return recordedTracks;
}

-(NSArray*)allTracks
{
    NSArray *allTracks = [self recordedTracks];
    if (self.recorder.recordingTrack) {
        allTracks = [allTracks arrayByAddingObject:self.recorder.recordingTrack];
    }
    return allTracks;
}


#pragma mark - DMBaseTrackDelegate

-(void)baseTrackDidLoop
{
    [self scheduleExtraTracksForPlayback];
}

-(void)baseTrackUpdatePosition:(NSTimeInterval)position
{
    //    self.playbackPosition = position;
}


#pragma mark - Internal

-(void)scheduleExtraTracksForPlayback
{
    for (DMTrack *track in [self.extraTracks copy]) {
        [track playAtTime:track.offset - self.baseTrack.currentTime];
    }
}


#pragma mark - DMRecorderDelegate

-(void)updateRecordPosition:(NSTimeInterval)position
{
    //    self.recordPosition = position;
}

-(void)trackRecorded:(DMTrack *)track
{
    if (!self.baseTrack) {
        self.baseTrack = track;
        [self.baseTrack playAtTime:0];
    }
    else {
        [self.extraTracks addObject:track];
        if (track.offset >= self.baseTrack.currentTime) {
            [track playAtTime:track.offset - self.baseTrack.currentTime];
        }
    }
    
    [self.delegate looperTracksChanged];
}


#pragma mark - Equality

-(BOOL)isEqualToLooper:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[DMLooper class]]) {
        return NO;
    }
    
    DMLooper *looper = object;
    BOOL titlesSame = (!looper.title && !self.title) || [looper.title isEqualToString:self.title];
    if (!titlesSame) {
        return NO;
    }
    
    BOOL baseTrackSame = (!looper.baseTrack && !self.baseTrack) || [looper.baseTrack isEqualToTrack:self.baseTrack];
    if (!baseTrackSame) {
        return NO;
    }
    
    BOOL extraTracksEqualSize = (!looper.extraTracks && !self.extraTracks) || looper.extraTracks.count == self.extraTracks.count;
    if (!extraTracksEqualSize) {
        return NO;
    }
    
    for (NSUInteger i=0; i<looper.extraTracks.count; i++) {
        DMTrack *otherTrack = looper.extraTracks[i];
        DMTrack *track = self.extraTracks[i];
        if (![track isEqualToTrack:otherTrack]) {
            return NO;
        }
    }
    
    return YES;
}

@end
