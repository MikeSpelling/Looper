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

@interface DMTrack : NSObject <NSCoding>

-(instancetype)initWithOffset:(CGFloat)offset;

-(BOOL)isBaseTrack;

-(void)startRecording;
-(void)stopRecording;

-(void)play;
-(void)stopPlayback;
-(void)pausePlayback;

-(void)deleteTrack;

@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, assign) BOOL hasPlayedInLoop;
@property (nonatomic, strong) AVAudioPlayer *player;

@end
