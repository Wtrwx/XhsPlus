#import <UIKit/UIKit.h>
#import "CustomSettingsViewController.h"

@interface TTTAttributedLabel : UILabel
@property (nonatomic, assign) NSTimeInterval lastClickTime;
@end

static NSTimeInterval lastClickTime = 0;

%hook TTTAttributedLabel

- (void)touchesBegan:(id)arg1 withEvent:(id)arg2 {
    if (lastClickTime == 0) {
        NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
        lastClickTime = currentTime;
        NSLog(@"[XhsPlus] 初始化 lastClickTime: %f", lastClickTime);
        %orig;
        return;
    }
    
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval timeSinceLastClick = currentTime - lastClickTime;
    
    NSLog(@"[XhsPlus] 当前时间: %f, 上次点击时间: %f", currentTime, lastClickTime);
    if (timeSinceLastClick < 0.5) {
        NSLog(@"[XhsPlus] 检测到双击");
        // 在调用 showSettings 时，附加当前的暗黑模式状态作为参数
        [CustomSettingsViewController showSettings];
    } else {
        NSLog(@"[XhsPlus] 检测到单击");
        lastClickTime = currentTime;
        %orig;
        return;
    }
}

%end

@interface XYTabBar : UIView
@property (nonatomic, copy) NSArray *tabs;
@end

%hook XYTabBar

- (void)layoutSubviews {
    %orig;
    
    if (self.subviews.count >= 3) {
        BOOL removeShoppingTab = [[NSUserDefaults standardUserDefaults] boolForKey:@"remove_tab_shopping"];
        BOOL removePostTab = [[NSUserDefaults standardUserDefaults] boolForKey:@"remove_tab_post"];
        
        if (removeShoppingTab && removePostTab) {
            [[self.subviews objectAtIndex:1] removeFromSuperview];
            [[self.subviews objectAtIndex:1] removeFromSuperview];
        } else {
            if (removeShoppingTab) {
                [[self.subviews objectAtIndex:1] removeFromSuperview];
            }
            if (removePostTab) {
                [[self.subviews objectAtIndex:2] removeFromSuperview];
            }
        }
    }

    CGFloat tabWidth = CGRectGetWidth(self.bounds) / self.subviews.count;
    CGFloat xPosition = 0;
    
    for (UIView *subview in self.subviews) {
        CGRect frame = subview.frame;
        frame.origin.x = xPosition;
        frame.size.width = tabWidth;
        subview.frame = frame;
        
        xPosition += tabWidth;
    }
}

%end

%hook XYPHMediaSaveConfig

- (void)setDisableWatermark:(_Bool)arg1 {
    BOOL removeWatermark = [[NSUserDefaults standardUserDefaults] boolForKey:@"remove_save_watermark"];
    %orig(removeWatermark);
}

- (void)setDisableSave:(_Bool)arg1 {
    BOOL forceSaveMedia = [[NSUserDefaults standardUserDefaults] boolForKey:@"force_save_media"];
    if (forceSaveMedia) {
        %orig(NO);
    } else {
        %orig(arg1);
    }
}
%end
