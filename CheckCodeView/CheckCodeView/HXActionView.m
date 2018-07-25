//
//  HXActionView.m
//  HongXun
//
//  Created by 张炯 on 2018/5/3.
//

#define     iPhone_X_HX                    ((HEIGHT_SCREEN == 812)&&(WIDTH_SCREEN == 375))
#define     iPhone5                     WIDTH_SCREEN == 320
#define     iPhone6                     WIDTH_SCREEN == 375
#define     iPhone6P                    WIDTH_SCREEN == 414
#define     OVER_Iphone6                WIDTH_SCREEN > 375

#define     WIDTH_SCREEN                [UIScreen mainScreen].bounds.size.width
#define     HEIGHT_SCREEN               [UIScreen mainScreen].bounds.size.height
#define     Font_ADAPTER(value)             (iPhone5 ?  value-1  :  ( OVER_Iphone6 ? value+2 : value ) )
#define     Layout_ADAPTER(value)            (int)( iPhone5 ? ( value * 0.85 ) : ( OVER_Iphone6 ? (value  / 0.9) : value ) )

#define  kLineBackColorNormal [UIColor colorWithHex:0x4AC3FF]
#define  kLineBackColorSelect [UIColor colorWithHex:0xE5E5E5]

#import "HXActionView.h"
#import "PooCodeView.h"

@interface HXActionView ()<UITextFieldDelegate>

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *showView;

@property (nonatomic, strong) UILabel *cursorLabel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *erroMessageLabel;

@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, strong) PooCodeView *codeView;

@end

@implementation HXActionView

#pragma mark - Public

+ (HXActionView *)share
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    HXActionView *actionView = [[HXActionView alloc] initWithFrame:rect];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_SCREEN, HEIGHT_SCREEN)];
    backView.backgroundColor = [UIColor colorWithHex:0xb2b2b2];
    backView.alpha = 0.4;
    
    CGFloat showW = WIDTH_SCREEN - Layout_ADAPTER(47.5 * 2);
    UIView *showView = [[UIView alloc] initWithFrame:CGRectMake((WIDTH_SCREEN-showW)/2, Layout_ADAPTER(139), showW, Layout_ADAPTER(191))];
    showView.layer.cornerRadius = 4;
    showView.layer.masksToBounds = YES;
    showView.backgroundColor = [UIColor whiteColor];
    
    // 主控件
    [actionView addSubview:backView]; //  背景
    [actionView addSubview:showView]; //  中间view
    
    actionView.backView = backView;
    actionView.showView = showView;
    
    [[UIApplication sharedApplication].keyWindow addSubview:actionView];

    // 子控件
    CGFloat canceleW = 35;
    CGFloat cancelX = showView.frame.size.width - canceleW;
    UIButton *cancelButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    cancelButton.frame = CGRectMake(cancelX, 0, canceleW, canceleW);
    [cancelButton setImage:[UIImage imageNamed:@"alertView_closed"] forState:(UIControlStateNormal)];
    [showView addSubview:cancelButton];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:Font_ADAPTER(18)];
    titleLabel.textColor = [UIColor colorWithHex:0x000000];
    titleLabel.text = @"请输入验证码";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.frame = CGRectMake(0, Layout_ADAPTER(25), showView.frame.size.width, Layout_ADAPTER(25));
    [showView addSubview:titleLabel];
    
    CGFloat codeViewH = Layout_ADAPTER(35);
    CGFloat codeViewX = (showView.frame.size.width - Layout_ADAPTER(90)) / 2;
    CGFloat codeViewY = CGRectGetMaxY(titleLabel.frame) + Layout_ADAPTER(15);
    
    PooCodeView *codeView = [[PooCodeView alloc] initWithFrame:(CGRectMake(codeViewX, codeViewY, Layout_ADAPTER(90), codeViewH)) andChangeArray:nil];
    [showView addSubview:codeView];
    actionView.codeView = codeView;
    
    UIButton *refreshButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    refreshButton.frame = CGRectMake(CGRectGetMaxX(codeView.frame), codeViewY, codeViewH, codeViewH);
    [refreshButton setImage:[UIImage imageNamed:@"verification_code_refresh"] forState:(UIControlStateNormal)];
    [showView addSubview:refreshButton];
    
    UITextField *textField = [[UITextField alloc] init];
    textField.delegate = actionView;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.keyboardType = UIKeyboardTypeASCIICapable;
    [showView addSubview:textField];
    [textField becomeFirstResponder];
    actionView.textField = textField;
    
    CGFloat codeLabelLet = Layout_ADAPTER(45);
    CGFloat codeLabelW = Layout_ADAPTER(40);
    CGFloat codeLabelY = CGRectGetMaxY(codeView.frame) + Layout_ADAPTER(15);
    for (int i = 0; i < 4; ++i)
    {
        UILabel *codeLabel = [[UILabel alloc] init];
        codeLabel.tag = 100 + i;
        codeLabel.textColor = [UIColor colorWithHex:0x333333];
        codeLabel.font = [UIFont systemFontOfSize:Font_ADAPTER(18)];
        codeLabel.textAlignment = NSTextAlignmentCenter;
        codeLabel.frame = CGRectMake(codeLabelLet + i * (codeLabelW+Layout_ADAPTER(10)),
                                     codeLabelY,
                                     codeLabelW,
                                     codeLabelW);
        [showView addSubview:codeLabel];
        
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, codeLabelW - 1, codeLabelW, 1)];
        line.tag =  200;
        line.backgroundColor = i == 0 ? kLineBackColorNormal : kLineBackColorSelect;
        [codeLabel addSubview:line];
    }
    
    UILabel *cursorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, codeLabelY+Layout_ADAPTER(10), 1, codeLabelW-Layout_ADAPTER(20))];
    cursorLabel.backgroundColor = [UIColor colorWithHex:0x4AC3FF];
    cursorLabel.layer.cornerRadius = 2;
    cursorLabel.layer.masksToBounds = YES;
    [showView addSubview:cursorLabel];
    actionView.cursorLabel = cursorLabel;
    
    UIView *tempView = [showView viewWithTag:100+textField.text.length];
    
    CGRect cursorFrame = cursorLabel.frame;
    cursorFrame.origin.x = tempView.frame.origin.x + tempView.frame.size.width / 2;
    cursorLabel.frame = cursorFrame;

    textField.frame = CGRectMake(0, cursorLabel.frame.origin.y-Layout_ADAPTER(10), WIDTH_SCREEN, 40);
    textField.textColor = [UIColor clearColor];
    textField.tintColor= [UIColor clearColor];
    
    UILabel *erroMessageLabel = [[UILabel alloc] init];
    erroMessageLabel.frame = CGRectMake(0, showView.frame.size.height - Layout_ADAPTER(25), showW, Font_ADAPTER(12) + 1);
    erroMessageLabel.textAlignment = NSTextAlignmentCenter;
    erroMessageLabel.hidden = YES;
    erroMessageLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:Font_ADAPTER(12)];
    erroMessageLabel.textColor = [UIColor colorWithRed:255/255.0 green:105/255.0 blue:113/255.0 alpha:1/1.0];
    [showView addSubview:erroMessageLabel];
    actionView.erroMessageLabel = erroMessageLabel;
    
    // 监听输入
    [textField addTarget:actionView action:@selector(textField1TextChange:) forControlEvents:UIControlEventEditingChanged];
    
    // 手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:actionView action:@selector(disappearWithAction)];
    [backView addGestureRecognizer:tap];
    
    [cancelButton addTarget:actionView action:@selector(disappearWithAction) forControlEvents:(UIControlEventTouchUpInside)];
    [refreshButton addTarget:actionView action:@selector(refreshButtonAction) forControlEvents:(UIControlEventTouchUpInside)];

    [UIView animateWithDuration:0.5 animations:^{
        actionView.hidden = NO;
    }];

    // 光标倒计时
    cursorLabel.hidden = YES;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    actionView.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(actionView.timer,dispatch_walltime(NULL, 0),0.7*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(actionView.timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            cursorLabel.hidden = !cursorLabel.hidden;
        });
    });
    dispatch_resume(actionView.timer);

   return actionView;
}

- (void)setChangeString:(NSString *)changeString
{
    _changeString = changeString;
    
    _textField.text = @"";
    
    _codeView.changeString = changeString.mutableCopy;
    
    [self textField1TextChange:_textField];
}

- (void)disappearWithAction
{
    dispatch_source_cancel(_timer);
    _timer = nil;
    
    [UIView animateWithDuration:0.5 animations:^{
        [self removeFromSuperview];
    }];
}

- (void)setErroMessage:(NSString *)erroMessage
{
    _erroMessage = erroMessage;
    
    if ( erroMessage && erroMessage.length) {
        _erroMessageLabel.text = erroMessage;
        _erroMessageLabel.hidden = NO;
    }
}

#pragma mark Touch

- (void)refreshButtonAction
{
    if (_actionViewWithUpdateVerificationCodeBlock) {
        _actionViewWithUpdateVerificationCodeBlock();
    }
    else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(actionViewWithUpdateVerificationCode)]) {
            [self.delegate actionViewWithUpdateVerificationCode];
        }
    }
}

- (void)textField1TextChange:(UITextField *)textField
{
    NSString *text = [self removeSpaceAndNewline:textField.text];
    
    textField.text = text;
    
    if (!_erroMessageLabel.hidden) {
        _erroMessageLabel.hidden = YES;
        _erroMessage = nil;
    }
    
    UILabel *codeLabel0 = [self.showView viewWithTag:100];
    UILabel *codeLabel1 = [self.showView viewWithTag:101];
    UILabel *codeLabel2 = [self.showView viewWithTag:102];
    UILabel *codeLabel3 = [self.showView viewWithTag:103];
    
    UIView *tempView = [self.showView viewWithTag:100+text.length];
    
    CGRect cursorFrame = self.cursorLabel.frame;
    cursorFrame.origin.x = tempView.frame.origin.x + tempView.frame.size.width / 2;
    self.cursorLabel.frame = cursorFrame;
    self.cursorLabel.alpha = text.length == 4 ? 0 : 1;
    
    if (text.length == 1) {
        codeLabel0.text = text;
        codeLabel1.text = @"";
        codeLabel2.text = @"";
        codeLabel3.text = @"";
    }
    else if (text.length == 2) {
        codeLabel1.text = [text substringFromIndex:text.length-1];
        codeLabel2.text = @"";
        codeLabel3.text = @"";
    }
    else if (text.length == 3) {
        codeLabel2.text = [text substringFromIndex:text.length-1];
        codeLabel3.text = @"";
    }
    else if (text.length == 4) {
        codeLabel3.text = [text substringFromIndex:text.length-1];
        
        if (_actionViewWithSucceedBlock) {
            _actionViewWithSucceedBlock(text);
        }
        else {
            if ([self.delegate respondsToSelector:@selector(actionViewWithSucceed:)] && self.delegate) {
                [self.delegate actionViewWithSucceed:text];
            }
        }
    }
    else {
        codeLabel0.text = @"";
        codeLabel1.text = @"";
        codeLabel2.text = @"";
        codeLabel3.text = @"";
    }
    
    for (int i = 0; i < 4; ++i)
    {
        UILabel *codeLabel = [self.showView viewWithTag:100 + i];
        UILabel *line = [codeLabel viewWithTag:200];
        line.backgroundColor = text.length == i ? kLineBackColorNormal: kLineBackColorSelect;
    }
}

#pragma mark - Privately

- (NSString *)removeSpaceAndNewline:(NSString *)str
{
    NSString *temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    temp = [temp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    return temp.copy;
}

- (void)animationDidStop:(CABasicAnimation *)anim finished:(BOOL)flag
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.showView.layer.backgroundColor = (__bridge CGColorRef)anim.toValue;
    [CATransaction commit];
}


- (NSString*)randomString:(int)len
{
    char* charSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    
    char* temp = malloc(12 + 1);
    
    for (int i = 0; i < 12; i++) {
        
        int randomPoz = arc4random()%strlen(charSet);
        
        temp[i] = charSet[randomPoz];
    }
    
    temp[len] = '\0';
    
    NSMutableString* randomString = [[NSMutableString alloc] initWithUTF8String:temp];
    
    free(temp);
    
    return randomString;
}

@end

#pragma mark - 分类

@implementation UIColor (HXColor)

+ (UIColor*) colorWithHex:(long)hexColor {
    return [UIColor colorWithHex:hexColor alpha:1.0];
}

+ (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity {
    float red = ((float)((hexColor & 0xFF0000) >> 16))/255.0;
    float green = ((float)((hexColor & 0xFF00) >> 8))/255.0;
    float blue = ((float)(hexColor & 0xFF))/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:opacity];
}

@end
