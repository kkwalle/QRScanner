//
//  QRScannerViewController.m
//
//  Created by kang on 15/10/8.
//  Copyright © 2015年 devhk. All rights reserved.
//

#import "QRScannerViewController.h"
#import <AVFoundation/AVFoundation.h>

#define mainBounds [UIScreen mainScreen].bounds
#define scanSize CGSizeMake(mainBounds.size.width - 80, mainBounds.size.width - 80)
#define timeInterval 1.5

@interface QRScannerViewController () <AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic, strong) UIImageView *scanLine;
@property (nonatomic, strong) NSTimer *scanLineTimer;
@end

@implementation QRScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    
    //判断相机权限.
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        [self showAlert];
    } else {
        [self initView];
        [self creatTimer];
    }
}

- (void)creatTimer {
    self.scanLineTimer = [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(moveScanLine) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.scanLineTimer forMode:NSRunLoopCommonModes];
}

- (void)moveScanLine {
    __block CGRect tempRect = self.scanLine.frame;
    [UIView animateWithDuration:timeInterval animations:^{
        tempRect.origin.y += scanSize.height - tempRect.size.height;
        self.scanLine.frame = tempRect;
    } completion:^(BOOL finished) {
        tempRect = self.scanLine.frame;
        tempRect.origin.y -= scanSize.height - tempRect.size.height;
        self.scanLine.frame = tempRect;
    }];
}

- (void)initView {
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPreset640x480];
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
    }
    //条码类型
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    /** 扫描框设置开始 */
    //扫描范围
    //扫描范围frame
    CGRect scanFrame = CGRectMake((mainBounds.size.width - scanSize.width) / 2, (mainBounds.size.height - scanSize.height) / 2, scanSize.width, scanSize.height);
    
    //扫描范围设置, rectOfInterest: 与通常的rect有区别, 值域为0-1, 按比例设置
    //x:对应与左上角的垂直距离(相当于通常rect的Y)
    //y:对应与左上角的水平距离(相当于通常rect的X)
    //width & height: 同理, 相当于通常rect 的 height & width
    CGRect interest = CGRectMake(scanFrame.origin.y / mainBounds.size.height, scanFrame.origin.x / mainBounds.size.width, scanSize.height / mainBounds.size.height, scanSize.width / mainBounds.size.width);
        [self.output setRectOfInterest:interest];
    //扫描框周围颜色设置
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainBounds.size.width, scanFrame.origin.y)];
    [self.view addSubview:topView];
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, scanFrame.origin.y, scanFrame.origin.x, scanSize.height)];
    [self.view addSubview:leftView];
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(scanFrame), scanFrame.origin.y, CGRectGetWidth(leftView.frame), scanSize.height)];
    [self.view addSubview:rightView];
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(leftView.frame), mainBounds.size.width, CGRectGetHeight(topView.frame))];
    [self.view addSubview:bottomView];
    //颜色
    topView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    bottomView.backgroundColor = topView.backgroundColor;
    leftView.backgroundColor = topView.backgroundColor;
    rightView.backgroundColor = topView.backgroundColor;
    
    //取景框
    CGFloat edgeLength = 17; //正方形取景框边长
    UIImageView *topLeft = [[UIImageView alloc] initWithFrame:CGRectMake(scanFrame.origin.x, scanFrame.origin.y, edgeLength, edgeLength)];
    topLeft.image = [UIImage imageNamed:@"app_scan_corner4_"];
    [self.view addSubview:topLeft];
    UIImageView *topRight = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(scanFrame) - edgeLength, scanFrame.origin.y, edgeLength, edgeLength)];
    topRight.image = [UIImage imageNamed:@"app_scan_corner3_"];
    [self.view addSubview:topRight];
    UIImageView *bottomLeft = [[UIImageView alloc] initWithFrame:CGRectMake(scanFrame.origin.x, CGRectGetMaxY(scanFrame) - edgeLength, edgeLength, edgeLength)];
    bottomLeft.image = [UIImage imageNamed:@"app_scan_corner2_"];
    [self.view addSubview:bottomLeft];
    UIImageView *bottomRight = [[UIImageView alloc] initWithFrame:CGRectMake(topRight.frame.origin.x, bottomLeft.frame.origin.y, edgeLength, edgeLength)];
    bottomRight.image = [UIImage imageNamed:@"app_scan_corner1_"];
    [self.view addSubview:bottomRight];
    //扫描线
    CGFloat imageWidth = 230;
    CGFloat imageHeight = 2;
    UIImageView *scanLine = [[UIImageView alloc] initWithFrame:CGRectMake((mainBounds.size.width - imageWidth) / 2, scanFrame.origin.y, imageWidth, imageHeight)];
    scanLine.image = [UIImage imageNamed:@"app_scan_line_"];
    self.scanLine = scanLine;
    [self.view addSubview:scanLine];
    
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:self.preview atIndex:0];
    [self.session startRunning];
    
    //返回
    CGFloat backImageViewWidth = 33;
    CGFloat backImageViewY = 64;
    UIButton *back = [[UIButton alloc] init];
    back.frame = CGRectMake(scanFrame.origin.x, backImageViewY, backImageViewWidth, backImageViewWidth);
    [back setBackgroundImage:[UIImage imageNamed:@"app_scan_back_"] forState:UIControlStateNormal];
    [back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];
    
    //相册
    UIButton *toAlbum = [[UIButton alloc] init];
    toAlbum.frame = CGRectMake(CGRectGetMaxX(scanFrame) - backImageViewWidth, backImageViewY, backImageViewWidth, backImageViewWidth);
    [toAlbum setBackgroundImage:[UIImage imageNamed:@"app_scan_folder_"] forState:UIControlStateNormal];
    [toAlbum setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [toAlbum addTarget:self action:@selector(toAlbum) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:toAlbum];
    
    //放大slider
    CGFloat imageViewWidth = 10;
    UIView *sliderView = [[UIView alloc] init];
    sliderView.frame = CGRectMake(0, 0, scanSize.width, imageViewWidth);
    sliderView.backgroundColor = [UIColor grayColor];
    sliderView.center = CGPointMake(CGRectGetMaxX(scanFrame) + scanFrame.origin.x / 2, scanFrame.origin.y + scanSize.height / 2);
    sliderView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    sliderView.layer.cornerRadius = imageViewWidth / 2.0;
    [self.view addSubview:sliderView];
    //addImageView
    UIImageView *addImageView = [[UIImageView alloc] init];
    addImageView.frame = CGRectMake(0, 0, imageViewWidth, imageViewWidth);
    addImageView.image = [UIImage imageNamed:@"app_scan_up_"];
    [sliderView addSubview:addImageView];
    //slider
    UISlider *slider = [[UISlider alloc] init];
    slider.frame = CGRectMake(imageViewWidth, 0, scanSize.width - imageViewWidth * 2, imageViewWidth);
    slider.maximumValue = 3.0;
    slider.minimumValue = 1.0;
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [sliderView addSubview:slider];
    //minusImageView
    UIImageView *minusImageView = [[UIImageView alloc] init];
    minusImageView.frame = CGRectMake(CGRectGetMaxX(slider.frame), 0, imageViewWidth, imageViewWidth);
    minusImageView.image = [UIImage imageNamed:@"app_scan_down_"];
    minusImageView.contentMode = UIViewContentModeScaleAspectFit;
    minusImageView.transform = CGAffineTransformMakeRotation(M_PI_2);
    [sliderView addSubview:minusImageView];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)toAlbum {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePicker.delegate = self;
    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
}

- (void)sliderValueChanged:(UISlider *)slider {
    [self.device lockForConfiguration:nil];
    self.device.videoZoomFactor = slider.value;
    [self.device unlockForConfiguration];
}

- (void)showAlert {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Notice" message:nil delegate:self cancelButtonTitle:@"Setting" otherButtonTitles:@"Ok", nil];
    [alertView show];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    NSString *strValue;
    if ([metadataObjects count] > 0) {
        //停止扫描
        [self.session stopRunning];
        [self.scanLineTimer invalidate];
        self.scanLineTimer = nil;
        AVMetadataMachineReadableCodeObject *object = [metadataObjects objectAtIndex:0];
        strValue = object.stringValue;
        //通知代理
        if ([self.delegate respondsToSelector:@selector(QRScannerViewController:didFinishScanner:)]) {
            [self.navigationController popViewControllerAnimated:NO];
            [self.delegate QRScannerViewController:self didFinishScanner:strValue];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyLow}];
        if (detector) {
            CIImage *ciImage = image.CIImage;
            if (ciImage == nil) {
                ciImage = [CIImage imageWithCGImage:image.CGImage];
            }
            NSArray *featuresR = [detector featuresInImage:ciImage];
            NSString *decodeR;
            for (CIQRCodeFeature* featureR in featuresR) {
                decodeR = featureR.messageString;
                
                //通知代理
                if ([self.delegate respondsToSelector:@selector(QRScannerViewController:didFinishScanner:)]) {
                    [self.navigationController popViewControllerAnimated:NO];
                    [self.delegate QRScannerViewController:self didFinishScanner:decodeR];
                }
            }
        }
    }];
}

#pragma mark - alertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    } else if (buttonIndex == 1) {
        [self back];
    }
}


@end
