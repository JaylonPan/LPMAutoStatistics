//
//  LPMEditStatsView.m
//  TestAutoStatstics
//
//  Created by 金龙潘 on 2017/12/8.
//  Copyright © 2017年 金龙潘. All rights reserved.
//

#import "LPMEditStatsView.h"

@interface LPMEditStatsView()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end
@implementation LPMEditStatsView

+ (instancetype)editView {
    LPMEditStatsView *view = [[NSBundle mainBundle] loadNibNamed:@"LPMEditStatsView" owner:nil options:nil][0];
    view.autoresizingMask = UIViewAutoresizingNone;
    view.autoresizesSubviews = NO;
    return view;
}

- (void)setText:(NSString *)text {
    _text = text;
    self.textView.text = text;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)okAction:(id)sender {
    if (self.block) {
        self.block(self.textView.text,YES);
    }
}
- (IBAction)cancelAction:(id)sender {
    if (self.block) {
        self.block(self.textView.text,NO);
    }
}

@end
