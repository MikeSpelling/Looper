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
@end


@implementation DMLooper

-(instancetype)init
{
    if (self = [super init]) {
        _fileService = [DMFileService sharedInstance];
        _extraTracks = [NSMutableArray new];
        
        [self commonInit];
    }
    return self;
}

-(void)commonInit
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    _recorder = [[DMRecorder alloc] initWithRecordDelgate:self];
    _baseTrack.baseTrackDelegate = self;
}

-(void)startRecording
{
    if (self.baseTrack) {
        if (!self.baseTrack.isPlaying) {
            [self play];
        }
        [self.recorder startRecordingNextTrack];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else {
        [self.recorder recordBaseTrack:self];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
    }
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

-(void)stopRecording
{
    [self.recorder stopRecording];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}

-(void)play
{
    [self.baseTrack playAtTime:0];
    [self scheduleExtraTracksForPlayback];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

-(void)stopPlayback
{
    for (DMTrack *track in [self recordedTracks]) {
        [track stopPlayback];
    }
    
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

-(void)saveRecordings
{
    [self.recorder saveRecordings];
}

-(void)deleteRecordings
{
    for (DMTrack *track in [self allTracks]) {
        [self.fileService deleteFileNamed:track.filename];
    }
}

-(void)tearDown
{
    for (DMTrack *track in [self allTracks]) {
        [track stopPlayback];
    }
    [self.recorder tearDown];
    
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}


#pragma mark - DMRecorderDelegate

-(void)updateRecordPosition:(NSTimeInterval)position
{
    // Update UI
}

-(void)baseTrackRecorded:(DMTrack*)track
{
    self.baseTrack = track;
    [self.baseTrack playAtTime:0];
}

-(void)trackRecorded:(DMTrack*)track
{
    [self.extraTracks addObject:track];
    if (track.offset >= self.baseTrack.currentTime) {
        [track playAtTime:track.offset - self.baseTrack.currentTime];
    }
}


#pragma mark - DMBaseTrackDelegate

-(void)baseTrackDidLoop
{
    [self scheduleExtraTracksForPlayback];
}

-(void)baseTrackUpdatePosition:(NSTimeInterval)position
{
    // Update UI
}


#pragma mark - Internal

-(void)scheduleExtraTracksForPlayback
{
    for (DMTrack *track in self.extraTracks) {
        [track playAtTime:track.offset - self.baseTrack.currentTime];
    }
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
    NSMutableArray *allTracks = [NSMutableArray new];
    if (self.recorder.recordingTrack) {
        [allTracks addObject:self.recorder.recordingTrack];
    }
    [allTracks addObjectsFromArray:[self recordedTracks]];
    return allTracks;
}


#pragma mark - NSCoding

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.title forKey:DMLooperTitleCodingKey];
    [encoder encodeObject:self.baseTrack forKey:DMLooperBaseTrackCodingKey];
    [encoder encodeObject:self.extraTracks forKey:DMLooperExtraTracksCodingKey];
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
