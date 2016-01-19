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

-(instancetype)initWithOffset:(NSTimeInterval)offset url:(NSURL*)url;
-(instancetype)initAsBaseTrackWithUrl:(NSURL*)url delegate:(id<DMBaseTrackDelegate>)delegate;
@property (nonatomic, weak) id<DMBaseTrackDelegate> baseTrackDelegate;

-(void)playAtTime:(NSTimeInterval)time;
-(void)stopPlayback;

-(BOOL)isPlaying;
-(NSTimeInterval)currentTime;
-(NSTimeInterval)duration;

@property (nonatomic, assign, readonly) NSTimeInterval offset;
@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, assign) BOOL isBaseTrack;

-(BOOL)isEqualToTrack:(id)object;

@end
