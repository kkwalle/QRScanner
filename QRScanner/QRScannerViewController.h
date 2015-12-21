//
//  QRScannerViewController.h
//
//  Created by kang on 15/10/8.
//  Copyright © 2015年 devhk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QRScannerViewController;
@protocol QRScannerViewControllerDelegate <NSObject>

- (void)QRScannerViewController:(QRScannerViewController *)qrScanner didFinishScanner:(NSString *)string;

@end

@interface QRScannerViewController : UIViewController
@property (nonatomic, assign) id<QRScannerViewControllerDelegate> delegate;
@end
