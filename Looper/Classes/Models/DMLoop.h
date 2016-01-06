//
//  DMLoop.h
//  Looper
//
//  Created by Michael Spelling on 05/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMLoop : NSObject <NSCoding>

-(instancetype)initWithTitle:(NSString*)title channels:(NSArray*)channels;
-(BOOL)isEqualToLoop:(id)loop;
-(void)deleteFiles;

@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSMutableArray *channels;

@end
