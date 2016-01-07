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

-(void)startRecording;
-(void)stopRecording;

-(void)play;
-(void)stopPlayback;
-(void)pausePlayback;

-(NSString*)filename;

@property (nonatomic, assign, readonly) CGFloat offset;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, assign) BOOL hasPlayedInLoop;

-(BOOL)isEqualToTrack:(id)object;

@end
