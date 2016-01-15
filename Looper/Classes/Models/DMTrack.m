//
//  DMTrack.m
//  Looper
//
//  Created by Michael Spelling on 04/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMTrack.h"
#import "DMEnvironment.h"

NSString *const DMTrackUrlCodingKey = @"DMTrackUrlCodingKey";
NSString *const DMTrackOffsetCodingKey = @"DMTrackOffsetCodingKey";

@interface DMTrack()
@property (nonatomic, assign) BOOL playScheduled;
@end


@implementation DMTrack

-(instancetype)initWithOffset:(CGFloat)offset filePath:(NSString*)filePath
{
    if (self = [super init]) {
        _offset = offset;
        _url = [NSURL fileURLWithPath:filePath];
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
    } else {
        NSLog(@"%@ play %@ in %f", self.player, self, time);
        self.playScheduled = YES;
        __weak typeof (self)weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if (weakSelf.playScheduled) {
                [weakSelf.player play];
            }
        });
    }
}

-(void)stopPlayback
{
    self.playScheduled = NO;
    
    if (self.isPlaying) {
        [self.player stop];
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

-(CGFloat)duration
{
    return self.player.duration;
}

-(BOOL)isBaseTrack
{
    return NO;
}


#pragma mark - Internal

-(void)createPlayer
{
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.url error:nil];
    _player.numberOfLoops = 0;
    _player.volume = 1;
}


#pragma mark - NSCoding

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.url forKey:DMTrackUrlCodingKey];
    [encoder encodeFloat:self.offset forKey:DMTrackOffsetCodingKey];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        _url = [decoder decodeObjectForKey:DMTrackUrlCodingKey];
        _offset = [decoder decodeFloatForKey:DMTrackOffsetCodingKey];
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
