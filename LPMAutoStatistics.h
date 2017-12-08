//
//  LPMAutoStatistics.h
//  TestAutoStatstics
//
//  Created by 金龙潘 on 2017/12/7.
//  Copyright © 2017年 金龙潘. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kLPMAutoStatsWillStartRecordingNotifyName @"LPMAutoStatsWillStartRecordingNotifyName"


/**
 自动打点回调block 用于调用使用者自己的打点方法。

 @param stats 传回打点信息。
 */
typedef void(^LPMAutoStatsBlock)(id<NSCoding> stats);


/**
 录制的回调  录制过程中 想要打点的类 相应方法被调用时候 会回调这个方法

 @param key 配置文件中的key (className^methodName)
 @param stats 打点信息
 */
typedef void(^LPMAutoStatsRecordBlock)(NSString *key, id<NSCoding> stats);

@interface LPMAutoStatistics : NSObject


/**
 初始化自动打点

 @param block 用于调用使用者自己的打点函数。
 */
+ (void)setupWithBlock:(LPMAutoStatsBlock)block;


/**
 是否有配置文件。

 @return 如果返回YES 则存在 否则不存在。
 */
+ (BOOL)hasConfigFile;


/**
 替换本地的配置文件 用于从服务器拉取最新的配置文件来做替换

 @param dictionary 配置文件的字典
 */
+ (void)replaceConfigWithDictionary:(NSDictionary *)dictionary;


//////////////////////////////////////////////////////////////////////////////////////
//       Warning！    下面的方法 只有DEBUG模式才能调用  建议调用前后加 #if DEBUG ... #endif
//////////////////////////////////////////////////////////////////////////////////////

/**
 获取当前的配置文件字典

 @return 返回配置文件中内容。
 */
+ (NSDictionary<NSString *, id<NSCoding> > *)configDictionary;


/**
 设置配置文件的值

 @param stats 打点信息  可以是任意遵守NSCOding协议的对象 使用者可自行对应自己所使用的打点函数所需参数
 @param key 配置文件中的key。
 */
+ (void)configStats:(id<NSCoding>)stats forKey:(NSString *)key;

/**
 为录制前做好准备 从指定的class 一直配置到指定的他的父类rootClass 如果他们没有父子关系 且不是同一个类 则抛出异常

 @param clazz 你想要自动打点的类
 @param rootClazz 自动打点截止类 不能继续往上
 */
+ (void)prepareClassForRecord:(Class)clazz rootClass:(Class)rootClazz;

/**
 开始录制打点位置

 @param block 用于获取 对应位置在配置文件中的key 和 打点信息 stats 如果配置文件中还不存在这个打点位置则stats为nil;
 */
+ (void)startRecordWithBlock:(LPMAutoStatsRecordBlock )block;


/**
 停止录制模式 并且恢复自动打点模式
 */
+ (void)endRecord;


/**
 是否正在录制

 @return 返回YES 则正在录制 否则没开始录制。
 */
+ (BOOL)isRecording;

@end

@protocol LPMAutoStatistics <NSObject>
@optional
+ (NSArray<NSString *> *)lpmAutoStatsIgnoreList;
@end
