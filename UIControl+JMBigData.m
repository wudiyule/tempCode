//
//  UIControl+JMBigData.m
//  JMBigDataKit
//
//  Created by 马克吐温° on 2019/8/22.
//

#import "UIControl+JMBigData.h"
#import "JMBigDataCommonModel.h"
#import "JMBigDataManager.h"
#import "JMBigDataToolHeader.h"
#import "UIView+JMBigData.h"
@interface UIControl ()


@end

@implementation UIControl (JMBigData)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        jm_runtime_methodSwizzling(@selector(sendAction:to:forEvent:), @selector(jm_sendAction:to:forEvent:))
    });
}

- (BOOL)isInitiativeToCall{
    return [jm_runtime_getAssociatedObject integerValue];
}

- (void)setIsInitiativeToCall:(BOOL)isInitiativeToCall{
    return jm_runtime_setAssociatedObject(@selector(isInitiativeToCall), @(isInitiativeToCall));
}

- (void)jm_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    [self jm_sendAction:action to:target forEvent:event];
    if (self.isInitiativeToCall) {
        kLog(@"已经主动触发，不在自动触发");
        return;
    }
    for (Class class in [JMBigDataManager shareJMBigDataManager].excludedControlClasses) {
        if ([self isKindOfClass:class]) {
            return;
        }
    }
    
    self.jm_accessibilityIdentifier = [NSString getTreePathWithControl:self];

    JMBigDataCommonModel *model = [[JMBigDataCommonModel alloc] init];

    model.elementId = self.jm_accessibilityIdentifier;
    
    model.elementName = self.uniqueIdentifierInWindow;
    
    if ([JMBigDataManager shareJMBigDataManager].debugMode) {
        kLog(@"===记录到自动埋点数据，elementId：%@，componentName：%@", model.elementId, model.elementName);
    }

    model.eventType =  BigDataLogTypeClick;
    
    [[JMBigDataManager shareJMBigDataManager] jm_swizzingEventLogWithModel:model];
}


@end
