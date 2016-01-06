//
//  DMSavedLoopCell.h
//  Looper
//
//  Created by Michael Spelling on 05/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const DMSavedLoopCellKey;

@interface DMSavedLoopCell : UICollectionViewCell

@property (nonatomic, copy) void(^deleteBlock)();

@property (nonatomic, weak) IBOutlet UILabel *label;

@end
