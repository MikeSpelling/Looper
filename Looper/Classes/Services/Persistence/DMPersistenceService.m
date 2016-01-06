//
//  DMPersistenceService.m
//  Looper
//
//  Created by Michael Spelling on 06/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMPersistenceService.h"

NSString *const DMPersistenceServiceLoopsKey = @"DMPersistenceServiceLoopsKey";

@interface DMPersistenceService()
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@end


@implementation DMPersistenceService

+(DMPersistenceService*)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    
    dispatch_once(&once, ^{
        sharedInstance = [[DMPersistenceService alloc] init];
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

-(void)saveLoop:(DMLoop*)loop
{
    if (loop.title) {
        NSMutableArray *loops = [[self loops] mutableCopy];
        for (DMLoop *savedLoop in loops) {
            if ([savedLoop.title isEqualToString:loop.title]) {
                [loops removeObject:savedLoop];
                break;
            }
        }
        [loops addObject:loop];
        
        [self.userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:loops] forKey:DMPersistenceServiceLoopsKey];
        [self.userDefaults synchronize];
    }
}

-(void)deleteLoop:(DMLoop*)loop
{
    if (loop.title) {
        NSMutableArray *loops = [[self loops] mutableCopy];
        for (DMLoop *savedLoop in loops) {
            if ([savedLoop.title isEqualToString:loop.title]) {
                [loops removeObject:savedLoop];
                [self.userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:loops] forKey:DMPersistenceServiceLoopsKey];
                [self.userDefaults synchronize];
                return;
            }
        }
    }
}

-(NSArray*)loops
{
    NSArray *loops = [NSArray new];
    NSData *loopsData = [self.userDefaults objectForKey:DMPersistenceServiceLoopsKey];
    if (loopsData) {
        loops = [NSKeyedUnarchiver unarchiveObjectWithData:loopsData];
    }
    return loops;
}

-(DMLoop*)loopWithTitle:(NSString*)title
{
    for (DMLoop *loop in [self loops]) {
        if ([loop.title isEqualToString:title]) {
            return loop;
        }
    }
    return nil;
}

@end
