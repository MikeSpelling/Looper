//
//  DMFileRepository.m
//  Looper
//
//  Created by Michael Spelling on 07/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMFileRepository.h"
#import "DMEnvironment.h"

@interface DMFileRepository()
@property (nonatomic, strong) DMEnvironment *environment;
@end

@implementation DMFileRepository

+(DMFileRepository*)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[DMFileRepository alloc] init];
    });
    return sharedInstance;
}

-(instancetype)init
{
    if (self = [super init]) {
        _environment = [DMEnvironment sharedInstance];
    }
    return self;
}

-(NSArray*)files
{
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.environment.baseFilePath error:nil];
}

-(void)deleteFileNamed:(NSString*)filename
{
    NSURL *url = [NSURL fileURLWithPathComponents:@[self.environment.baseFilePath, filename]];
    [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
}

@end
