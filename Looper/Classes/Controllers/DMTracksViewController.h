//
//  DMTracksViewController.h
//  Looper
//
//  Created by Michael Spelling on 05/01/2016.
//  Copyright © 2016 DM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMLoop.h"

@interface DMTracksViewController : UIViewController

-(instancetype)initWithLoop:(DMLoop*)loop;

-(void)saveLoopNamed:(NSString*)title;
-(BOOL)hasChanges;

@end
