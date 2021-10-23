//
//  JMBigDataManager.h
//  JMBigDataKit
//
//  Created by 马克吐温° on 2019/8/22.
//

#import <Foundation/Foundation.h>
#import "JMBigDataMacro.h"
#import "JMBigDataCommonModel.h"
#import "JMBigDataManagerService.h"
NS_ASSUME_NONNULL_BEGIN
@interface JMBigDataManager : NSObject
JMSingleMacroH(JMBigDataManager)

@property (nonatomic, strong)JMBigDataManagerService *managerService;

/// 全埋点开关（打开则只记录手动埋点）
@property (nonatomic, assign)BOOL jmAllburiedPointSwitch;

/*
 是否打开日志
 */
@property (nonatomic,assign)BOOL debugMode;

/*
 被排除的页面类型名称，非mainBundle下的类型，以及此数组内的类型，都会被排除在外，不做记录
 */
@property (nonatomic,copy)NSMutableArray <Class>*excludedViewControllerClasses;

/*
 被排除的UIControl的类型
 */
@property (nonatomic,copy)NSMutableArray <Class> *excludedControlClasses;


/// 注册大数据上传URL
/// @param debugURL 调试URL
/// @param releaseURL 发布URL
- (void)jm_registerDebugURL:(NSString *)debugURL releaseURL:(NSString *)releaseURL;

/**
 自定义页面事件

 @param customizeValue 自定义业务字段（根据大数据文档填写）
 */
- (void)jm_pageEventWithDynamicResourceType:(JMBigDataDynamicResourceType)dynamicResourceType customizeValue:(NSDictionary *)customizeValue;


/**
 自定义点击事件

 @param object 点击对象
 @param clickId 唯一标识（数据端定）
 @param dynamicResourceType 业务种类
 @param customizeValue 自定义业务字段（根据大数据文档填写）
 */
- (void)jm_clickEventWithObject:(UIControl *)object clickId:(NSString *)clickId dynamicResourceType:(JMBigDataDynamicResourceType)dynamicResourceType customizeValue:(NSDictionary *)customizeValue;


/**
 SDK内部调用，外部慎用

 @param model model
 */
- (void)jm_swizzingEventLogWithModel:(JMBigDataCommonModel *)model;

@end

NS_ASSUME_NONNULL_END
