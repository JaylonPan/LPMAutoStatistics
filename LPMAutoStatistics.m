//
//  LPMAutoStatistics.m
//  TestAutoStatstics
//
//  Created by 金龙潘 on 2017/12/7.
//  Copyright © 2017年 金龙潘. All rights reserved.
//

#import "LPMAutoStatistics.h"
#import <LPMHookUtils/LPMHookUtils.h>
#import <objc/runtime.h>
#import <objc/message.h>

#define LPMConfigFileName @"lpm_auto_stats_config.plist"
#define LPMAutoStatsDirName @"lpm_suto_stats"
#define BlackList @[@"dealloc", @"lpmAutoStatsIgnoreList"]

static LPMAutoStatsBlock g_uploadLogBlock;
static LPMAutoStatsRecordBlock g_recordBlock;
static BOOL g_isRecording;

@implementation LPMAutoStatistics
+ (void)setupWithBlock:(LPMAutoStatsBlock)block {
    g_uploadLogBlock = [block copy];
    [self setupConfigFile];
    [self setupStatsList];
}

+ (void)setupConfigFile {
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[self configFilePath]];
    if (!exists) {
        BOOL dirExists = [[NSFileManager defaultManager] fileExistsAtPath:[self configDir]];
        if (!dirExists) {
            NSError *error = nil;
            BOOL success = NO;
           success = [[NSFileManager defaultManager] createDirectoryAtPath:[self configDir] withIntermediateDirectories:YES attributes:nil error:&error];
            if (!success || !error) {
#if DEBUG
                [NSException raise:@"Dir created failed error!" format:@"%@",error];
#else
                NSLog(@"Dir created failed error!  %@",error);
#endif
                return;
            }
        }
        NSString *theFilePath = [[NSBundle mainBundle] pathForResource:LPMConfigFileName ofType:nil];
        if (!theFilePath) {
#if DEBUG
            [NSException raise:@"No config file exception." format:@" The project doesn't have config file named:%@",LPMConfigFileName];
#endif
            return;
        }
        NSError *error = nil;
       [[NSFileManager defaultManager]copyItemAtPath:theFilePath toPath:[self configFilePath] error:&error];
        if (!error) {
#if DEBUG
            [NSException raise:@"File copied failed error!" format:@"%@",error];
#else
            NSLog(@"File copied failed error!  %@",error);
#endif
            return;
        }
    }
    
    [self getConfigDict:^(NSMutableDictionary *config) {
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:[self configFilePath]];
        [config removeAllObjects];
        if (dic) {
            [config addEntriesFromDictionary:dic];
        }
    }];
}

+ (BOOL)hasConfigFile {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self configFilePath]];
}

+ (void)setupStatsList {
    [self getConfigDict:^(NSMutableDictionary *config) {
        for (NSString *key in config.allKeys) {
            Class clazz = nil;
            SEL selector = nil;
            id stats = [config valueForKey:key];
            NSArray *arr = [self analysisConfigKey:key];
            if (arr.count) {
                clazz = NSClassFromString(arr[0]);
            }
            if (arr.count > 1) {
                selector = NSSelectorFromString(arr[1]);
            }
            if (!clazz || !selector || !stats) {
                continue;
            }
            [LPMHookUtils addHookStartOfMethod:selector ofClass:clazz withHookCallback:^(id receiver, NSArray *arguments) {
                g_uploadLogBlock(stats);
            }];
        }
    }];
}

+ (void)destroyStatsList {
    [self getConfigDict:^(NSMutableDictionary *config) {
        for (NSString *key in config.allKeys) {
            Class clazz = nil;
            SEL selector = nil;
            id stats = [config valueForKey:key];
            NSArray *arr = [self analysisConfigKey:key];
            if (arr.count) {
                clazz = NSClassFromString(arr[0]);
            }
            if (arr.count > 1) {
                selector = NSSelectorFromString(arr[1]);
            }
            if (!clazz || !selector || !stats) {
                continue;
            }
            [LPMHookUtils removeHookWithMethod:selector ofClass:clazz];
        }
    }];
}

+ (void)replaceConfigWithDictionary:(NSDictionary *)dictionary {
    [self getConfigDict:^(NSMutableDictionary *config) {
        if (dictionary) {
            [config removeAllObjects];
            [config addEntriesFromDictionary:dictionary];
            [config writeToFile:[self configFilePath] atomically:YES];
        }
    }];
}

+ (NSDictionary<NSString *, id<NSCoding> > *)configDictionary {
#if DEBUG
    __block NSDictionary *dic = nil;
    [self getConfigDict:^(NSMutableDictionary *config) {
        dic = [config copy];
    }];
    return dic;
#else
    return nil;
#endif
}

+ (NSArray<NSString *> *)analysisConfigKey:(NSString *)key {
    return [key componentsSeparatedByString:@"^"];
}
+ (NSString *)configKeyWithClass:(Class)clazz selector:(SEL)selector {
    return [NSString stringWithFormat:@"%@^%@",NSStringFromClass(clazz), NSStringFromSelector(selector)];
}

+ (void)getConfigDict:(void(^)(NSMutableDictionary *config))block {
    static NSMutableDictionary *theConfig = nil;
    static dispatch_queue_t getConfigDictQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        getConfigDictQueue = dispatch_queue_create("getConfigDictQueue", DISPATCH_QUEUE_SERIAL);
        theConfig = [NSMutableDictionary dictionary];
    });
    dispatch_barrier_sync(getConfigDictQueue, ^{
        block(theConfig);
    });
}

+ (void)classesPreparedForRecording:(void(^)(NSMutableArray *preparedClasses))block {
    static NSMutableArray *preparedClasses = nil;
    static dispatch_queue_t preparedClassesQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        preparedClassesQueue = dispatch_queue_create("preparedClassesQueue", DISPATCH_QUEUE_SERIAL);
        preparedClasses = [NSMutableArray array];
    });
    dispatch_barrier_sync(preparedClassesQueue, ^{
        block(preparedClasses);
    });
}

+ (void)configStats:(id<NSCoding>)stats forKey:(NSString *)key {
#if DEBUG
    if (!key ||!stats) {
        return;
    }
    NSArray *arr = [self analysisConfigKey:key];
    Class clazz = nil;
    SEL selector = nil;
    if (arr.count) {
        clazz = NSClassFromString(arr[0]);
    }
    if (arr.count > 1) {
        selector = NSSelectorFromString(arr[1]);
    }
    [self getConfigDict:^(NSMutableDictionary *config) {
        [config setValue:stats forKey:key];
        [config writeToFile:[self configFilePath] atomically:YES];
    }];
    
#endif
}

+ (void)prepareClassForRecord:(Class)clazz rootClass:(Class)rootClazz {
#if DEBUG
    if (!g_isRecording) {
        return;
    }
    if (!clazz || !rootClazz) {
        NSLog(@"class:%@,rootClass:%@", clazz, rootClazz);
        return;
    }
    if (![clazz isSubclassOfClass:rootClazz] && ![clazz isEqual:rootClazz]) {
        [NSException raise:@"clazz not rootClass's subclass " format:@"The clazz should be subclass of rootClazz!"];
        return;
    }

    do {
        __block BOOL prepared = NO;
        [self classesPreparedForRecording:^(NSMutableArray *preparedClasses) {
            prepared = ([preparedClasses indexOfObject:clazz] != NSNotFound);
        }];
        if (!prepared) {
            unsigned int count = 0;
            Method *methodList = class_copyMethodList(clazz, &count);
            SEL ignoreSel = @selector(lpmAutoStatsIgnoreList);
            Method method = class_getClassMethod(clazz, ignoreSel);
            IMP imp = method_getImplementation(method);
            NSArray<NSString *> * (*fuc)(void) = (void *)imp;
            
            NSArray<NSString *> *ignoreList = fuc();
            for (unsigned i = 0; i < count; i ++) {
                Method method = methodList[i];
                SEL selector = method_getName(method);
                if ([BlackList indexOfObject:NSStringFromSelector(selector)] != NSNotFound) {
                    continue;
                }
                if ([ignoreList indexOfObject:NSStringFromSelector(selector)] != NSNotFound) {
                    continue;
                }
                [LPMHookUtils addHookStartOfMethod:selector
                                           ofClass:clazz
                                  withHookCallback:^(id receiver, NSArray *arguments) {
                                      
                      __block id<NSCoding> stats = nil;
                      NSString *key = [self configKeyWithClass:clazz selector:selector];
                      [self getConfigDict:^(NSMutableDictionary *config) {
                          stats = config[key];
                      }];
                      g_recordBlock(key,stats);
                                      
                }];
            }
            [self classesPreparedForRecording:^(NSMutableArray *preparedClasses) {
                [preparedClasses addObject:clazz];
            }];
        }
        
        if ([NSStringFromClass(clazz) isEqualToString:NSStringFromClass(rootClazz)]) {
            break;
        }
    } while ((clazz = [clazz superclass]));
#endif
}

+ (void)startRecordWithBlock:(LPMAutoStatsRecordBlock)block {
#if DEBUG
    [self destroyStatsList];
    g_recordBlock = [block copy];
    g_isRecording = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:kLPMAutoStatsWillStartRecordingNotifyName object:nil];
#endif
}

+ (void)endRecord {
#if DEBUG
    g_recordBlock = nil;
    g_isRecording = NO;
    [self classesPreparedForRecording:^(NSMutableArray *preparedClasses) {
        for (Class clazz in preparedClasses) {
            [LPMHookUtils removeAllHooksOfClass:clazz];
        }
        [preparedClasses removeAllObjects];
    }];
    [self setupStatsList];
#endif
}

+ (BOOL)isRecording {
#if DEBUG
    return g_isRecording;
#else
    return NO;
#endif
}

+ (NSString *)configFilePath {
    static NSString *lpmConfigFilePath = nil;
    if (!lpmConfigFilePath) {
        NSString *configDir = [self configDir];
        if (![configDir hasSuffix:@"/"]) {
            configDir = [configDir stringByAppendingString:@"/"];
        }
        lpmConfigFilePath = [configDir stringByAppendingString:LPMConfigFileName];
    }
    return lpmConfigFilePath;
}
+ (NSString *)configDir {
    static NSString *lpmConfigDir = nil;
    if (!lpmConfigDir) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex:0];
        if (![docDir hasSuffix:@"/"]) {
            docDir = [docDir stringByAppendingString:@"/"];
        }
        lpmConfigDir = [docDir stringByAppendingString:LPMAutoStatsDirName];
    }
    return lpmConfigDir;
}
    
@end
