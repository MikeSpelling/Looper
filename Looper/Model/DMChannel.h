//
//  DMChannel.h
//  Looper
//
//  Created by Michael Spelling on 04/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DMChannel;

@protocol DMChannelDelegate <NSObject>
@optional
-(void)channel:(DMChannel*)channel recordFinishedSuccessfully:(BOOL)successfully;
-(void)channel:(DMChannel*)channel recordErrorDidOrrur:(NSError*)error;
-(void)channel:(DMChannel*)channel playbackFinishedSuccessfully:(BOOL)successfully;
-(void)channel:(DMChannel*)channel playbackErrorDidOrrur:(NSError*)error;
@end


@interface DMChannel : NSObject

-(instancetype)initWithDelegate:(id<DMChannelDelegate>)delegate index:(NSUInteger)index offset:(NSUInteger)offset;

-(void)record;
-(void)play;
-(void)stopPlayback;
-(void)stopRecording;

@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, assign, readonly) NSUInteger index;
@property (nonatomic, assign, readonly) NSUInteger offset;
@property (nonatomic, assign, readonly) NSUInteger duration;
@property (nonatomic, assign, readonly) BOOL isRecording;
@property (nonatomic, assign, readonly) BOOL isPlaying;

@property (nonatomic, assign) NSUInteger sampleRate;
@property (nonatomic, assign) NSUInteger bitDepth;
@property (nonatomic, assign) NSUInteger numberOfChannels;

@end
