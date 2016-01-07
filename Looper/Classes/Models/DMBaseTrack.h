//
//  DMBaseTrack.h
//  Looper
//
//  Created by Michael Spelling on 06/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMTrack.h"

@protocol DMBaseTrackDelegate <NSObject>
-(void)baseTrackDidLoop;
-(void)baseTrackUpdatePosition:(CGFloat)position;
@end

@interface DMBaseTrack : DMTrack

-(instancetype)initWithDelegate:(id<DMBaseTrackDelegate>)delegate;
@property (nonatomic, weak) id<DMBaseTrackDelegate> delegate;

@end
