//
//  ViewController.m
//  二维码
//
//  Created by kang on 15/9/28.
//  Copyright © 2015年 devhk. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "QRScannerViewController.h"
#import "TestViewController.h"

@interface ViewController () <QRScannerViewControllerDelegate>
@property (nonatomic, strong) UITextView *resultView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"Scan";
    //初始化
    [self initView];
}

- (void)initView {
    //二维码扫描器
    CGRect mainBounds = [UIScreen mainScreen].bounds;
    UIButton *showQRScanner = [[UIButton alloc] init];
    showQRScanner.frame = CGRectMake(0, 100, mainBounds.size.width, 40);
    [showQRScanner setTitle:@"StartToScan" forState:UIControlStateNormal];
    [showQRScanner setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    showQRScanner.titleLabel.font = [UIFont systemFontOfSize:14];
    showQRScanner.layer.borderColor = [UIColor lightGrayColor].CGColor;
    showQRScanner.layer.borderWidth = 1.0;
    [showQRScanner setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [showQRScanner addTarget:self action:@selector(showQRScanner) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showQRScanner];
    
    
    //title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, mainBounds.size.width, 40)];
    titleLabel.text = @"Scan Result";
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:titleLabel];
    
    //显示扫描结果
    UITextView *resultView = [[UITextView alloc] init];
    resultView.frame = CGRectMake(0, 240, mainBounds.size.width, 80);
    resultView.layer.borderWidth = 1.0;
    resultView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    resultView.textAlignment = NSTextAlignmentLeft;
    resultView.font = [UIFont systemFontOfSize:16];
    resultView.tintColor = [UIColor redColor];
    self.resultView = resultView;
    [self.view addSubview:resultView];
}

- (void)showQRScanner {
    QRScannerViewController *qrScanner = [[QRScannerViewController alloc] init];
    qrScanner.delegate = self;
    [self.navigationController pushViewController:qrScanner animated:YES];
}

- (void)QRScannerViewController:(QRScannerViewController *)qrScanner didFinishScanner:(NSString *)string {
    self.resultView.text = string;
//    TestViewController *viewContrller = [[TestViewController alloc] init];
//    [self.navigationController pushViewController:viewContrller animated:YES];
}
@end
