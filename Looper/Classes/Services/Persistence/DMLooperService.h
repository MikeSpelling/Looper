//
//  DMLooperService.h
//  Looper
//
//  Created by Michael Spelling on 06/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMLooper.h"

@interface DMLooperService : NSObject

+(DMLooperService*)sharedInstance;

-(void)saveLooper:(DMLooper*)looper;
-(void)deleteLooper:(DMLooper*)looper;
-(NSArray*)loopers;
-(DMLooper*)looperWithTitle:(NSString*)title;

@end
