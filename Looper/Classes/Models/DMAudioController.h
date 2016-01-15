//
//  DMAudioController.h
//  Looper
//
//  Created by Michael Spelling on 12/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMAudioController : NSObject

-(instancetype)initWithTracks:(NSArray*)tracks;
-(void)tearDown;

-(void)toggleRecord;

@end
