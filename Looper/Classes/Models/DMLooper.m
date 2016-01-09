//
//  DMLooper.m
//  Looper
//
//  Created by Michael Spelling on 04/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "DMLooper.h"
#import "DMBaseTrack.h"
#import "DMTrack.h"

NSString *const DMLooperTitleCodingKey = @"DMLooperTitleCodingKey";
NSString *const DMLooperBaseTrackCodingKey = @"DMLooperBaseTrackCodingKey";
NSString *const DMLooperExtraTracksCodingKey = @"DMLooperExtraTracksCodingKey";

@interface DMLooper() <DMBaseTrackDelegate, DMTrackRecordDelegate>
@property (nonatomic, strong) DMBaseTrack *baseTrack;
@property (nonatomic, strong) NSMutableArray *extraTracks;

@property (nonatomic, strong) DMTrack *recordingTrack;

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
    _baseTrack.baseTrackDelegate = self;
}

-(void)startRecording
{
    if (self.baseTrack) {
        if (!self.baseTrack.player.isPlaying) {
            [self play];
        }
        
        self.recordingTrack = [[DMTrack alloc] initWithOffset:self.playbackPosition recordDelgate:self];
        [self.extraTracks addObject:self.recordingTrack];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else {
        self.baseTrack = [[DMBaseTrack alloc] initWithBaseTrackDelegate:self recordDelegate:self];
        self.recordingTrack = self.baseTrack;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
    }
    
    [self.recordingTrack startRecording];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

-(void)stopRecording
{
    [self.recordingTrack stopRecording];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    if (self.recordingTrack == self.baseTrack) {
        [self.baseTrack play];
    }
    
    self.recordingTrack = nil;
    self.recordPosition = 0;
}

-(void)play
{
    [self.baseTrack play];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

-(void)stopPlayback
{
    for (DMTrack *track in [self tracks]) {
        [track stopPlayback];
    }
    self.playbackPosition = 0;
    
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

-(void)pausePlayback
{
    for (DMTrack *track in [self tracks]) {
        [track pausePlayback];
    }
    
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

-(void)tearDown
{
    for (DMTrack *track in [self tracks]) {
        [track stopPlayback];
        [track stopRecording];
    }
    
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

-(NSArray*)tracks
{
    NSArray *allTracks = [NSArray new];
    if (self.baseTrack) {
        allTracks = @[self.baseTrack];
        if (self.extraTracks) {
            allTracks = [allTracks arrayByAddingObjectsFromArray:self.extraTracks];
        }
    }
    return allTracks;
}


#pragma mark - DMBaseTrackDelegate

-(void)baseTrackDidLoop
{
    for (DMTrack *track in self.extraTracks) {
        track.hasPlayedInLoop = NO;
    }
}

-(void)baseTrackUpdatePosition:(CGFloat)position
{
    self.playbackPosition = position;
    
    for (DMTrack *track in self.extraTracks) {
        if (!track.hasPlayedInLoop && position >= track.offset) {
            [track playAtTime:position];
        }
    }
}


#pragma mark - DMTrackRecordDelegate

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
