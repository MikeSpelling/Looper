//
//  DMEnvironment.h
//  Looper
//
//  Created by Michael Spelling on 07/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMEnvironment : NSObject

+(DMEnvironment*)sharedInstance;

@property (nonatomic, strong, readonly) NSString *baseFilePath;

@end
