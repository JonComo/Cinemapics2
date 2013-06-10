//
//  CPPreviewViewController.m
//  Cinemapics
//
//  Created by Jon Como on 6/9/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "CPPreviewViewController.h"

@interface CPPreviewViewController ()
{
    __weak IBOutlet UIImageView *imageViewPreview;
}

@end

@implementation CPPreviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    imageViewPreview.animationImages = self.captureSession.images;
    imageViewPreview.animationDuration = 1/self.captureSession.frameRate * self.captureSession.images.count;
    [imageViewPreview startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
