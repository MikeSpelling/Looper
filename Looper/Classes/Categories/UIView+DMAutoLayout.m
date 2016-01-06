//
//  UIView+DMAutoLayout.m
//  Looper
//
//  Created by Michael Spelling on 04/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "UIView+DMAutoLayout.h"

@implementation UIView (DMAutoLayout)

-(void)dm_addExpandingSubview:(UIView *)subview
{
    [self dm_addExpandingSubview:subview edgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
}

-(void)dm_addExpandingSubview:(UIView *)subview edgeInsets:(UIEdgeInsets)insets
{
    if (subview.superview) {
        [subview removeFromSuperview];
    }
    
    [self addSubview:subview];
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(subview);
    
    NSString *verticalConstraints = [NSString stringWithFormat:@"V:|-%f-[subview]-%f-|", insets.top, insets.bottom];
    NSString *horizontalConstraints = [NSString stringWithFormat:@"H:|-%f-[subview]-%f-|", insets.left, insets.right];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalConstraints
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:horizontalConstraints
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
}

+(UIView*)dm_viewWithStackedSubviews:(NSArray *)subviews vertically:(BOOL)stackVertically
{
    UIView *containerView = [UIView new];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView dm_insertStackedSubviews:subviews vertically:stackVertically];
    return containerView;
}

-(void)dm_insertStackedSubviews:(NSArray *)subviews vertically:(BOOL)stackVertically
{
    NSMutableArray *constraints = [NSMutableArray new];
    
    if (subviews.count > 1)
    {
        NSString *direction1 = stackVertically ? @"V" : @"H";
        NSString *direction2 = stackVertically ? @"H" : @"V";
        for (int count=0; count<subviews.count; count++) {
            UIView *subview = subviews[count];
            
            if (subview.superview) {
                [subview removeFromSuperview];
            }
            [self addSubview:subview];
            subview.translatesAutoresizingMaskIntoConstraints = NO;
            
            if (subview == subviews.firstObject) {
                UIView *nextSubview = subviews[count+1];
                [constraints addObject:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"%@:|[subview][nextSubview]", direction1]
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:@{@"subview":subview, @"nextSubview":nextSubview}]];
            } else if (subview == subviews.lastObject) {
                [constraints addObject:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"%@:[subview]|", direction1]
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:@{@"subview":subview}]];
            } else {
                UIView *nextSubview = subviews[count+1];
                [constraints addObject:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"%@:[subview][nextSubview]", direction1]
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:@{@"subview":subview, @"nextSubview":nextSubview}]];
            }
            
            
            [constraints addObject:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"%@:|[subview]|", direction2]
                                                                           options:0
                                                                           metrics:nil
                                                                             views:@{@"subview":subview}]];
        }
    }
    
    for (NSArray *constraint in constraints) {
        [self addConstraints:constraint];
    }
}

-(void)dm_addPinnedToTopAndSidesSubview:(UIView *)subview
{
    if (subview.superview) {
        [subview removeFromSuperview];
    }
    
    [self addSubview:subview];
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(subview);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subview]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subview]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
}

-(void)dm_addWidthConstraint:(CGFloat)width toView:(UIView*)view
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:width]];
}

-(void)dm_addHeightConstraint:(CGFloat)height toView:(UIView*)view
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:height]];
}

@end
