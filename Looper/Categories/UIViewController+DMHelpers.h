//
//  UIViewController+DMHelpers.h
//  Looper
//
//  Created by Michael Spelling on 04/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (DMHelpers)

-(void)dm_addChildViewController:(UIViewController*)childViewController;
-(void)dm_addChildViewController:(UIViewController*)childViewController toView:(UIView*)view;
-(void)dm_addExpandingChildViewController:(UIViewController*)childViewController;
-(void)dm_addExpandingChildViewController:(UIViewController*)childViewController toView:(UIView*)view;
-(void)dm_removeChildViewController:(UIViewController*)childViewController;

+(instancetype)dm_instantiateFromStoryboard;

@end
