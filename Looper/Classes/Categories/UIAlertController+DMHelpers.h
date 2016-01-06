//
//  UIAlertController+DMHelpers.h
//  Looper
//
//  Created by Michael Spelling on 06/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (DMHelpers)

+(void)dm_presentAlertFrom:(UIViewController*)viewController
                     title:(NSString*)title
                   message:(NSString*)message
               cancelTitle:(NSString*)cancelTitle
               cancelBlock:(void (^)(void))cancelBlock
                otherTitle:(NSString*)otherTitle
                otherBlock:(void (^)(void))otherBlock
                otherStyle:(UIAlertActionStyle)otherStyle;

@end
