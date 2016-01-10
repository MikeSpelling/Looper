//
//  DMRecorder.h
//  Looper
//
//  Created by Michael Spelling on 10/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMBaseTrack.h"

@protocol DMRecorderDelegate <NSObject>
-(void)updateRecordPosition:(CGFloat)position;
@end

@interface DMRecorder : NSObject

-(instancetype)initWithRecordDelgate:(id<DMRecorderDelegate>)recordDelegate;

-(DMBaseTrack*)recordBaseTrackWithDelegate:(id<DMBaseTrackDelegate>)delegate;
-(DMTrack*)recordNewTrackAt:(CGFloat)offset;
-(void)stopRecording;

@property (nonatomic, strong, readonly) DMTrack *recordingTrack;

@end
