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
NSString *const DMTrackIsBaseTrackCodingKey = @"DMTrackIsBaseTrackCodingKey";

@interface DMTrack()
@property (nonatomic, assign) NSTimeInterval lastKnownPosition;
@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, strong) AVAudioPlayer *player1;
@property (nonatomic, strong) AVAudioPlayer *player2;
@end


@implementation DMTrack

-(instancetype)initWithOffset:(NSTimeInterval)offset url:(NSURL*)url
{
    if (self = [super init]) {
        _offset = offset;
        _url = url;
    }
    return self;
}

-(instancetype)initAsBaseTrackWithUrl:(NSURL*)url delegate:(id<DMBaseTrackDelegate>)delegate
{
    if (self = [super init]) {
        _offset = 0;
        _url = url;
        _isBaseTrack = YES;
        _baseTrackDelegate = delegate;
    }
    return self;
}

-(void)playAtTime:(NSTimeInterval)time
{
    // Lazy load the players when we want to play - ensures we should have required metadata
    if (!self.player1) {
        [self createPlayers];
    }
    
    // Get a player that is ready to play
    AVAudioPlayer *player = self.freePlayer;
    if (time <= 0) {
        player.currentTime = -time;
        [player play];
    }
    else {
        [player playAtTime:player.deviceCurrentTime+time];
    }
    
    if (self.isBaseTrack) {
        [self startTimer];
    }
}

-(void)stopPlayback
{
    [self.currentlyPlayingPlayer stop];
    [self stopTimer];
}

-(NSString*)filename
{
    return [self.url lastPathComponent];
}
    
-(BOOL)isPlaying
{
    return self.currentlyPlayingPlayer != nil;
}

-(NSTimeInterval)currentTime
{
    return self.currentlyPlayingPlayer.currentTime;
}

-(NSTimeInterval)duration
{
    return self.player1.duration;
}

-(void)tearDown
{
    [self stopPlayback];
}


#pragma mark - Internal

-(void)createPlayers
{
    self.player1 = [[AVAudioPlayer alloc] initWithContentsOfURL:self.url error:nil];
    self.player1.numberOfLoops = self.isBaseTrack ? -1 : 0;
    self.player1.volume = 1;
    
    // May need to overlap if not a base track, needs second player
    if (!self.isBaseTrack) {
        self.player2 = [[AVAudioPlayer alloc] initWithContentsOfURL:self.url error:nil];
        self.player2.numberOfLoops = 0;
        self.player2.volume = 1;
    }
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
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, DISPATCH_TIMER_STRICT, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
        
        __weak typeof (self)weakSelf = self;
        dispatch_source_set_event_handler(self.timer, ^{
            [weakSelf timerFired];
        });
        
        dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC), (int64_t)(0.01 * NSEC_PER_SEC));
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
        NSLog(@"%@ Looped %f", player, currentPosition);
        [self.baseTrackDelegate baseTrackDidLoop];
    }
    NSLog(@"%f %f", player.currentTime, player.deviceCurrentTime);
    self.lastKnownPosition = currentPosition;
}


#pragma mark - NSCoding

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.url forKey:DMTrackUrlCodingKey];
    [encoder encodeDouble:self.offset forKey:DMTrackOffsetCodingKey];
    [encoder encodeBool:self.isBaseTrack forKey:DMTrackIsBaseTrackCodingKey];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        _url = [decoder decodeObjectForKey:DMTrackUrlCodingKey];
        _offset = [decoder decodeDoubleForKey:DMTrackOffsetCodingKey];
        _isBaseTrack = [decoder decodeBoolForKey:DMTrackIsBaseTrackCodingKey];
    }
    return self;
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
    
    BOOL urlsSame = (!track.url && !self.url) || [track.url.absoluteString isEqualToString:self.url.absoluteString];
    if (!urlsSame) {
        return NO;
    }
    
    return YES;
}

@end
