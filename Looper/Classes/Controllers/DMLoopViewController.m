//
//  DMLoopViewController.m
//  Looper
//
//  Created by Michael Spelling on 04/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMLoopViewController.h"
#import "DMTracksViewController.h"
#import "UIViewController+DMHelpers.h"
#import "DMPersistenceService.h"

@interface DMLoopViewController() <UITextFieldDelegate>
@property (nonatomic, strong) DMLoop *loop;

@property (nonatomic, strong) DMTracksViewController *tracksViewController;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *keyboardDismissButton;
@end


@implementation DMLoopViewController

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

-(instancetype)withLoop:(DMLoop*)loop
{
    _loop = loop;
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tracksViewController = [[DMTracksViewController alloc] initWithLoop:self.loop];
    [self dm_addExpandingChildViewController:self.tracksViewController toView:self.containerView];
    
    self.titleLabel.text = self.loop.title ? self.loop.title : @"Loop1";
    self.titleTextField.text = self.titleLabel.text;
    self.titleTextField.alpha = 0;
    self.keyboardDismissButton.alpha = 0;
}


#pragma mark - Actions

-(IBAction)cancelTapped
{
    if ([self.tracksViewController hasChanges]) {
        __weak typeof (self)weakSelf = self;
        [self dm_presentAlertWithTitle:@"Cancelling"
                               message:@"All changes will be lost.\nAre you sure you want to continue?"
                           cancelTitle:@"No"
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
    if ([[DMPersistenceService sharedInstance] loopWithTitle:self.titleLabel.text] &&
        [self.tracksViewController hasChanges]) {
        __weak typeof (self)weakSelf = self;
        [self dm_presentAlertWithTitle:[NSString stringWithFormat:@"Overwriting %@", self.titleLabel.text]
                               message:@"Are you sure you want to continue?"
                           cancelTitle:@"No"
                            otherTitle:@"Yes"
                            otherBlock:^{
                                [weakSelf saveAndDismiss];
                            }
                            otherStyle:UIAlertActionStyleDefault];
    }
    else {
        [self saveAndDismiss];
    }
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


#pragma mark - Internal

-(void)saveAndDismiss
{
    [self.tracksViewController saveLoopNamed:self.titleLabel.text];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
