//
//  TestViewController.m
//  QRScanner
//
//  Created by kang on 15/11/26.
//  Copyright © 2015年 devhk. All rights reserved.
//

#import "TestViewController.h"

@implementation TestViewController
- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"Test";
    [self.navigationController setNavigationBarHidden:NO];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = left;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
