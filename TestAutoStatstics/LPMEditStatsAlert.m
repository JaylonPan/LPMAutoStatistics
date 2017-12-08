//
//  LPMEditStatsAlert.m
//  TestAutoStatstics
//
//  Created by 金龙潘 on 2017/12/8.
//  Copyright © 2017年 金龙潘. All rights reserved.
//

#import "LPMEditStatsAlert.h"
#import "LPMEditStatsView.h"

@interface LPMEditStatsAlert()
@property (nonatomic, copy) void(^block)(NSString *text, BOOL isOK);
@property (nonatomic, strong) LPMEditStatsView *editView;
@end
@implementation LPMEditStatsAlert
+ (instancetype)sharedInstance {
    static LPMEditStatsAlert *singleInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleInstance = [[LPMEditStatsAlert alloc]init];
        singleInstance.rootViewController = [UIViewController new];
        singleInstance.rootViewController.view.hidden = YES;
        singleInstance.backgroundColor = [UIColor colorWithWhite:0 alpha:.2];
        singleInstance.editView = [LPMEditStatsView editView];
        [singleInstance addSubview:singleInstance.editView];
        [singleInstance layoutTheViews];
    });
    return singleInstance;
}

- (void)layoutTheViews {
    CGPoint center = CGPointMake(CGRectGetWidth(self.frame) / 2.f, CGRectGetHeight(self.frame) / 2.f);
    self.editView.center = center;
//    NSLayoutConstraint *centerX =  [NSLayoutConstraint constraintWithItem:self.editView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f];
//    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self.editView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f];
//    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.editView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.f constant:250.f];
//    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.editView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:160.f];
//    [self addConstraints:@[centerX, centerY]];
//    [self.editView addConstraints:@[width, height]];
}
- (void)showWithText:(NSString *)text block:(void (^)(NSString *, BOOL))block {
    self.block = block;
    self.editView.text = text;
    __weak typeof(self) weakSelf = self;
    self.editView.block = ^(NSString *text, BOOL isOK) {
        __strong typeof(self) self = weakSelf;
        self.block(text, isOK);
        [self dismiss];
    };
    [self makeKeyAndVisible];
    self.hidden = NO;
}

- (void)dismiss {
    self.block = nil;
    self.editView.text = nil;
    self.editView.block = nil;
    [self resignKeyWindow];
    self.hidden = YES;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
