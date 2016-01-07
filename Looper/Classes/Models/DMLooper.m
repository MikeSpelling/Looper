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

@interface DMLooper() <DMBaseTrackDelegate>
@property (nonatomic, strong) DMBaseTrack *baseTrack;
@property (nonatomic, strong) NSMutableArray *extraTracks;

@property (nonatomic, strong) DMTrack *recordingTrack;

@property (nonatomic, assign) CGFloat playbackPosition;
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
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
}

-(void)startRecording
{
    if (self.baseTrack) {
        self.recordingTrack = [[DMTrack alloc] initWithOffset:self.playbackPosition];
        [self.extraTracks addObject:self.recordingTrack];
    }
    else {
        self.baseTrack = [[DMBaseTrack alloc] initWithDelegate:self];
        self.recordingTrack = self.baseTrack;
    }
    
    [self.recordingTrack startRecording];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

-(void)stopRecording
{
    [self.recordingTrack stopRecording];
    
    if (self.recordingTrack.isBaseTrack) {
        [self.recordingTrack play];
    }
    
    self.recordingTrack = nil;
}

-(void)play
{
    [self.baseTrack play];
    for (DMTrack *track in self.extraTracks) {
        [track play];
    }
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

-(void)stopPlayback
{
    [self.baseTrack stopPlayback];
    for (DMTrack *track in self.extraTracks) {
        [track stopPlayback];
    }
    
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

-(void)pausePlayback
{
    [self.baseTrack pausePlayback];
    for (DMTrack *track in self.extraTracks) {
        [track pausePlayback];
    }
    
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

-(void)deleteLooper
{
    [self.baseTrack deleteTrack];
    for (DMTrack *track in self.extraTracks) {
        [track deleteTrack];
    }
    _title = nil;
    _baseTrack = nil;
    _extraTracks = nil;
}


#pragma mark - DMBaseTrackDelegate

-(void)baseTrackDidLoop
{
    NSLog(@"Loop");
    for (DMTrack *track in self.extraTracks) {
        track.hasPlayedInLoop = NO;
    }
}

-(void)baseTrackUpdatePosition:(CGFloat)position
{
    self.playbackPosition = position;
    
    for (DMTrack *track in self.extraTracks) {
        if (!track.hasPlayedInLoop && position >= track.offset) {
            [track play];
        }
    }
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

@end
