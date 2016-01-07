//
//  DMLooper.h
//  Looper
//
//  Created by Michael Spelling on 04/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMLooper : NSObject

@property (nonatomic, strong) NSString *title;

-(void)startRecording;
-(void)stopRecording;

-(void)play;
-(void)stopPlayback;
-(void)pausePlayback;

-(void)saveLooper;
-(NSArray*)tracks;

-(BOOL)isEqualToLooper:(id)object;

@end
