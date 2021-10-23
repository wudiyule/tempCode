//
//  AppDelegate+JMBigData.m
//  JMBigDataKit
//
//  Created by 马克吐温° on 2019/8/22.
//  Copyright © 2019 马克吐温°. All rights reserved.
//

#import "AppDelegate+JMBigData.h"
#import "JMBigDataToolHeader.h"

@implementation UIApplication(JMBigData)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        jm_runtime_methodSwizzling(@selector(setDelegate:), @selector(jm_setDelegate:))
        
        jm_runtime_methodSwizzling(@selector(sendEvent:), @selector(jm_sendEvent:))
    });
}

- (void)jm_setDelegate:(id<UIApplicationDelegate>)delegate {
    [self jm_setDelegate:delegate];
    
    [[self.delegate class] aspect_hookSelector:@selector(application:didFinishLaunchingWithOptions:) withOptions:AspectPositionAfter usingBlock:^{} error:nil];
    
    [[self.delegate class] aspect_hookSelector:@selector(applicationWillResignActive:) withOptions:AspectPositionAfter usingBlock:^{} error:nil];

    [[self.delegate class] aspect_hookSelector:@selector(applicationDidBecomeActive:) withOptions:AspectPositionAfter usingBlock:^{} error:nil];
}

- (void)jm_sendEvent:(UIEvent *)event{
    [self jm_sendEvent:event];
    [[NSNotificationCenter defaultCenter] postNotificationName:uesr_operation_notice object:nil];
}

@end
