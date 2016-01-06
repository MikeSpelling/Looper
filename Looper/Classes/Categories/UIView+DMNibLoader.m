//
//  UIView+DMNibLoader.m
//  Looper
//
//  Created by Michael Spelling on 04/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "UIView+DMNibLoader.h"
#import "UIView+DMAutoLayout.h"

@implementation UIView (DMNibLoader)

-(instancetype)dm_initFromNib
{
    return [self viewForNibNamed:NSStringFromClass([self class])];
}

-(void)dm_addExpandingNib
{
    [self dm_addExpandingNibNamed:NSStringFromClass([self class])];
}

-(void)dm_addExpandingNibNamed:(NSString*)nibName
{
    UIView *subview = [self viewForNibNamed:nibName];
    [self dm_addExpandingSubview:subview];
}


#pragma mark - Internal

-(UIView*)viewForNibNamed:(NSString*)nibName
{
    return [[[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil] objectAtIndex:0];
}

@end
