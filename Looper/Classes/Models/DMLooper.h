//
//  DMLooper.h
//  Looper
//
//  Created by Michael Spelling on 04/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMLoop.h"

@interface DMLooper : NSObject

-(instancetype)initWithLoop:(DMLoop*)loop;

-(void)recordNewLoop;
-(void)stopRecordingLoop;
-(void)stopPlayback;
-(void)pausePlayback;
-(void)play;
-(BOOL)isRecording;
-(BOOL)hasChanges;

-(void)saveLoopWithName:(NSString*)title;

@end
