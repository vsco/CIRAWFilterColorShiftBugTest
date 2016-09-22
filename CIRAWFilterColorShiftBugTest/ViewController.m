//
//  ViewController.m
//  CIRAWFilterColorShiftBugTest
//
//  Created by Gilles Dezeustre on 9/22/16.
//  Copyright © 2016 VSCO. All rights reserved.
//

#import "ViewController.h"

@import CoreImage;
@import AssetsLibrary;

static NSString *kImageFileURLPath = @"TestGradientStripedProfile2";
static NSString *kImageFileURLExtension = @"png";

@interface ViewController ()

@property (strong, nonatomic) UIImage *inputUIImage;
@property (strong, nonatomic) UIImage *outputUIImage;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *imageURL = [NSURL fileURLWithPath:[bundle pathForResource:kImageFileURLPath ofType:kImageFileURLExtension]];
    assert(imageURL);
    
    CIFilter *CIRAWFilter = [CIFilter filterWithImageURL:imageURL options:@{}];

    CIImage *CIRAWFilterOutputImage = CIRAWFilter.outputImage;
    
    CIContext *context = [CIContext contextWithOptions:@{kCIContextWorkingFormat:@(kCIFormatRGBAh),
                                                         kCIContextUseSoftwareRenderer:@YES
                                                         }];
    
    CGImageRef CIRAWFilterOutputCGImage = [context createCGImage:CIRAWFilterOutputImage fromRect:CIRAWFilterOutputImage.extent];
 
    self.inputUIImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.%@", kImageFileURLPath, kImageFileURLExtension]];
    self.outputUIImage = [UIImage imageWithCGImage:CIRAWFilterOutputCGImage];
    
    [self.imageView setImage:self.outputUIImage];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)exportButtonAction:(id)sender {
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    NSData *pngData = UIImagePNGRepresentation(self.outputUIImage);
    
    [library writeImageDataToSavedPhotosAlbum:pngData metadata:@{}
                              completionBlock:^(NSURL *assetURL, NSError *error) {
                                  NSLog(@"%s: export as PNG, write time: %g ms", __PRETTY_FUNCTION__);
                              }];
    
}

- (IBAction)inputOutputButtonAction:(id)sender {
    static BOOL showInput = NO;
    
    showInput = !showInput;
    
    if (showInput) {
        [self.imageView setImage:self.inputUIImage];
    } else {
        [self.imageView setImage:self.outputUIImage];
    }
 }

@end
