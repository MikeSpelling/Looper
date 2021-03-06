//
//  DMTrack.m
//  Looper
//
//  Created by Michael Spelling on 04/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMTrack.h"

NSString *const DMTrackUrlCodingKey = @"DMTrackUrlCodingKey";
NSString *const DMTrackOffsetCodingKey = @"DMTrackOffsetCodingKey";
NSString *const DMTrackDurationCodingKey = @"DMTrackDurationCodingKey";
NSString *const DMTrackIsBaseTrackCodingKey = @"DMTrackIsBaseTrackCodingKey";
NSString *const DMTrackIsMutedCodingKey = @"DMTrackIsMutedCodingKey";
NSString *const DMTrackVolumeCodingKey = @"DMTrackVolumeCodingKey";
NSString *const DMTrackBaseDurationCodingKey = @"DMTrackBaseDurationCodingKey";

@interface DMTrack()
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, assign) NSTimeInterval lastKnownPosition;

@property (nonatomic, strong) AVAudioPlayer *player1;
@property (nonatomic, strong) AVAudioPlayer *player2;
@end


@implementation DMTrack

-(instancetype)initWithOffset:(NSTimeInterval)offset url:(NSURL*)url baseDuration:(NSTimeInterval)baseDuration
{
    if (self = [super init]) {
        _offset = offset;
        _url = url;
        _volume = 0.8;
        _baseDuration = baseDuration;
    }
    return self;
}

-(instancetype)initAsBaseTrackWithUrl:(NSURL*)url delegate:(id<DMBaseTrackDelegate>)delegate
{
    if (self = [super init]) {
        _offset = 0;
        _url = url;
        _volume = 0.8;
        _isBaseTrack = YES;
        _baseTrackDelegate = delegate;
    }
    return self;
}

#pragma mark NSCoding

-(id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        _url = [decoder decodeObjectForKey:DMTrackUrlCodingKey];
        _offset = [decoder decodeDoubleForKey:DMTrackOffsetCodingKey];
        _duration = [decoder decodeDoubleForKey:DMTrackDurationCodingKey];
        _isBaseTrack = [decoder decodeBoolForKey:DMTrackIsBaseTrackCodingKey];
        _isMuted = [decoder decodeBoolForKey:DMTrackIsMutedCodingKey];
        _volume = [decoder decodeFloatForKey:DMTrackVolumeCodingKey];
        _baseDuration = [decoder decodeDoubleForKey:DMTrackBaseDurationCodingKey];
        
        [self createPlayers];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.url forKey:DMTrackUrlCodingKey];
    [encoder encodeDouble:self.offset forKey:DMTrackOffsetCodingKey];
    [encoder encodeDouble:self.duration forKey:DMTrackDurationCodingKey];
    [encoder encodeBool:self.isBaseTrack forKey:DMTrackIsBaseTrackCodingKey];
    [encoder encodeBool:self.isMuted forKey:DMTrackIsMutedCodingKey];
    [encoder encodeFloat:self.volume forKey:DMTrackVolumeCodingKey];
    [encoder encodeDouble:self.baseDuration forKey:DMTrackBaseDurationCodingKey];
}


#pragma mark - DMTrack

-(void)playAtTime:(NSTimeInterval)time
{
    if (!self.player1) {
        [self createPlayers];
    }
    
    // Check whether should already be playing (wrapped track)
    if (!self.isBaseTrack && !self.isPlaying) {
        NSTimeInterval wrappedEndTime = self.offset + self.duration - self.baseDuration;
        if (time < wrappedEndTime) {
            AVAudioPlayer *player = self.freePlayer;
            player.currentTime = self.baseDuration - self.offset + time;
            [player play];
        }
    }
    
    // Schedule next play on the next free player
    NSTimeInterval adjustedTime = self.offset - time;
    AVAudioPlayer *player = self.freePlayer;
    if (adjustedTime <= 0) {
        player.currentTime = -adjustedTime;
        [player play];
    }
    else {
        [player playAtTime:player.deviceCurrentTime+adjustedTime];
    }
    
    if (self.isBaseTrack) {
        [self startTimer];
    }
}

-(void)stopPlayback
{
    [self.player1 stop];
    [self.player2 stop];
    [self stopTimer];
    self.lastKnownPosition = 0;
}

-(BOOL)isPlaying
{
    return self.currentlyPlayingPlayer != nil;
}

-(NSTimeInterval)currentTime
{
    return self.currentlyPlayingPlayer.currentTime;
}

-(void)setIsMuted:(BOOL)isMuted
{
    _isMuted = isMuted;
    
    [self setPlayersVolumes];
}

-(void)setVolume:(CGFloat)volume
{
    _volume = volume;
    
    [self setPlayersVolumes];
}

-(void)createPlayers
{
    self.player1 = [[AVAudioPlayer alloc] initWithContentsOfURL:self.url error:nil];
    self.player1.numberOfLoops = self.isBaseTrack ? -1 : 0;
    [self.player1 prepareToPlay];
    if (!_duration) _duration = self.player1.duration;
    if (self.isBaseTrack && !_baseDuration) _baseDuration = _duration;
    
    // May need to overlap if not a base track, needs second player
    if (!self.isBaseTrack) {
        self.player2 = [[AVAudioPlayer alloc] initWithContentsOfURL:self.url error:nil];
        self.player2.numberOfLoops = 0;
        [self.player2 prepareToPlay];
    }
    
    [self setPlayersVolumes];
}


#pragma mark - Internal

-(void)setPlayersVolumes
{
    self.player1.volume = self.isMuted ? 0 : self.volume;
    self.player2.volume = self.isMuted ? 0 : self.volume;
}

-(AVAudioPlayer*)currentlyPlayingPlayer
{
    if (self.player1.isPlaying) {
        return self.player1;
    }
    else if (self.player2.isPlaying) {
        return self.player2;
    }
    return nil;
}

-(AVAudioPlayer*)freePlayer
{
    if (!self.player1.isPlaying) {
        [self.player1 prepareToPlay];
        return self.player1;
    }
    else if (!self.player2.isPlaying) {
        [self.player2 prepareToPlay];
        return self.player2;
    }
    return nil;
}


#pragma mark - Timer

-(void)startTimer
{
    if (!self.timer) {
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0/*DISPATCH_TIMER_STRICT*/, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT/*DISPATCH_QUEUE_PRIORITY_HIGH*/, 0));
        
        __weak typeof (self)weakSelf = self;
        dispatch_source_set_event_handler(self.timer, ^{
            [weakSelf timerFired];
        });
        
        dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC), (int64_t)(0.0001 * NSEC_PER_SEC));
        dispatch_resume(self.timer);
    }
}

-(void)stopTimer
{
    self.timer = nil;
}

-(void)timerFired
{
    AVAudioPlayer *player = self.currentlyPlayingPlayer;
    NSTimeInterval currentPosition = player.currentTime;
    if (currentPosition < self.lastKnownPosition) {
        [self.baseTrackDelegate baseTrackDidLoop];
    }
    self.lastKnownPosition = currentPosition;
}


#pragma mark - Equality

-(BOOL)isEqualToTrack:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[DMTrack class]]) {
        return NO;
    }
    
    DMTrack *track = object;
    
    // Precision lost when serialized
    if (fabs(track.offset-self.offset) > 0.0001) {
        return NO;
    }
    
    if (fabs(track.duration-self.duration) > 0.0001) {
        return NO;
    }
    
    if (fabs(track.baseDuration-self.baseDuration) > 0.0001) {
        return NO;
    }
    
    if (fabs(track.volume-self.volume) > 0.0001) {
        return NO;
    }
    
    BOOL urlsSame = (!track.url && !self.url) || [track.url.absoluteString isEqualToString:self.url.absoluteString];
    if (!urlsSame) {
        return NO;
    }
    
    if (track.isBaseTrack != self.isBaseTrack) {
        return NO;
    }
    
    if (track.isMuted != self.isMuted) {
        return NO;
    }
    
    return YES;
}

@end
