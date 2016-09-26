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

static NSString *kImageFileURLPath = @"IMG_1453";
static NSString *kImageFileURLExtension = @"CR2";

@interface ViewController ()

@property (strong, nonatomic) UIImage *inputUIImage;
@property (strong, nonatomic) UIImage *outputUIImage;
@property (weak, nonatomic) IBOutlet UISwitch *colorspaceSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISwitch *rawSwitch;
@property CGColorSpaceRef workingSpace;

@end

@implementation ViewController


- (void)LoadImage
{
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *imageURL = [NSURL fileURLWithPath:[bundle pathForResource:kImageFileURLPath ofType:kImageFileURLExtension]];
    assert(imageURL);
    
    CIFilter *CIRAWFilter = [CIFilter filterWithImageURL:imageURL options:@{}];
    [CIRAWFilter setValue:@(0.3457) forKey:kCIInputNeutralChromaticityXKey];
    [CIRAWFilter setValue:@(0.3585) forKey:kCIInputNeutralChromaticityYKey];
    
    CIImage *CIRAWFilterOutputImage = CIRAWFilter.outputImage;
    
    CIContext *context = [CIContext contextWithOptions:@{kCIContextWorkingFormat:@(kCIFormatRGBAh),
                                                         kCIContextUseSoftwareRenderer:@YES,
                                                         kCIContextWorkingColorSpace: (__bridge id)self.workingSpace,
                                                         kCIContextOutputColorSpace: (__bridge id)CGColorSpaceCreateWithName(kCGColorSpaceDisplayP3)
                                                         }];
    
    CGImageRef CIRAWFilterOutputCGImage = [context createCGImage:CIRAWFilterOutputImage fromRect:CIRAWFilterOutputImage.extent];
    self.outputUIImage = [UIImage imageWithCGImage:CIRAWFilterOutputCGImage];
    CGImageRelease(CIRAWFilterOutputCGImage);
    [self.imageView setImage:self.outputUIImage];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.workingSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGBLinear);
    [self LoadImage];
    [[self colorspaceSwitch] setEnabled:YES];

}

- (IBAction)colorspaceSwitchToggle:(UISwitch *)sender {
    if ([sender isOn]){
        self.workingSpace = CGColorSpaceCreateWithName(kCGColorSpaceDisplayP3);
    }else{
        self.workingSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGBLinear);
    }
    [self LoadImage];
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

- (IBAction)rawSwitchToggle:(UISwitch *)sender {
    if ([sender isOn]){
        [[self colorspaceSwitch] setEnabled:YES];
        [self.imageView setImage:self.outputUIImage];
    }else{
        [[self colorspaceSwitch] setEnabled:NO];
        self.inputUIImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@.%@", kImageFileURLPath, kImageFileURLExtension]];
        [self.imageView setImage:self.inputUIImage];
    }
}

@end
