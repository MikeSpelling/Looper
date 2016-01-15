//
//  DMChannel.h
//  Looper
//
//  Created by Michael Spelling on 14/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <TheAmazingAudioEngine/TheAmazingAudioEngine.h>
#import <UIKit/UIKit.h>

@interface DMChannel : AEAudioFilePlayer

- (instancetype)initWithURL:(NSURL *)url error:(NSError **)error offset:(CGFloat)offset loopDuration:(CGFloat)loopDuration;

@end
