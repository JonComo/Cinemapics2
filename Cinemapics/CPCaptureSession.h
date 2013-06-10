//
//  CPCaptureSession.h
//  Cinemapics
//
//  Created by Jon Como on 6/9/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ImageCapturedBlock)(UIImage *image, float progress);

@class GPUImageView;

@interface CPCaptureSession : NSObject

@property (nonatomic, strong) NSMutableArray *images;
@property float duration, frameRate;

-(id)initWithFrameRate:(float)fps duration:(float)dur preview:(GPUImageView *)preview;

-(void)beginCaptureWithCompletion:(ImageCapturedBlock)block;
-(void)endCapture;

-(void)startCamera;
-(void)stopCamera;

@end
