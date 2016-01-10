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

NSString *const DMLooperTitleCodingKey = @"DMLooperTitleCodingKey";
NSString *const DMLooperBaseTrackCodingKey = @"DMLooperBaseTrackCodingKey";
NSString *const DMLooperExtraTracksCodingKey = @"DMLooperExtraTracksCodingKey";

@interface DMLooper() <DMBaseTrackDelegate, DMRecorderDelegate>
@property (nonatomic, strong) DMRecorder *recorder;

@property (nonatomic, assign) CGFloat playbackPosition;
@property (nonatomic, assign) CGFloat recordPosition;
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
        
        DMTrack *track = [self.recorder recordNewTrackAt:self.playbackPosition];
        if (track) {
            self.recordingTrack = track;
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        }
    }
    else {
        DMBaseTrack *baseTrack = [self.recorder recordBaseTrackWithDelegate:self];
        if (baseTrack) {
            self.recordingTrack = baseTrack;
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
        }
    }
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

#warning TODO - Create new track at this point? Stop delay when starting new recording...
-(void)stopRecording
{
    [self.recorder stopRecording];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    if (self.recordingTrack.isBaseTrack) {
        self.baseTrack = (DMBaseTrack*)self.recordingTrack;
        [self.baseTrack play];
    }
    else {
        [self.extraTracks addObject:self.recordingTrack];
        if (self.recordingTrack.offset >= self.playbackPosition) {
            [self.recordingTrack playAtTime:self.recordingTrack.offset - self.playbackPosition];
        }
    }
    
    self.recordingTrack = nil;
    self.recordPosition = 0;
}

-(void)play
{
    [self.baseTrack play];
    [self scheduleExtraTracksForPlayback];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

-(void)stopPlayback
{
    for (DMTrack *track in [self recordedTracks]) {
        [track stopPlayback];
    }
    self.playbackPosition = 0;
    
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

-(void)tearDown
{
    for (DMTrack *track in [self allTracks]) {
        [track stopPlayback];
    }
    [self.recorder stopRecording];
    
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
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
    if (self.recordingTrack) {
        [allTracks addObject:self.recordingTrack];
    }
    [allTracks addObjectsFromArray:[self recordedTracks]];
    return allTracks;
}


#pragma mark - DMBaseTrackDelegate

-(void)baseTrackDidLoop
{
    [self scheduleExtraTracksForPlayback];
}

-(void)baseTrackUpdatePosition:(CGFloat)position
{
    self.playbackPosition = position;
}


#pragma mark - Internal

-(void)scheduleExtraTracksForPlayback
{
    for (DMTrack *track in self.extraTracks) {
        CGFloat timeToPlay = track.offset - self.playbackPosition;
        if (track.duration > self.baseTrack.duration) {
            if (!track.isPlaying) [track playAtTime:timeToPlay];
        }
        else {
            [track playAtTime:timeToPlay];
        }
    }
}


#pragma mark - DMRecorderDelegate

-(void)updateRecordPosition:(CGFloat)position
{
    self.recordPosition = position;
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
