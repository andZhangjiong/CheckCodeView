//
//  HXActionView.h
//  HongXun
//
//  Created by 张炯 on 2018/5/3.
//

#import <UIKit/UIKit.h>

@protocol HXActionViewDelegate <NSObject>

- (void)actionViewWithSucceed:(NSString *)text;

- (void)actionViewWithUpdateVerificationCode;


@end

@interface HXActionView : UIView


@property (nonatomic, weak) id <HXActionViewDelegate> delegate;

@property (nonatomic, copy) NSString *changeString;
@property (nonatomic, copy) NSString *erroMessage;

@property (nonatomic, copy) void (^actionViewWithSucceedBlock)(NSString *text);
@property (nonatomic, copy) void (^actionViewWithUpdateVerificationCodeBlock)(void);

/// 初始化
+ (HXActionView *)share;

/// 关闭弹窗
- (void)disappearWithAction;

/// 获取随机校验码
- (NSString*)randomString:(int)len;

@end

@interface UIColor (HXColor)

+ (UIColor*) colorWithHex:(long)hexColor;

+ (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity ;

@end
