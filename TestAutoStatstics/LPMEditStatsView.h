//
//  LPMEditStatsView.h
//  TestAutoStatstics
//
//  Created by 金龙潘 on 2017/12/8.
//  Copyright © 2017年 金龙潘. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LPMEditStatsView : UIView
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) void (^block)(NSString *text, BOOL isOK);
+ (instancetype)editView;
@end
