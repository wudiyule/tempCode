//
//  JMBigDataManagerService.h
//  JMBigDataKit_Example
//
//  Created by 马克吐温° on 2019/8/27.
//  Copyright © 2019 马克吐温°. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMBigDataCommonModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 日志类型
 
 - BigDataLogTypeClick:  点击日志
 - BigDataLogTypePage:   页面日志
 - BigDataLogTypeCustom: 自定义日志
 */
typedef NS_ENUM(NSUInteger, JMBigDataLogType) {
    BigDataLogTypeClick       = 1,
    BigDataLogTypePage        = 2,
    BigDataLogTypeCustom      = 3,
};

/**
 业务类型
 - BigDataBanaerResourceType: 广告业务
 - BigDataProductResourceType: 商品业务
 - BigDataCategoryResourceType: 分类业务
 - BigDataOrderResourceType: 订单业务
 */
typedef NS_ENUM(NSUInteger, JMBigDataDynamicResourceType) {
    BigDataBanaerResourceType        = 1,
    BigDataProductResourceType       = 2,
    BigDataCategoryResourceType      = 3,
    BigDataOrderResourceType         = 4,
};

@interface JMBigDataManagerService : NSObject

/**最大上传条数*/
@property (nonatomic, assign)NSInteger maxUploadNum;

/**会话最大间隔时间*/
@property (nonatomic, assign)NSInteger maxIntervalTime;

/**一次会话ID*/
@property (nonatomic, copy)NSString *sessionId;

/**用户ID*/
@property (nonatomic, copy)NSString *userID;

/**上一页面名称*/
@property (nonatomic, copy)NSString *saveReferPage;

/**web页面URL*/
@property (nonatomic, copy)NSString *lastWebURL;

/**
 整合数据

 @param handler 处理器
 */
- (void)improveDataAssemblyHandler:(void (^)( JMBigDataCommonModel *_Nonnull saveModel))handler model:(JMBigDataCommonModel *_Nonnull)model;

@end

NS_ASSUME_NONNULL_END
