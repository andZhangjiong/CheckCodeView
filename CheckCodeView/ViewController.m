//
//  ViewController.m
//  CheckCodeView
//
//  Created by 张炯 on 2018/7/25.
//  Copyright © 2018年 张炯. All rights reserved.
//

#import "ViewController.h"
#import "HXActionView.h"

@interface ViewController ()<HXActionViewDelegate>

@property (nonatomic, strong) HXActionView *action;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [button setTitle:@"校验码弹出" forState:(UIControlStateNormal)];
    button.frame = CGRectMake(100, 100, 160, 50);
    button.backgroundColor = [UIColor redColor];
    [self.view addSubview:button];
    
    [button addTarget:self action:@selector(buttonWithType:) forControlEvents:(UIControlEventTouchUpInside)];
}

- (void)buttonWithType:(UIButton *)button
{
    self.action = [HXActionView share];
    
    // 刷新校验码
    self.action.changeString = [self.action randomString:4];
    
    //    /// 交互
    //    self.action.delegate = self;
    
    __weak typeof(self)weakSelf = self;
    [self.action setActionViewWithSucceedBlock:^(NSString *text) {
        [weakSelf actionViewWithSucceed:text];
    }];
    
    [self.action setActionViewWithUpdateVerificationCodeBlock:^{
        [weakSelf actionViewWithUpdateVerificationCode];
    }];
}

#pragma mark HXActionViewDelegate
- (void)actionViewWithSucceed:(NSString *)text
{
    if (![self.action.changeString.lowercaseString isEqualToString:text.lowercaseString]) {
        
        // 输入信息
        self.action.changeString = [self.action randomString:4];
        self.action.erroMessage = @"校验码输入错误,请重新输入";
    }
    else {
        self.action.erroMessage = @"校验码输入正确";
    }
}

- (void)actionViewWithUpdateVerificationCode
{
    self.action.changeString = [self.action randomString:4];
}

@end
