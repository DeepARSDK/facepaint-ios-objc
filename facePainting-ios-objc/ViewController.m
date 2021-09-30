//
//  ViewController.m
//  facePainting-ios-objc
//
//  Created by Luka Mijatovic on 05/12/2019.
//  Copyright © 2019 DeepAR. All rights reserved.
//

#import "ViewController.h"
#import <DeepAR/DeepAR.h>
#import <DeepAR/CameraController.h>

@interface ViewController () <DeepARDelegate>

@property (nonatomic, strong) DeepAR* deepar;
@property (nonatomic, strong) ARView* arview;
@property (nonatomic, strong) CameraController* cameraController;

@property (nonatomic, assign) NSInteger currentMode;

@property (nonatomic, strong) IBOutlet UIButton* masksButton;

@property (nonatomic, strong) IBOutlet UIStackView* buttonStack;
@property (nonatomic, strong) IBOutlet UISlider* brushSizeSlider;


@end

@implementation ViewController

Vector4 color = {0.0, 0.0, 0.0, 1.0};
float scale = 0.03;
float minValue = 0.005;
float maxValue = 0.25;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.masksButton.backgroundColor = [UIColor lightGrayColor];
    
    // Instantiate ARView and add it to view hierarchy.
    self.deepar = [[DeepAR alloc] init];

    [self.deepar setLicenseKey:@"your-license-key-here"];
    [self.deepar initialize];
    self.deepar.delegate = self;

    self.arview = (ARView*)[self.deepar createARViewWithFrame:[UIScreen mainScreen].bounds];
    [self.view insertSubview:self.arview atIndex:0];
    self.cameraController = [[CameraController alloc] init];
    self.cameraController.deepAR = self.deepar;

    [self.cameraController startCamera];

    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    
    _brushSizeSlider.thumbTintColor = [UIColor colorWithRed:color.x green:color.y blue:color.z alpha:1.0f];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.arview.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification  object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [self.deepar shutdown];
}

- (void)switchEffect:(NSString*)name {
    [self.deepar switchEffectWithSlot:@"effect" path:[[NSBundle mainBundle] pathForResource:name ofType:nil]];
}

- (void)resetPaintingEffect {
    color.x = 0.0;
    color.y = 0.0;
    color.z = 0.0;
    color.w = 1.0;
    scale = 0.03;
    
    _brushSizeSlider.thumbTintColor = [UIColor colorWithRed:color.x green:color.y blue:color.z alpha:1.0f];
    _brushSizeSlider.value = 0.116465863;
}

- (void)initializePaintingEffect {
    _buttonStack.hidden = false;
    _brushSizeSlider.hidden = false;
    
    [self resetPaintingEffect];
}

- (IBAction)takeScreenshot:(id)sender {
    [self.deepar takeScreenshot];
}

- (IBAction)switchCamera:(id)sender {
    self.cameraController.position = self.cameraController.position == AVCaptureDevicePositionBack ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
}

- (void)orientationChanged:(NSNotification *)notification {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        self.cameraController.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        self.cameraController.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    } else if (orientation == UIInterfaceOrientationPortrait) {
        self.cameraController.videoOrientation = AVCaptureVideoOrientationPortrait;
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        self.cameraController.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
    }
}

    // Retrieves and normalizes the location point of the given touch within the view
- (CGPoint)getPoint:(UITouch *) touch {
    CGPoint point = [touch locationInView:self.arview];
    CGSize size = self.view.bounds.size;
    return CGPointMake(point.x / size.width, point.y / size.height);
}

    // Called every time a new touch is detected
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(event.type == UIEventTypeTouches) {
        UITouch * touch = [touches allObjects][0];
        CGPoint point = [self getPoint:touch];
        TouchInfo info = {point.x, point.y, START};
        [self.deepar touchOccurred:info];
    } else {
        [super touchesBegan:touches withEvent:event];
    }
}

    // Called every time a change in the previously started touch is detected
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if(event.type == UIEventTypeTouches) {
        UITouch * touch = [touches allObjects][0];
        CGPoint point = [self getPoint:touch];
        TouchInfo info = {point.x, point.y, MOVE};
        [self.deepar touchOccurred:info];
    } else {
        [super touchesMoved:touches withEvent:event];
    }
}

    // Called every time a previously started touch is ended
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if(event.type == UIEventTypeTouches) {
        UITouch * touch = [touches allObjects][0];
        CGPoint point = [self getPoint:touch];
        TouchInfo info = {point.x, point.y, END};
        [self.deepar touchOccurred:info];
    } else {
        [super touchesEnded:touches withEvent:event];
    }
}

    // Called every time a previously started touch is cancelled (interrupted)
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if(event.type == UIEventTypeTouches) {
        UITouch * touch = [touches allObjects][0];
        CGPoint point = [self getPoint:touch];
        TouchInfo info = {point.x, point.y, END};
        [self.deepar touchOccurred:info];
    } else {
        [super touchesCancelled:touches withEvent:event];
    }
}

- (void)didStartVideoRecording {

}

- (void)didFinishVideoRecording:(NSString*)videoFilePath {
    NSLog(@"didFinishVideoRecording");
}

- (void)recordingFailedWithError:(NSError*)error {
    
}

- (void)didTakeScreenshot:(UIImage*)screenshot {
    UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil, nil);
}

- (void)didInitialize {
    [self switchEffect:@"facePainting"];
}

- (void)faceVisiblityDidChange:(BOOL)faceVisible {

}

- (IBAction)whitePaintBrushTouch:(UIButton *)sender {
    color.x = 1.0;
    color.y = 1.0;
    color.z = 1.0;
    color.w = 1.0;
    
    [self.deepar changeParameter:@"PaintBrush" component: @"MeshRenderer" parameter: @"u_color" vectorValue:color];
    _brushSizeSlider.thumbTintColor = [UIColor colorWithRed:color.x green:color.y blue:color.z alpha:1.0f];
}

- (IBAction)greyPaintBrushTouch:(UIButton *)sender {
    color.x = 0.5;
    color.y = 0.5;
    color.z = 0.5;
    color.w = 1.0;
    
    [self.deepar changeParameter:@"PaintBrush" component: @"MeshRenderer" parameter: @"u_color" vectorValue:color];
    _brushSizeSlider.thumbTintColor = [UIColor colorWithRed:color.x green:color.y blue:color.z alpha:1.0f];
}

- (IBAction)blackPaintBrushTouch:(UIButton *)sender {
    color.x = 0.0;
    color.y = 0.0;
    color.z = 0.0;
    color.w = 1.0;
    
    [self.deepar changeParameter:@"PaintBrush" component: @"MeshRenderer" parameter: @"u_color" vectorValue:color];
    _brushSizeSlider.thumbTintColor = [UIColor colorWithRed:color.x green:color.y blue:color.z alpha:1.0f];
}

- (IBAction)orangePaintBrushTouch:(UIButton *)sender {
    color.x = 209.0/255;
    color.y = 82.0/255;
    color.z = 23.0/255;
    color.w = 1.0;
    
    [self.deepar changeParameter:@"PaintBrush" component: @"MeshRenderer" parameter: @"u_color" vectorValue:color];
    _brushSizeSlider.thumbTintColor = [UIColor colorWithRed:color.x green:color.y blue:color.z alpha:1.0f];
}

- (IBAction)greenPaintBrushTouch:(UIButton *)sender {
    color.x = 132.0/255;
    color.y = 184.0/255;
    color.z = 95.0/255;
    color.w = 1.0;
    
    [self.deepar changeParameter:@"PaintBrush" component: @"MeshRenderer" parameter: @"u_color" vectorValue:color];
    _brushSizeSlider.thumbTintColor = [UIColor colorWithRed:color.x green:color.y blue:color.z alpha:1.0f];
}

- (IBAction)bluePaintBrushTouch:(UIButton *)sender {
    color.x = 95.0/255;
    color.y = 160.0/255;
    color.z = 184.0/255;
    color.w = 1.0;
    
    [self.deepar changeParameter:@"PaintBrush" component: @"MeshRenderer" parameter: @"u_color" vectorValue:color];
    _brushSizeSlider.thumbTintColor = [UIColor colorWithRed:color.x green:color.y blue:color.z alpha:1.0f];
}

- (IBAction)eraseBrushTouch:(UIButton *)sender {
    color.x = 0.0;
    color.y = 0.0;
    color.z = 0.0;
    color.w = 0.0;
    
    [self.deepar changeParameter:@"PaintBrush" component: @"MeshRenderer" parameter: @"u_color" vectorValue:color];
    _brushSizeSlider.thumbTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.1f];
}

- (IBAction)deleteDrawing:(UIButton *)sender {
    Vector3 oldScale = {scale, scale, scale};
    Vector4 oldColor = {color.x, color.y, color.z, color.w};
    
    [self switchEffect:@"facePainting"];
    
    [self.deepar changeParameter:@"PaintBrush" component: @"MeshRenderer" parameter: @"u_color" vectorValue:oldColor];
    [self.deepar changeParameter:@"PaintBrush" component: @"" parameter: @"scale" vector3Value: oldScale];
}

- (IBAction)brushSizeSlider:(UISlider *)sender {
    scale = (1 - sender.value) * minValue + sender.value * maxValue;
    Vector3 newScale = {scale, scale, scale};
    [self.deepar changeParameter:@"PaintBrush" component: @"" parameter: @"scale" vector3Value: newScale];
}

@end
