//
//  ViewController.m
//  TestAutoStatstics
//
//  Created by 金龙潘 on 2017/12/7.
//  Copyright © 2017年 金龙潘. All rights reserved.
//

#import "ViewController.h"
#import "LPMAutoStatistics.h"
#import "LPMEditStatsAlert.h"

@interface ViewController ()<LPMAutoStatistics>
@property (nonatomic, copy) UIColor *statusColor;
@end

@implementation ViewController
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (instancetype)init {
    if (self = [super init]) {
        [LPMAutoStatistics prepareClassForRecord:[self class] rootClass:[ViewController class]];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(recordStartNotify:) name:kLPMAutoStatsWillStartRecordingNotifyName object:nil];
        [LPMAutoStatistics prepareClassForRecord:[self class] rootClass:[ViewController class]];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)buttonClicked:(id)sender {

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)recordStartNotify:(id)notify {
     [LPMAutoStatistics prepareClassForRecord:[self class] rootClass:[ViewController class]];
}

- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}

- (UIColor *)getStatusBarBackgroudColor {
    UIColor *color = nil;
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
         color =statusBar.backgroundColor;
    }
    return color;
}


- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    UIAlertAction *ok = nil;
    NSString *title = nil;
    if ([LPMAutoStatistics isRecording]) {
        
        title = @"Upload config file?";
        ok = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [LPMAutoStatistics endRecord];
            [self setStatusBarBackgroundColor:self.statusColor];
            NSLog(@"%@",[LPMAutoStatistics configDictionary]);
        }];
        
    }else{
        
        title = @"Start recording?";
        ok = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.statusColor = [self getStatusBarBackgroudColor];
            [self setStatusBarBackgroundColor:[UIColor redColor]];
            [LPMAutoStatistics startRecordWithBlock:^(NSString *key, id<NSCoding> stats) {
                NSLog(@"add config key:%@  oldStats:%@",key,stats);
                [[LPMEditStatsAlert sharedInstance]showWithText:(NSString *)stats block:^(NSString *text, BOOL isOK) {
                    
                    [LPMAutoStatistics configStats:text forKey:key];
                }];
            }];
        }];
    }
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:cancel];
    [controller addAction:ok];
    [self presentViewController:controller animated:YES completion:nil];
}

+ (NSArray<NSString *> *)lpmAutoStatsIgnoreList {
    return @[NSStringFromSelector(@selector(motionEnded:withEvent:))];
}
@end
