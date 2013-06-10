//
//  CPCaptureSession.m
//  Cinemapics
//
//  Created by Jon Como on 6/9/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "CPCaptureSession.h"
#import "GPUImage.h"
#import "Macros.h"
#import <ImageIO/ImageIO.h>

@implementation CPCaptureSession
{
    GPUImageVideoCamera *videoCamera;
    GPUImageCropFilter *filter;
    NSTimer *captureTimer;
    
    ImageCapturedBlock imageCapturedBlock;
}

-(id)initWithFrameRate:(float)fps duration:(float)dur preview:(GPUImageView *)preview
{
    if (self = [super init]) {
        //init
        _frameRate = fps;
        _duration = dur;
        
        _images = [NSMutableArray array];
        
        videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
        videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        
        filter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0, 1, 480.0/640.0)];
        [videoCamera addTarget:filter];
        
        __weak GPUImageView *previewView = preview;
        
        if (previewView)
            [filter addTarget:previewView];
    }
    
    return self;
}

-(void)startCamera
{
    [videoCamera startCameraCapture];
}

-(void)stopCamera
{
    [videoCamera stopCameraCapture];
}

-(void)setPreviewView:(GPUImageView *)preview
{
    [filter addTarget:preview];
}

-(void)beginCaptureWithCompletion:(ImageCapturedBlock)block
{
    [captureTimer invalidate];
    captureTimer = nil;
    
    imageCapturedBlock = block;
    
    captureTimer = [NSTimer scheduledTimerWithTimeInterval:1/self.frameRate target:self selector:@selector(captureImage) userInfo:nil repeats:YES];
}

-(void)endCapture
{
    [captureTimer invalidate];
    captureTimer = nil;
}

-(void)captureImage
{
    
    int totalImages = self.duration / (1/self.frameRate);
    
    if (self.images.count > totalImages) return;
    
    UIImage *frame = [filter imageFromCurrentlyProcessedOutput];
    
    if (frame){
        [self.images addObject:frame];
        if (imageCapturedBlock) imageCapturedBlock(frame, self.images.count / (float)totalImages);
    }
}

- (void)exportAnimatedGif
{
    float numFrames = self.images.count;
    float delay = 1.0f/self.frameRate;
    
    int loopCount = 0;
    
    NSString *path = [NSString stringWithFormat:@"%@/anim.gif", DOCUMENTS];
    
    CGImageDestinationRef imageDestination = CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:path], CFSTR("com.compuserve.gif"), numFrames, NULL);
    
    // image/frame level properties
    NSDictionary *imageProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithFloat:delay], (NSString *)kCGImagePropertyGIFDelayTime,
                                     nil];
    
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                imageProperties, (NSString *)kCGImagePropertyGIFDictionary,
                                nil];
    
    for (UIImage *image in self.images) {
        CGImageDestinationAddImage(imageDestination, image.CGImage, (__bridge CFDictionaryRef)properties);
    }
    
    // gif level properties
    NSDictionary *gifProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInt: loopCount], (NSString *)kCGImagePropertyGIFLoopCount,
                                   [NSNumber numberWithInt:1.0], kCGImageDestinationLossyCompressionQuality,
                                   nil];
    
    properties = [NSDictionary dictionaryWithObjectsAndKeys:
                  gifProperties, (NSString *)kCGImagePropertyGIFDictionary,
                  nil];
    
    CGImageDestinationSetProperties(imageDestination, (__bridge CFDictionaryRef)properties);
    CGImageDestinationFinalize(imageDestination);
    CFRelease(imageDestination);
    
    NSLog(@"animated GIF file created at %@", path);
}

@end
