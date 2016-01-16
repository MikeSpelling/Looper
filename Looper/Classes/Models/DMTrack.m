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
@property (nonatomic, assign) BOOL playScheduled;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGFloat lastKnownPosition;
@end


@implementation DMTrack

-(instancetype)initWithOffset:(CGFloat)offset url:(NSURL*)url
{
    if (self = [super init]) {
        _offset = offset;
        _url = url;
    }
    return self;
}

-(void)playAtTime:(CGFloat)time
{
    if (!self.player) {
        [self createPlayer];
    }
    if (time <= 0) {
        NSLog(@"%@ play %@", self.player, self);
        [self.player play];
        if (self.isBaseTrack) {
            [self startTimer];
        }
    } else {
        NSLog(@"%@ play %@ in %f", self.player, self, time);
        self.playScheduled = YES;
        [self.player prepareToPlay];
        __weak typeof (self)weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if (weakSelf.playScheduled) {
                [weakSelf.player play];
                weakSelf.playScheduled = NO;
            }
        });
    }
}

-(void)stopPlayback
{
    self.playScheduled = NO;
    
    if (self.isPlaying) {
        [self.player stop];
        [self stopTimer];
    }
}

-(NSString*)filename
{
    return [self.url lastPathComponent];
}
    
-(BOOL)isPlaying
{
    return self.player.isPlaying;
}

-(NSTimeInterval)currentTime
{
    return self.player.currentTime;
}

-(CGFloat)duration
{
    return self.player.duration;
}


#pragma mark - Internal

-(void)createPlayer
{
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.url error:nil];
    _player.numberOfLoops = self.isBaseTrack ? -1 : 0;
    _player.volume = 1;
}


#pragma mark - Timer

-(void)startTimer
{
    if (self.timer) {
        [self stopTimer];
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
}

-(void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

-(void)timerFired
{
    [self.baseTrackDelegate baseTrackUpdatePosition:self.player.currentTime];
    
    CGFloat currentPosition = self.player.currentTime;
    if (currentPosition < self.lastKnownPosition) {
        [self.baseTrackDelegate baseTrackDidLoop];
    }
    self.lastKnownPosition = currentPosition;
}


#pragma mark - NSCoding

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.url forKey:DMTrackUrlCodingKey];
    [encoder encodeFloat:self.offset forKey:DMTrackOffsetCodingKey];
    [encoder encodeBool:self.isBaseTrack forKey:DMTrackIsBaseTrackCodingKey];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        _url = [decoder decodeObjectForKey:DMTrackUrlCodingKey];
        _offset = [decoder decodeFloatForKey:DMTrackOffsetCodingKey];
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
