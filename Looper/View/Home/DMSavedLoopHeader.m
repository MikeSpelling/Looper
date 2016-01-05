//
//  DMSavedLoopHeader.m
//  Looper
//
//  Created by Michael Spelling on 05/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMSavedLoopHeader.h"

NSString *const DMSavedLoopHeaderKey = @"DMSavedLoopHeader";

@interface DMSavedLoopHeader()
@property (nonatomic, weak) IBOutlet UIButton *button;
@end

@implementation DMSavedLoopHeader

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.button addTarget:self action:@selector(addHitState) forControlEvents:UIControlEventTouchDown|UIControlEventTouchDragEnter];
    [self.button addTarget:self action:@selector(removeHitState) forControlEvents:UIControlEventTouchDragExit|UIControlEventTouchUpInside|UIControlEventTouchCancel];
}


#pragma mark - Actions

-(IBAction)headerTapped
{
    if (self.tapHandler) {
        self.tapHandler();
    }
}


#pragma mark - Hit states

-(void)addHitState
{
    self.alpha = 0.5;
}

-(void)removeHitState
{
    __weak typeof (self)weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.alpha = 1;
    }];
}

@end
