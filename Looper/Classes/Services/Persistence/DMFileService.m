//
//  DMFileService.m
//  Looper
//
//  Created by Michael Spelling on 07/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMFileService.h"
#import "DMLooperService.h"
#import "DMFileRepository.h"
#import "DMTrack.h"

@interface DMFileService()
@property (nonatomic, strong) DMFileRepository *fileRepository;
@end

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

-(instancetype)init
{
    if (self = [super init]) {
        _fileRepository = [DMFileRepository sharedInstance];
        _baseFilePath = _fileRepository.baseFilePath;
        NSLog(@"%@", _baseFilePath);
    }
    return self;
}

-(void)deleteUnsavedFiles
{
    NSArray *currentFiles = [self.fileRepository files];
    
    NSMutableArray *filesToKeep = [NSMutableArray new];
    for (DMLooper *looper in [[DMLooperService sharedInstance] loopers]) {
        for (DMTrack *track in [looper tracks]) {
            [filesToKeep addObject:track.filename];
        }
    }
    
    for (NSString *filename in currentFiles) {
        if (![filesToKeep containsObject:filename]) {
            [self.fileRepository deleteFileNamed:filename];
        }
    }
}

@end
