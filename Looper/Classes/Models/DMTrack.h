//
//  DMTrack.h
//  Looper
//
//  Created by Michael Spelling on 04/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol DMBaseTrackDelegate <NSObject>
-(void)baseTrackDidLoop;
-(void)baseTrackUpdatePosition:(NSTimeInterval)position;
@end


@interface DMTrack : NSObject <NSCoding>

-(instancetype)initWithOffset:(NSTimeInterval)offset url:(NSURL*)url baseDuration:(NSTimeInterval)baseDuration;
-(instancetype)initAsBaseTrackWithUrl:(NSURL*)url delegate:(id<DMBaseTrackDelegate>)delegate;
@property (nonatomic, weak) id<DMBaseTrackDelegate> baseTrackDelegate;

-(void)createPlayers;
-(void)playAtTime:(NSTimeInterval)time;
-(void)stopPlayback;

-(BOOL)isPlaying;
-(NSTimeInterval)currentTime;

@property (nonatomic, assign, readonly) NSTimeInterval offset;
@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, assign, readonly) NSTimeInterval baseDuration;
@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, assign) BOOL isBaseTrack;
@property (nonatomic, assign) BOOL isMuted;
@property (nonatomic, assign) CGFloat volume;

-(BOOL)isEqualToTrack:(id)object;

@end
