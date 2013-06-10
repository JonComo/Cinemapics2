//
//  CPCaptureViewController.m
//  Cinemapics
//
//  Created by Jon Como on 6/9/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "CPCaptureViewController.h"
#import "CPCaptureSession.h"
#import "CPPreviewViewController.h"

@interface CPCaptureViewController ()
{
    CPCaptureSession *captureSession;
    __weak IBOutlet GPUImageView *outputView;
    __weak IBOutlet UIProgressView *progressView;
    
    __weak IBOutlet UIButton *cancelButton;
    __weak IBOutlet UIButton *doneButton;
}

@end

@implementation CPCaptureViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    captureSession = [[CPCaptureSession alloc] initWithFrameRate:24 duration:6 preview:outputView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [captureSession startCamera];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [captureSession stopCamera];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    if (touch.view == cancelButton || touch.view == doneButton)
        return;
    
    __weak UIProgressView *weakProgress = progressView;
    
    [captureSession beginCaptureWithCompletion:^(UIImage *image, float progress) {
        weakProgress.progress = progress;
    }];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [captureSession endCapture];
}

- (IBAction)preview:(id)sender
{
    CPPreviewViewController *preview = [self.storyboard instantiateViewControllerWithIdentifier:@"previewVC"];
    
    preview.captureSession = captureSession;
    
    [self presentViewController:preview animated:YES completion:nil];
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
