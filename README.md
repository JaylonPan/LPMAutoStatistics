# LPMAutoStatistics
一个自动打点追踪的系统
# 用法

## 先在App已进入的时候 初始化 并且在block中调用自己的打点函数.
```
@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [LPMAutoStatistics setupWithBlock:^(id<NSCoding> stats) {
        NSLog(@"%@",stats);//此处直接调用 您自己的打点函数  比如 [LPMLog uploadLog:stats]
    }];
    // Override point for customization after application launch.
    return YES;
}
```
## 在想要自动打点的基类中 进行如下调用
```
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

- (void)recordStartNotify:(id)notify {
     [LPMAutoStatistics prepareClassForRecord:[self class] rootClass:[ViewController class]];
}
```
## 添加要忽略的方法
```
+ (NSArray<NSString *> *)lpmAutoStatsIgnoreList {
    return @[NSStringFromSelector(@selector(motionEnded:withEvent:))];
}
```
## 开启和关闭录制模式 
可以根据需要设置不同的彩蛋  我这里用的是shake手势。

```
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    UIAlertAction *ok = nil;
    NSString *title = nil;
    if ([LPMAutoStatistics isRecording]) {
        
        title = @"Upload config file?";
        ok = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [LPMAutoStatistics endRecord];
            //这里添加上传代码 将本地修改过的配置文件上传到服务器 
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
```


