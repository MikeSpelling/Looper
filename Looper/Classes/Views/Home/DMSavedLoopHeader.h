//
//  DMSavedLoopHeader.h
//  Looper
//
//  Created by Michael Spelling on 05/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const DMSavedLoopHeaderKey;

@interface DMSavedLoopHeader : UICollectionReusableView

@property (nonatomic, copy) void(^tapHandler)();

@end
