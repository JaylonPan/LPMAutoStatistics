//
//  LPMAutoStatistics.h
//  TestAutoStatstics
//
//  Created by 金龙潘 on 2017/12/7.
//  Copyright © 2017年 金龙潘. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kLPMAutoStatsWillStartRecordingNotifyName @"LPMAutoStatsWillStartRecordingNotifyName"

typedef void(^LPMAutoStatsBlock)(id<NSCoding> stats);
typedef void(^LPMAutoStatsRecordBlock)(NSString *key, id<NSCoding> stats);

@interface LPMAutoStatistics : NSObject

+ (void)setupWithBlock:(LPMAutoStatsBlock)block;
+ (BOOL)hasConfigFile;
+ (void)replaceConfigWithDictionary:(NSDictionary *)dictionary;

+ (NSDictionary<NSString *, id<NSCoding> > *)configDictionary;
+ (void)configStats:(id<NSCoding>)stats forKey:(NSString *)key;
+ (void)prepareClassForRecord:(Class)clazz rootClass:(Class)rootClazz;
+ (void)startRecordWithBlock:(LPMAutoStatsRecordBlock )block;
+ (void)endRecord;
+ (BOOL)isRecording;

@end

@protocol LPMAutoStatistics <NSObject>
@optional
+ (NSArray<NSString *> *)lpmAutoStatsIgnoreList;
@end
