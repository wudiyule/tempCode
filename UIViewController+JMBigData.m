//
//  UIViewController+JMBigData.m
//  JMBigDataKit
//
//  Created by 马克吐温° on 2019/8/22.
//

#import "UIViewController+JMBigData.h"
#import "JMBigDataMacro.h"
#import "JMBigDataManager.h"
@implementation UIViewController (JMBigData)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        jm_runtime_methodSwizzling(@selector(viewWillAppear:), @selector(jm_viewWillAppear:))
        
        jm_runtime_methodSwizzling(@selector(viewDidAppear:), @selector(jm_viewDidAppear:))
                
        jm_runtime_methodSwizzling(@selector(presentViewController:animated:completion:), @selector(jm_presentViewController:animated:completion:))
    });
}

- (void)jm_viewWillAppear:(BOOL)animated{
    [self jm_viewWillAppear:animated];
    
}

- (void)jm_viewDidAppear:(BOOL)animated{
    [self jm_viewDidAppear:animated];
    Class selfClass = [self class];
    if (![[NSBundle bundleForClass:selfClass] isEqual:[NSBundle mainBundle]]) {
        return;
    }
    for (Class class in [JMBigDataManager shareJMBigDataManager].excludedViewControllerClasses) {
        if ([self isKindOfClass:class]) {
            return;
        }
    }
    
    JMBigDataCommonModel *model = [[JMBigDataCommonModel alloc] init];
    
    model.screenName = NSStringFromClass(self.class);

    model.eventType = BigDataLogTypePage;
    
    [[JMBigDataManager shareJMBigDataManager] jm_swizzingEventLogWithModel:model];
}

- (void)jm_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion{
    [self jm_presentViewController:viewControllerToPresent animated:flag completion:completion];
}

@end
