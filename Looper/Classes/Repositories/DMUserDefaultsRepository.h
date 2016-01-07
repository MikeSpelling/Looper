//
//  DMUserDefaultsRepository.h
//  Looper
//
//  Created by Michael Spelling on 06/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMUserDefaultsRepository : NSObject

+(DMUserDefaultsRepository*)sharedInstance;

-(void)saveLoopers:(NSArray*)loopers;
-(NSArray*)loopers;

@end
