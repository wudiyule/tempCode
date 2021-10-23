//
//  JMBigDataManagerService.m
//  JMBigDataKit_Example
//
//  Created by 马克吐温° on 2019/8/27.
//  Copyright © 2019 马克吐温°. All rights reserved.
//

#import "JMBigDataManagerService.h"
#import "JMBigDataPostModel.h"
#import "JMBigDataToolHeader.h"
#import "JMLocationManager.h"

@interface JMBigDataManagerService ()

/*
 记录的上一次埋点的时间
 */
@property (nonatomic,strong)NSDate *saveCurrentTime;

/**经度*/
@property (nonatomic, assign)double latitude;

/**纬度*/
@property (nonatomic, assign)double longitude;

/**网络状态*/
@property (nonatomic, copy)NSString *networkType;

@end

@implementation JMBigDataManagerService

- (instancetype)init{
    self = [super init];
    if (self) {
        
        self.sessionId = [NSString jm_getRandomId];

        @weakify(self);
        [[JMLocationManager shareJMLocationManager] startLocationMonitoringSuccess:^(double latitude, double longitude) {
            @strongify(self);
            self.latitude = latitude;
            self.longitude = longitude;
        }];
        
        [[JMBigDataNetworkReachability shareJMBigDataNetworkReachability] startNetworkSnifWithCallback:^(JMNetworkState networkState, NSString * _Nonnull networkName) {
            @strongify(self);
            self.networkType = networkName;
        }];
        
    }
    return self;
}

- (NSInteger )maxUploadNum{
    return (_maxUploadNum == 0 ? 100 : _maxUploadNum);
}

- (NSInteger)maxIntervalTime{
    return (_maxIntervalTime == 0 ? 5 : _maxIntervalTime);
}

- (void)improveDataAssemblyHandler:(void (^)( JMBigDataCommonModel * _Nonnull saveModel))handler model:(JMBigDataCommonModel * _Nonnull)model{
      
    NSDate *now = [NSDate date];
    NSInteger distance = [now timeIntervalSinceDate:self.saveCurrentTime];
    if (distance > self.maxIntervalTime) {
        self.sessionId = [NSString jm_getRandomId];
    }
    self.saveCurrentTime = now;
    
    model.sessionId = self.sessionId;
    
    model.latitude = self.latitude;
    
    model.longitude = self.longitude;
    
    model.networkType = self.networkType;
    
    model.referPage = self.saveReferPage;
    
    model.userId = self.userID;
    
    model.screenName = NSStringFromClass([[UIViewController jm_currentDisplayController] class]);
    
    self.saveReferPage =  model.screenName;

    handler(model);
}

@end
