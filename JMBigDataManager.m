//
//  JMBigDataManager.m
//  JMBigDataKit
//
//  Created by 马克吐温° on 2019/8/22.
//

#import "JMBigDataManager.h"
#import "JMBigDataDataBaseHelper.h"
#import "JMBigDataNetworkManager.h"
#import "UIControl+JMBigData.h"
#import "JMBigDataToolHeader.h"
#import "JMBigDataNetworkReachability.h"
#import "JMBigDataNetworkManager.h"

const char *bigDataQueueName = "bigDataQueueName";

const char *networkCompleteQueue = "networkCompleteQueue";

@interface JMBigDataManager ()

@property (nonatomic, strong)JMBigDataDataBaseHelper *dataBaseHelper;

@property (nonatomic, strong)dispatch_queue_t bigDataQueu;

@property (nonatomic, strong)dispatch_queue_t completeQueue;
@end

@implementation JMBigDataManager

JMSingleMacroM(JMBigDataManager)

- (instancetype)init{
    self = [super init];
    if (self) {
        _excludedViewControllerClasses = [NSMutableArray arrayWithArray:@[[UINavigationController class], [UITabBarController class], [UIPageViewController class]]];
        _excludedControlClasses = [NSMutableArray arrayWithArray:@[[UITextField class]]];
    }
    return self;
}

- (JMBigDataDataBaseHelper *)dataBaseHelper{
    if (!_dataBaseHelper) {
        _dataBaseHelper = [[JMBigDataDataBaseHelper alloc] init];
    }
    return _dataBaseHelper;
}

- (JMBigDataManagerService *)managerService{
    if (!_managerService) {
        _managerService = [[JMBigDataManagerService alloc] init];
    }
    return _managerService;
}

- (dispatch_queue_t)bigDataQueu{
    if (!_bigDataQueu) {
        _bigDataQueu = dispatch_queue_create(bigDataQueueName, DISPATCH_QUEUE_SERIAL);
    }
    return _bigDataQueu;
}

- (dispatch_queue_t)completeQueue{
    if (!_completeQueue) {
        _completeQueue = dispatch_queue_create(networkCompleteQueue, DISPATCH_QUEUE_SERIAL);
    }
    return _completeQueue;
}

- (void)jm_pageEventWithDynamicResourceType:(JMBigDataDynamicResourceType)dynamicResourceType customizeValue:(NSDictionary *)customizeValue{

    @weakify(self)
    [self.managerService improveDataAssemblyHandler:^(JMBigDataCommonModel * _Nonnull saveModel) {
        @strongify(self)
        saveModel.saveCustomizeValue = [NSData jm_conversionDicToData:customizeValue ? customizeValue : [NSDictionary dictionary]];
        
        saveModel.eventType = BigDataLogTypeCustom;

        saveModel.dynamicResourceType = dynamicResourceType;
        
        [self bigDataEventLogWithModel:saveModel];
    } model:[[JMBigDataCommonModel alloc] init]];
}

- (void)jm_clickEventWithObject:(UIControl *)object clickId:(NSString *)clickId dynamicResourceType:(JMBigDataDynamicResourceType)dynamicResourceType customizeValue:(NSDictionary *)customizeValue{
    
    object.isInitiativeToCall = true;
   
    @weakify(self)
    [self.managerService improveDataAssemblyHandler:^(JMBigDataCommonModel * _Nonnull saveModel) {
        @strongify(self)
        saveModel.saveCustomizeValue = [NSData jm_conversionDicToData:customizeValue ? customizeValue : [NSDictionary dictionary]];
        
        saveModel.elementId = clickId;
        
        saveModel.eventType = BigDataLogTypeCustom;
        
        saveModel.dynamicResourceType = dynamicResourceType;
        
        [self bigDataEventLogWithModel:saveModel];
    } model:[[JMBigDataCommonModel alloc] init]];
}

- (void)jm_swizzingEventLogWithModel:(JMBigDataCommonModel *)model{
    @weakify(self)
    if (self.jmAllburiedPointSwitch) {
        return;
    }
    [self.managerService improveDataAssemblyHandler:^(JMBigDataCommonModel * _Nonnull saveModel) {
        @strongify(self)
        [self bigDataEventLogWithModel:saveModel];
    } model:model];
}

- (void)bigDataEventLogWithModel:(JMBigDataCommonModel *)model{
    @weakify(self);
    dispatch_async(self.bigDataQueu, ^{
        //进行数据插入
        [self.dataBaseHelper insertToRealmDataWithModel:model handlerBlock:^{
            @strongify(self)
            //进行数据搜索
            [self.dataBaseHelper searchWithModelMaxNum:self.managerService.maxUploadNum handlerBlock:^(NSMutableArray * _Nonnull modelList, NSMutableArray <NSString *>* _Nonnull primaryKeyList) {
                @strongify(self)
                //指定AFN回调
                [JMBigDataNetworkManager shareJMBigDataNetworkManager].sessionManager.completionQueue = dispatch_queue_create(bigDataQueueName, DISPATCH_QUEUE_SERIAL);
                
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                
                //进行数据上传
                [[JMBigDataNetworkManager shareJMBigDataNetworkManager]     bigDataNormalRequestWithParameter:modelList success:^(NSDictionary * _Nonnull response) {
                    @strongify(self)
                    
                    dispatch_semaphore_signal(semaphore);
                    
                    //进行数据删除
                    [self.dataBaseHelper deleteToRealmDataWithPrimaryKeyList:primaryKeyList];
                } failure:^(NSError * _Nonnull error) {
                    dispatch_semaphore_signal(semaphore);
                }];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }];
        }];
    });
}

- (void)jm_registerDebugURL:(NSString *)debugURL releaseURL:(NSString *)releaseURL{
    #ifndef __OPTIMIZE__
    [JMBigDataNetworkManager shareJMBigDataNetworkManager].bigDateURL = debugURL;
    #else
    [JMBigDataNetworkManager shareJMBigDataNetworkManager].bigDateURL = releaseURL;
    #endif
}

@end
