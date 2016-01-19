//
//  DMLooperViewController.m
//  Looper
//
//  Created by Michael Spelling on 04/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMLooperViewController.h"
#import "DMTracksViewController.h"
#import "UIViewController+DMHelpers.h"

@interface DMLooperViewController() <UITextFieldDelegate>
@property (nonatomic, strong) DMLooper *looper;

@property (nonatomic, strong) DMTracksViewController *tracksViewController;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *keyboardDismissButton;
@end


@implementation DMLooperViewController

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

-(instancetype)withLooper:(DMLooper*)looper
{
    _looper = looper;
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.looper setupForRecording];
    self.tracksViewController = [[DMTracksViewController alloc] initWithLooper:self.looper];
    [self dm_addExpandingChildViewController:self.tracksViewController toView:self.containerView];
    
    self.titleLabel.text = self.looper.title ? self.looper.title : @"Loop1";
    self.titleTextField.text = self.titleLabel.text;
    self.titleTextField.alpha = 0;
    self.keyboardDismissButton.alpha = 0;
}


#pragma mark - Actions

-(IBAction)closeTapped
{
    if ([self.tracksViewController hasUnsavedChanges]) {
        __weak typeof (self)weakSelf = self;
        [self dm_presentAlertWithTitle:@"Cancelling"
                               message:@"All changes will be lost.\nAre you sure you want to continue?"
                           cancelTitle:@"No"
                           cancelBlock:nil
                            otherTitle:@"Yes"
                            otherBlock:^{
                                [weakSelf dismissViewControllerAnimated:YES completion:nil];
                            }
                            otherStyle:UIAlertActionStyleDestructive];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(IBAction)saveTapped
{
    [self.tracksViewController saveLooperWithTitle:self.titleLabel.text];
}

-(IBAction)titleTapped
{
    self.titleLabel.alpha = 0;
    self.titleTextField.alpha = 1;
    self.keyboardDismissButton.alpha = 1;
    
    [self.titleTextField becomeFirstResponder];
}

-(IBAction)dismissKeyboard
{
    [self.titleTextField resignFirstResponder];
}

-(IBAction)textFieldEdited
{
    self.titleLabel.text = self.titleTextField.text;
}


#pragma mark - Notifications

-(void)keyboardWillHide
{
    self.keyboardDismissButton.alpha = 0;
    self.titleLabel.alpha = 1;
    self.titleTextField.alpha = 0;
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

@end
