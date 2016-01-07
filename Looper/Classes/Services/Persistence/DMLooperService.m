//
//  DMLooperService.m
//  Looper
//
//  Created by Michael Spelling on 06/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMLooperService.h"
#import "DMUserDefaultsRepository.h"

@interface DMLooperService()
@property (nonatomic, strong) DMUserDefaultsRepository *userDefaultsRepository;
@end


@implementation DMLooperService

+(DMLooperService*)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[DMLooperService alloc] init];
    });
    return sharedInstance;
}

-(instancetype)init
{
    if (self = [super init]) {
        _userDefaultsRepository = [DMUserDefaultsRepository sharedInstance];
    }
    return self;
}

-(void)saveLooper:(DMLooper*)looper
{
    if (looper.title) {
        [looper saveLooper];
        
        NSMutableArray *loopers = [[self loopers] mutableCopy];
        for (DMLooper *savedLooper in loopers) {
            if ([savedLooper.title isEqualToString:looper.title]) {
                [savedLooper deleteAudioFiles];
                [loopers removeObject:savedLooper];
                break;
            }
        }
        [loopers insertObject:looper atIndex:0];
        
        [self.userDefaultsRepository saveLoopers:loopers];
    }
}

-(void)deleteLooper:(DMLooper*)looper
{
    NSMutableArray *loopers = [[self loopers] mutableCopy];
    for (DMLooper *savedLooper in loopers) {
        if ([savedLooper.title isEqualToString:looper.title]) {
            [savedLooper deleteAudioFiles];
            [loopers removeObject:savedLooper];
            
            [self.userDefaultsRepository saveLoopers:loopers];
            return;
        }
    }
}

-(NSArray*)loopers
{
    return [self.userDefaultsRepository loopers];
}

-(DMLooper*)looperWithTitle:(NSString*)title
{
    for (DMLooper *looper in [self loopers]) {
        if ([looper.title isEqualToString:title]) {
            return looper;
        }
    }
    return nil;
}

@end
