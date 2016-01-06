//
//  DMPersistenceService.h
//  Looper
//
//  Created by Michael Spelling on 06/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DMLoop.h"

@interface DMPersistenceService : NSObject

+(DMPersistenceService*)sharedInstance;

-(void)saveLoop:(DMLoop*)loop;
-(NSArray*)loops;
-(DMLoop*)loopWithTitle:(NSString*)title;

@end
