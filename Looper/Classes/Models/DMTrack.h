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
#import "EZAudio.h"

@interface DMTrack : NSObject <NSCoding>

-(instancetype)initWithOffset:(CGFloat)offset;

-(NSString*)filename;

-(void)playAtTime:(CGFloat)time;
-(void)stopPlayback;

-(BOOL)isPlaying;
-(CGFloat)duration;

-(BOOL)isBaseTrack;

@property (nonatomic, assign, readonly) CGFloat offset;
@property (nonatomic, strong, readonly) NSURL *url;

-(BOOL)isEqualToTrack:(id)object;


#pragma mark - For Subclasses

@property (nonatomic, strong, readonly) EZAudioPlayer *player;

@end
