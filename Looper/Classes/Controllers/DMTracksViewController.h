//
//  DMTracksViewController.h
//  Looper
//
//  Created by Michael Spelling on 05/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMLooper.h"

@interface DMTracksViewController : UIViewController

-(instancetype)initWithLooper:(DMLooper*)looper;

-(void)saveLooperWithTitle:(NSString*)title;
-(BOOL)hasUnsavedChanges;

@end
