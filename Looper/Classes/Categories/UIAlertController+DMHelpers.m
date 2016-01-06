//
//  UIAlertController+DMHelpers.m
//  Looper
//
//  Created by Michael Spelling on 06/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import "UIAlertController+DMHelpers.h"

@implementation UIAlertController (DMHelpers)

+(void)dm_presentAlertFrom:(UIViewController*)viewController
                     title:(NSString*)title
                   message:(NSString*)message
               cancelTitle:(NSString*)cancelTitle
               cancelBlock:(void (^)(void))cancelBlock
                otherTitle:(NSString*)otherTitle
                otherBlock:(void (^)(void))otherBlock
                otherStyle:(UIAlertActionStyle)otherStyle
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherTitle
                                                          style:otherStyle
                                                        handler:^(UIAlertAction *action) {
                                                            if (otherBlock) {
                                                                otherBlock();
                                                            }
                                                        }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             if (cancelBlock) {
                                                                 cancelBlock();
                                                             }
                                                         }];
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    [viewController presentViewController:alertController animated:YES completion:nil];
}

@end
