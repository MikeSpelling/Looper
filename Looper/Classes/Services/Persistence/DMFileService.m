//
//  DMFileService.m
//  Looper
//
//  Created by Michael Spelling on 07/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMFileService.h"

@implementation DMFileService

+(DMFileService*)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[DMFileService alloc] init];
    });
    return sharedInstance;
}

-(void)deleteFileAtUrl:(NSURL*)url
{
    [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
}

@end
