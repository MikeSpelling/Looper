//
//  DMLoop.m
//  Looper
//
//  Created by Michael Spelling on 05/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMLoop.h"
#import "DMChannel.h"

NSString *const DMLoopTitleCodingKey = @"DMLoopTitleCodingKey";
NSString *const DMLoopChannelsCodingKey = @"DMLoopChannelsCodingKey";

@implementation DMLoop

-(instancetype)initWithTitle:(NSString*)title channels:(NSMutableArray*)channels
{
    if (self = [super init]) {
        _title = title;
        _channels = channels;
    }
    return self;
}

-(void)deleteFiles
{
    for (DMChannel *channel in self.channels) {
        [channel deleteFile];
    }
}

-(BOOL)isEqualToLoop:(id)loop
{
    if ([loop isKindOfClass:[DMLoop class]]) {
        DMLoop *castLoop = loop;
        BOOL titlesEqual = [castLoop.title isEqualToString:self.title];
        BOOL channelsEqual = [castLoop.channels isEqualToArray:self.channels];
        return titlesEqual && channelsEqual;
    }
    return NO;
}


#pragma mark - NSCoding

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.title forKey:DMLoopTitleCodingKey];
    [encoder encodeObject:self.channels forKey:DMLoopChannelsCodingKey];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        _title = [decoder decodeObjectForKey:DMLoopTitleCodingKey];
        _channels = [decoder decodeObjectForKey:DMLoopChannelsCodingKey];
    }
    return self;
}

@end
