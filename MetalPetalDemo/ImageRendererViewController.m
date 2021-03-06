//
//  ViewController.m
//  MetalPetalDemo
//
//  Created by YuAo on 25/06/2017.
//  Copyright © 2017 MetalPetal. All rights reserved.
//

#import "ImageRendererViewController.h"
#import "MetalPetalDemo-Swift.h"
#import "WeakToStrongObjectsMapTableTests.h"
#import "CameraViewController.h"
@import MetalPetal;
@import MetalKit;

@interface ImageRendererViewController () <MTKViewDelegate>

@property (nonatomic, weak) MTKView *renderView;

@property (nonatomic, strong) MTIContext *context;

@property (nonatomic, strong) MTIImage *inputImage;

@property (nonatomic, strong) MTISaturationFilter *saturationFilter;

@property (nonatomic, strong) MTIColorInvertFilter *colorInvertFilter;

@end

@implementation ImageRendererViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[MetalPetalSwiftInterfaceTest test];
    
    //[WeakToStrongObjectsMapTableTests test];

    NSError *error;
    MTIContext *context = [[MTIContext alloc] initWithDevice:MTLCreateSystemDefaultDevice() error:&error];
    self.context = context;
    
    UIImage *image = [UIImage imageNamed:@"P1040808.jpg"];
    
    MTKView *renderView = [[MTKView alloc] initWithFrame:self.view.bounds device:context.device];
    renderView.delegate = self;
    renderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:renderView];
    self.renderView = renderView;
    
    self.saturationFilter = [[MTISaturationFilter alloc] init];
    self.colorInvertFilter = [[MTIColorInvertFilter alloc] init];
    //MTIImage *mtiImageFromCGImage = [[MTIImage alloc] initWithPromise:[[MTICGImagePromise alloc] initWithCGImage:image.CGImage]];
    
    id<MTLTexture> texture = [context.textureLoader newTextureWithCGImage:image.CGImage options:@{MTKTextureLoaderOptionSRGB: @(YES)} error:&error];
    MTIImage *mtiImageFromTexture = [[MTIImage alloc] initWithTexture:texture];
    self.inputImage = mtiImageFromTexture;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)drawInMTKView:(MTKView *)view {
    self.saturationFilter.inputImage = self.inputImage;
    self.saturationFilter.saturation = 1.0 + sin(CFAbsoluteTimeGetCurrent() * 2.0);
    self.colorInvertFilter.inputImage = self.saturationFilter.outputImage;
    self.saturationFilter.inputImage = self.colorInvertFilter.outputImage;
    self.colorInvertFilter.inputImage = self.saturationFilter.outputImage;
    self.saturationFilter.inputImage = self.colorInvertFilter.outputImage;
    self.colorInvertFilter.inputImage = self.saturationFilter.outputImage;
    self.saturationFilter.inputImage = self.colorInvertFilter.outputImage;
    self.colorInvertFilter.inputImage = self.saturationFilter.outputImage;
    MTIImage *outputImage = self.colorInvertFilter.outputImage;
    
    MTIDrawableRenderingRequest *request = [[MTIDrawableRenderingRequest alloc] init];
    request.drawableProvider = self.renderView;
    request.resizingMode = MTIDrawableRenderingResizingModeAspect;
    [self.context renderImage:outputImage toDrawableWithRequest:request error:nil];
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end

