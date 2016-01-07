//
//  DMFileRepository.h
//  Looper
//
//  Created by Michael Spelling on 07/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMFileRepository : NSObject

+(DMFileRepository*)sharedInstance;

-(NSArray*)files;
-(void)deleteFileNamed:(NSString*)filename;

@property (nonatomic, strong, readonly) NSString *baseFilePath;

@end
