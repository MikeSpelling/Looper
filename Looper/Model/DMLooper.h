//
//  DMLooper.h
//  Looper
//
//  Created by Michael Spelling on 04/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMLooper : NSObject

-(void)recordNewLoop;
-(void)stopRecordingLoopAndPlay;
-(void)stopAllPlayback;
-(BOOL)isRecording;

@end
