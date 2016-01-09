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

@protocol DMTrackRecordDelegate <NSObject>
-(void)updateRecordPosition:(CGFloat)position;
@end


@interface DMTrack : NSObject <NSCoding>

-(instancetype)initWithOffset:(CGFloat)offset recordDelgate:(id<DMTrackRecordDelegate>)recordDelegate;

-(void)startRecording;
-(void)stopRecording;

-(void)playAtTime:(CGFloat)time;
-(void)stopPlayback;
-(void)pausePlayback;

-(NSString*)filename;
-(BOOL)isRecording;

@property (nonatomic, assign, readonly) CGFloat offset;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, assign) BOOL hasPlayedInLoop;

-(BOOL)isEqualToTrack:(id)object;

@end
