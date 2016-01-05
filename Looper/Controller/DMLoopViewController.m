//
//  DMLoopViewController.m
//  Looper
//
//  Created by Michael Spelling on 04/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMLoopViewController.h"
#import "DMLooper.h"

@interface DMLoopViewController()
@property (nonatomic, strong) DMLooper *looper;

@property (weak, nonatomic) IBOutlet UIButton *loopButton;
@property (weak, nonatomic) IBOutlet UIButton *stopPlaybackButton;
@end


@implementation DMLoopViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.looper = [DMLooper new];
}


#pragma mark - Actions

-(IBAction)loopTapped
{
    if (!self.looper.isRecording) {
        [self.looper recordNewLoop];
    }
    else {
        [self.looper stopRecordingLoop];
    }
}

-(IBAction)stopPlaybackTapped
{
    [self.looper stopAllPlayback];
}

@end
