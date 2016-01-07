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

-(void)deleteUnsavedFiles;

@property (nonatomic, strong, readonly) NSString *baseFilePath;

@end
