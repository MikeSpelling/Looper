//
//  DMTracksViewController.m
//  Looper
//
//  Created by Michael Spelling on 05/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMTracksViewController.h"
#import "DMLooperService.h"
#import "UIViewController+DMHelpers.h"

@interface DMTracksViewController ()
@property (nonatomic, strong) DMLooperService *looperService;
@property (nonatomic, strong) DMLooper *looper;

@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UIButton *pauseButton;
@property (nonatomic, weak) IBOutlet UIButton *stopButton;
@property (nonatomic, weak) IBOutlet UIButton *finishRecordingButton;
@property (nonatomic, weak) IBOutlet UIButton *startRecordingButton;
@property (nonatomic, weak) IBOutlet UIButton *nextRecordingButton;
@end


@implementation DMTracksViewController

-(instancetype)initWithLooper:(DMLooper*)looper
{
    if (self = [super initWithNibName:@"DMTracksView" bundle:nil]) {
        _looperService = [DMLooperService sharedInstance];
        _looper = looper;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.playButton.alpha = self.looper ? 1 : 0;
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

-(void)saveLooperWithTitle:(NSString*)title
{
    NSString *originalTitle = self.looper.title;
    self.looper.title = title;
    
    DMLooper *savedLooper = [self.looperService looperWithTitle:title];
    if (savedLooper && ![savedLooper isEqualToLooper:self.looper]) {
        __weak typeof (self)weakSelf = self;
        [self dm_presentAlertWithTitle:[NSString stringWithFormat:@"Overwriting %@", title]
                               message:@"Are you sure you want to continue?"
                           cancelTitle:@"No"
                           cancelBlock:^{
                               weakSelf.looper.title = originalTitle;
                           }
                            otherTitle:@"Yes"
                            otherBlock:^{
                                [weakSelf.looperService saveLooper:weakSelf.looper];
                            }
                            otherStyle:UIAlertActionStyleDefault];
    }
    else {
        [self.looperService saveLooper:self.looper];
    }
}

-(BOOL)hasUnsavedChanges
{
    DMLooper *savedLooper = [self.looperService looperWithTitle:self.looper.title];
    if (savedLooper) {
        return ![savedLooper isEqualToLooper:self.looper];
    }
    return [self.looper tracks].count>0;
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
    [self.looper stopRecording];
    
    self.playButton.alpha = 0;
    self.pauseButton.alpha = 1;
    self.stopButton.alpha = 1;
    
    self.startRecordingButton.alpha = 1;
    self.finishRecordingButton.alpha = 0;
    self.nextRecordingButton.alpha = 0;
}

-(IBAction)startRecordingTapped
{
    [self.looper startRecording];
    
    self.startRecordingButton.alpha = 0;
    self.finishRecordingButton.alpha = 1;
    self.nextRecordingButton.alpha = 1;
}

-(IBAction)nextRecordingTapped
{
    [self.looper stopRecording];
    [self.looper startRecording];
    
    self.playButton.alpha = 1;
    self.pauseButton.alpha = 0;
    self.stopButton.alpha = 0;
    
    self.startRecordingButton.alpha = 0;
    self.finishRecordingButton.alpha = 1;
    self.nextRecordingButton.alpha = 1;
}

@end
