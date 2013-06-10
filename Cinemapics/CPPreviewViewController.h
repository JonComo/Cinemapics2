//
//  CPPreviewViewController.h
//  Cinemapics
//
//  Created by Jon Como on 6/9/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPCaptureSession.h"

@interface CPPreviewViewController : UIViewController

@property (nonatomic, weak) CPCaptureSession *captureSession;

@end