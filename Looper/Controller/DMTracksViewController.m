//
//  DMTracksViewController.m
//  Looper
//
//  Created by Michael Spelling on 05/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMTracksViewController.h"
#import "DMLooper.h"
#import "DMPersistenceService.h"

@interface DMTracksViewController ()
@property (nonatomic, strong) DMLooper *looper;

@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UIButton *pauseButton;
@property (nonatomic, weak) IBOutlet UIButton *stopButton;
@property (nonatomic, weak) IBOutlet UIButton *finishRecordingButton;
@property (nonatomic, weak) IBOutlet UIButton *startRecordingButton;
@property (nonatomic, weak) IBOutlet UIButton *nextRecordingButton;
@end


@implementation DMTracksViewController

-(instancetype)initWithLoop:(DMLoop*)loop
{
    if (self = [super initWithNibName:@"DMTracksView" bundle:nil]) {
        self.looper = [[DMLooper alloc] initWithLoop:loop];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.playButton.alpha = 0;
    self.pauseButton.alpha = 0;
    self.stopButton.alpha = 0;
    self.startRecordingButton.alpha = 1;
    self.finishRecordingButton.alpha = 0;
    self.nextRecordingButton.alpha = 0;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.looper stopPlayback];
}


#pragma mark - DMTracksViewController

-(void)saveLoopNamed:(NSString*)title
{
    DMLoop *loop = [[DMLoop alloc] initWithTitle:title channels:[self.looper channels]];
    [[DMPersistenceService sharedInstance] saveLoop:loop];
}


#pragma mark - Actions

-(IBAction)playTapped
{
    [self.looper play];
    
    self.playButton.alpha = 0;
    self.pauseButton.alpha = 1;
    self.stopButton.alpha = 1;
}

-(IBAction)pauseTapped
{
    [self.looper pausePlayback];
    
    self.playButton.alpha = 1;
    self.pauseButton.alpha = 0;
    self.stopButton.alpha = 0;
}

-(IBAction)stopTapped
{
    [self.looper stopPlayback];
    
    self.playButton.alpha = 1;
    self.pauseButton.alpha = 0;
    self.stopButton.alpha = 0;
}

-(IBAction)finishRecordingTapped
{
    [self.looper stopRecordingLoop];
    
    self.playButton.alpha = 0;
    self.pauseButton.alpha = 1;
    self.stopButton.alpha = 1;
    
    self.startRecordingButton.alpha = 1;
    self.finishRecordingButton.alpha = 0;
    self.nextRecordingButton.alpha = 0;
}

-(IBAction)startRecordingTapped
{
    [self.looper recordNewLoop];
    
    self.startRecordingButton.alpha = 0;
    self.finishRecordingButton.alpha = 1;
    self.nextRecordingButton.alpha = 1;
}

-(IBAction)nextRecordingTapped
{
    [self.looper stopRecordingLoop];
    [self.looper recordNewLoop];
    
    self.playButton.alpha = 1;
    self.pauseButton.alpha = 0;
    self.stopButton.alpha = 0;
    
    self.startRecordingButton.alpha = 0;
    self.finishRecordingButton.alpha = 1;
    self.nextRecordingButton.alpha = 1;
}

@end
