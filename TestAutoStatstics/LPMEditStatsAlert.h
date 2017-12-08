//
//  LPMEditStatsAlert.h
//  TestAutoStatstics
//
//  Created by 金龙潘 on 2017/12/8.
//  Copyright © 2017年 金龙潘. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPMEditStatsAlert : UIWindow
+ (instancetype)sharedInstance;
- (void)showWithText:(NSString *)text block:(void(^)(NSString *text, BOOL isOK))block;
@end
