//
//  DMChannel.m
//  Looper
//
//  Created by Michael Spelling on 14/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMChannel.h"

@interface DMChannel()
@property (nonatomic, assign) AEAudioRenderCallback filePlayerRenderCallback;
@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, assign) CGFloat loopDuration;
@end


@implementation DMChannel

- (instancetype)initWithURL:(NSURL *)url error:(NSError **)error offset:(CGFloat)offset loopDuration:(CGFloat)loopDuration
{
    if (self = [super initWithURL:url error:error]) {
        _filePlayerRenderCallback = [super renderCallback];
    }
    return self;
}

#pragma mark - AEAudioRenderCallback

-(AEAudioRenderCallback)renderCallback
{
    return renderCallback;
}

//struct AudioTimeStamp
//{
//    Float64             mSampleTime;
//    UInt64              mHostTime;
//    Float64             mRateScalar;
//    UInt64              mWordClockTime;
//    SMPTETime           mSMPTETime;
//    AudioTimeStampFlags mFlags;
//    UInt32              mReserved;
//};

//struct SMPTETime
//{
//    SInt16          mSubframes;
//    SInt16          mSubframeDivisor;
//    UInt32          mCounter;
//    SMPTETimeType   mType;
//    SMPTETimeFlags  mFlags;
//    SInt16          mHours;
//    SInt16          mMinutes;
//    SInt16          mSeconds;
//    SInt16          mFrames;
//};

static OSStatus renderCallback(__unsafe_unretained DMChannel            *THIS,
                               __unsafe_unretained AEAudioController    *audioController,
                               const AudioTimeStamp                     *time,
                               UInt32                                   frames,
                               AudioBufferList                          *audio)
{
    // Render
    return THIS->_filePlayerRenderCallback(THIS, audioController, time, frames, audio);
    
    // Examine playhead
//    int32_t playhead = THIS->_playhead;
//    int32_t originalPlayhead = THIS->_playhead;
//    
//    double sourceToOutputSampleRateScale = THIS->_unitOutputDescription.mSampleRate / THIS->_fileDescription.mSampleRate;
//    UInt32 lengthInFrames = ceil(THIS->_lengthInFrames * sourceToOutputSampleRateScale);
//    
//    if ( playhead + frames >= lengthInFrames && !THIS->_loop ) {
//    NSLog(@"%f %f", THIS.currentTime, THIS.duration);
//    return THIS->_superRenderCallback(THIS, audioController, time, frames, audio);
}

//static void timeUpdated(void *userInfo, int userInfoLength)
//{
//    DMAudioController *audioController = (__bridge_transfer id)*(void **)userInfo;
//    if (audioController.playbackPosition != audioController.basePlayer.currentTime) {
//        if (audioController.basePlayer.currentTime < audioController.playbackPosition) {
//            [audioController baseTrackLooped];
//        }
//        audioController.playbackPosition = audioController.basePlayer.currentTime;
//        [audioController baseTrackPositionUpdated];
//    }
//}
//
//-(void)baseTrackLooped
//{
//    NSLog(@"LOOP %f on %@", self.playbackPosition, [NSThread currentThread]);
//}
//
//-(void)baseTrackPositionUpdated
//{
//    NSLog(@"%f %@", self.playbackPosition, [NSThread currentThread]);
//}

@end
