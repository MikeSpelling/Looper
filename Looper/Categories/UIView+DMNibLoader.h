//
//  UIView+DMNibLoader.h
//  Looper
//
//  Created by Michael Spelling on 04/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (DMNibLoader)

-(instancetype)dm_initFromNib;
-(void)dm_addExpandingNibNamed:(NSString*)nibName;
-(void)dm_addExpandingNib;

@end
