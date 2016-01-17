//
//  DMRecorder.h
//  Looper
//
//  Created by Michael Spelling on 10/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMTrack.h"

@protocol DMRecorderDelegate <NSObject>
-(void)updateRecordPosition:(NSTimeInterval)position;
-(void)baseTrackRecorded:(DMTrack*)track;
-(void)trackRecorded:(DMTrack*)track;
@end

@interface DMRecorder : NSObject

-(instancetype)initWithRecordDelgate:(id<DMRecorderDelegate>)recordDelegate;

-(void)recordBaseTrack:(id<DMBaseTrackDelegate>)delegate;
-(void)startRecordingNextTrack;
-(void)stopRecording;
-(void)saveRecordings;
-(void)tearDown;

-(NSTimeInterval)recordPosition;

@property (nonatomic, strong, readonly) DMTrack *recordingTrack;

@end
