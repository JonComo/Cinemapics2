//
//  CPViewController.m
//  Cinemapics
//
//  Created by Jon Como on 6/8/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#define FPS 24.0f
#define TOTAL 6.0f

#import "CPViewController.h"
#import "GPUImage.h"
#import "Macros.h"

#import <ImageIO/ImageIO.h>

@interface CPViewController ()
{
    GPUImageVideoCamera *videoCamera;
    GPUImageGrayscaleFilter *filter;
    
    NSTimer *captureTimer;
    
    __weak IBOutlet UIProgressView *progressImages;
    
    NSMutableArray *images;
    
    __weak IBOutlet GPUImageView *videoView;
    __weak IBOutlet UIImageView *imageViewPreview;
}

@end

@implementation CPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    images = [NSMutableArray array];
    
    [self setupCamera];
}

-(void)setupCamera
{
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    filter = [[GPUImageGrayscaleFilter alloc] init];
    
    GPUImageCropFilter *crop = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(0, 0, 1, 480.0/640.0)];
    
    [videoCamera addTarget:crop];
    [crop addTarget:filter];
    [filter addTarget:videoView];
    
    [videoCamera startCameraCapture];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (fromInterfaceOrientation == UIInterfaceOrientationPortrait) {
        [self clearImages];
    }
}

-(void)clearImages
{
    [images removeAllObjects];
    imageViewPreview.animationImages = nil;
    progressImages.progress = 0;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!captureTimer)
        captureTimer = [NSTimer scheduledTimerWithTimeInterval:1/FPS target:self selector:@selector(captureImage) userInfo:nil repeats:YES];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [captureTimer invalidate];
    captureTimer = nil;
    
    imageViewPreview.animationDuration = (1/FPS) * images.count;
    imageViewPreview.animationImages = images;
    
    [imageViewPreview startAnimating];
}

-(void)captureImage
{
    int totalImages = TOTAL / (1/FPS);
    
    if (images.count > totalImages) return;
    
    UIImage *frame = [filter imageFromCurrentlyProcessedOutput];
    
    if (frame)
    {
        [images addObject:frame];
        progressImages.progress = images.count / (float)totalImages;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)export:(id)sender
{
    [self exportAnimatedGif];
}

- (void)exportAnimatedGif
{
    float numFrames = images.count;
    float delay = 1.0f/FPS;
    
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
    
    for (UIImage *image in images) {
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
