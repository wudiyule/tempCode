//
//  UIGestureRecognizer+JMBigData.m
//  JMBigDataKit_Example
//
//  Created by 马克吐温° on 2019/9/2.
//  Copyright © 2019 马克吐温°. All rights reserved.
//

#import "UIGestureRecognizer+JMBigData.h"
#import "JMBigDataToolHeader.h"
#import "JMBigDataCommonModel.h"
#import "JMBigDataManager.h"
#import "UIView+JMBigData.h"

@implementation UIGestureRecognizer (JMBigData)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        jm_runtime_methodSwizzling(@selector(addTarget:action:), @selector(jm_addTarget:action:));
    });
}

- (void)jm_addTarget:(id)target action:(SEL)action{
    [self jm_addTarget:target action:action];

    [target aspect_hookSelector:action withOptions:AspectPositionAfter usingBlock:^{
        
        JMBigDataCommonModel *model = [[JMBigDataCommonModel alloc] init];
        
        UIView *view = self.view;
        model.elementId = [NSString getTreePathWithControl: view];
        
        model.elementName = view.uniqueIdentifierInWindow;
        
        if ([JMBigDataManager shareJMBigDataManager].debugMode) {
            kLog(@"===记录到自动埋点数据，elementId：%@，componentName：%@", model.elementId, model.elementName);
        }
        
        model.eventType =  BigDataLogTypeClick;

        [[JMBigDataManager shareJMBigDataManager] jm_swizzingEventLogWithModel:model];

    } error:nil];
}

@end
