//
//  DMTrackCell.h
//  Looper
//
//  Created by Michael Spelling on 07/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMTrack.h"

extern NSString *const DMTrackCellKey;

@interface DMTrackCell : UICollectionViewCell

-(void)updateForTrack:(DMTrack*)track
          currentTime:(NSTimeInterval)currentTime
          deleteBlock:(void (^)())deleteBlock;

-(void)updateForTime:(NSTimeInterval)time;

@end
