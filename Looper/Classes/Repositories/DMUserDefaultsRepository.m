//
//  DMUserDefaultsRepository.m
//  Looper
//
//  Created by Michael Spelling on 06/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMUserDefaultsRepository.h"

NSString *const DMUserDefaultsRepositoryLoopersKey = @"DMUserDefaultsRepositoryLoopersKey";

@interface DMUserDefaultsRepository()
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@end


@implementation DMUserDefaultsRepository

+(DMUserDefaultsRepository*)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[DMUserDefaultsRepository alloc] init];
    });
    return sharedInstance;
}

-(instancetype)init
{
    if (self = [super init]) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

-(void)saveLoopers:(NSArray*)loopers
{
    [self.userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:loopers] forKey:DMUserDefaultsRepositoryLoopersKey];
    [self.userDefaults synchronize];
}

-(NSArray*)loopers
{
    NSArray *loopers = [NSArray new];
    NSData *loopersData = [self.userDefaults objectForKey:DMUserDefaultsRepositoryLoopersKey];
    if (loopersData) {
        loopers = [NSKeyedUnarchiver unarchiveObjectWithData:loopersData];
    }
    return loopers;
}

@end
