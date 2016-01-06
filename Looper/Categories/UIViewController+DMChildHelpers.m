//
//  UIViewController+DMChildHelpers.m
//  Looper
//
//  Created by Michael Spelling on 04/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "UIViewController+DMChildHelpers.h"
#import "UIView+DMAutoLayout.h"

@implementation UIViewController (DMChildHelpers)

-(void)dm_addChildViewController:(UIViewController*)childViewController
{
    [self dm_addChildViewController:childViewController toView:self.view];
}

-(void)dm_addChildViewController:(UIViewController*)childViewController toView:(UIView*)view
{
    [self addChildViewController:childViewController];
    childViewController.view.frame = view.bounds;
    [view addSubview:childViewController.view];
    [childViewController didMoveToParentViewController:self];
}

-(void)dm_addExpandingChildViewController:(UIViewController*)childViewController
{
    [self dm_addExpandingChildViewController:childViewController toView:self.view];
}

-(void)dm_addExpandingChildViewController:(UIViewController*)childViewController toView:(UIView*)view
{
    [self addChildViewController:childViewController];
    [view dm_addExpandingSubview:childViewController.view];
    [childViewController didMoveToParentViewController:self];
}

-(void)dm_removeChildViewController:(UIViewController*)childViewController
{
    [childViewController willMoveToParentViewController:nil];
    [childViewController.view removeFromSuperview];
    [childViewController removeFromParentViewController];
}

@end
