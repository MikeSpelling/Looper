//
//  DMLooper.h
//  Looper
//
//  Created by Michael Spelling on 04/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMTrack.h"

@protocol DMLooperDelegate <NSObject>
-(void)tracksChanged;
@end

@interface DMLooper : NSObject

@property (nonatomic, weak) id<DMLooperDelegate>delegate;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) DMTrack *baseTrack;
@property (nonatomic, strong) NSMutableArray *extraTracks;

-(void)setupForRecording;
-(void)startRecording;
-(void)stopRecording;
-(void)scheduleRecordingForNextLoop;

-(void)play;
-(void)stopPlayback;

-(NSArray*)recordedTracks;
-(NSArray*)allTracks;

-(void)saveRecordings;
-(void)deleteRecordings;
-(void)tearDown;

-(BOOL)isEqualToLooper:(id)object;

@end
