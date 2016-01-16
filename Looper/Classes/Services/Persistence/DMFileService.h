//
//  DMFileService.h
//  Looper
//
//  Created by Michael Spelling on 07/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMFileService : NSObject

+(DMFileService*)sharedInstance;

-(void)deleteFileNamed:(NSString*)filename;
-(void)deleteUnsavedFiles;

@end
