//
//  DMLoopViewController.m
//  Looper
//
//  Created by Michael Spelling on 04/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "DMLoopViewController.h"
#import "DMTracksViewController.h"
#import "UIViewController+DMChildHelpers.h"

@interface DMLoopViewController() <UITextFieldDelegate>
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

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self dm_addExpandingChildViewController:[DMTracksViewController new] toView:self.containerView];
    
    self.titleTextField.text = self.titleLabel.text;
    self.titleTextField.alpha = 0;
    self.keyboardDismissButton.alpha = 0;
}


#pragma mark - Actions

-(IBAction)cancelTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)saveTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
