//
//  UIView+DMAutoLayout.h
//  Looper
//
//  Created by Michael Spelling on 04/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (IRAutoLayout)
+(UIView*)dm_viewWithStackedSubviews:(NSArray *)subviews vertically:(BOOL)stackVertically;

-(void)dm_addExpandingSubview:(UIView *)subview;
-(void)dm_addExpandingSubview:(UIView *)subview edgeInsets:(UIEdgeInsets)insets;
-(void)dm_addPinnedToTopAndSidesSubview:(UIView *)subview;
-(void)dm_addWidthConstraint:(CGFloat)width toView:(UIView*)view;
-(void)dm_addHeightConstraint:(CGFloat)height toView:(UIView*)view;
-(void)dm_insertStackedSubviews:(NSArray *)subviews vertically:(BOOL)stackVertically;
@end
