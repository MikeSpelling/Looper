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
-(void)updateRecordPosition:(CGFloat)position;
@end

@interface DMRecorder : NSObject

-(instancetype)initWithRecordDelgate:(id<DMRecorderDelegate>)recordDelegate;

-(void)toggleRecordAt:(CGFloat)offset;
-(void)saveRecordings;
-(void)tearDown;

@property (nonatomic, strong, readonly) DMTrack *recordingTrack;

@end
