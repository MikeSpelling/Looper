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
-(void)baseTrackUpdatePosition:(CGFloat)position;
@end


@interface DMTrack : NSObject <NSCoding>

-(instancetype)initWithOffset:(CGFloat)offset url:(NSURL*)url;
@property (nonatomic, weak) id<DMBaseTrackDelegate> baseTrackDelegate;

-(NSString*)filename;

-(void)playAtTime:(CGFloat)time;
-(void)stopPlayback;

-(BOOL)isPlaying;
-(NSTimeInterval)currentTime;
-(CGFloat)duration;

@property (nonatomic, assign, readonly) CGFloat offset;
@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, assign) BOOL isBaseTrack;

-(BOOL)isEqualToTrack:(id)object;


#pragma mark - For Subclasses

@property (nonatomic, strong, readonly) AVAudioPlayer *player;

@end
