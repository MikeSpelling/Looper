//
//  DMLooper.h
//  Looper
//
//  Created by Michael Spelling on 04/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMBaseTrack.h"
#import "DMTrack.h"

@interface DMLooper : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) DMTrack *recordingTrack;
@property (nonatomic, strong) DMBaseTrack *baseTrack;
@property (nonatomic, strong) NSMutableArray *extraTracks;

-(void)startRecording;
-(void)stopRecording;

-(void)play;
-(void)stopPlayback;

-(NSArray*)recordedTracks;
-(NSArray*)allTracks;

-(void)tearDown;

-(BOOL)isEqualToLooper:(id)object;

@end
