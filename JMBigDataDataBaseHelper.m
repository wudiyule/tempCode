//
//  JMBigDataDataBaseHelper.m
//  JMBigDataKit
//
//  Created by 马克吐温° on 2019/8/22.
//

#import "JMBigDataDataBaseHelper.h"
#import <Realm/Realm.h>
#import "JMBigDataToolHeader.h"

const char *bigDataQueueName2 = "bigDataQueueName2";

@interface JMBigDataDataBaseHelper ()

@property (nonatomic, strong)RLMRealm *realm;

@property (nonatomic, strong)RLMRealmConfiguration *config;

@end

@implementation JMBigDataDataBaseHelper

- (instancetype)init{
    self = [super init];
    if (self) {
        [self initDataBase];
    }
    return self;
}

- (RLMRealm *)realm{
    return [RLMRealm realmWithConfiguration:self.config error:nil];
}

- (void)initDataBase{
    //默认配置
    self.config = [RLMRealmConfiguration defaultConfiguration];
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)  lastObject];
    self.config.fileURL = [NSURL URLWithString:[file stringByAppendingPathComponent:@"JMBigDataKit.realm"]];
    //设置版本号
    self.config.schemaVersion = 2;
    //数据库迁移回调
    self.config.migrationBlock = ^(RLMMigration * _Nonnull migration, uint64_t oldSchemaVersion) {
        if (oldSchemaVersion < 2) {
            [migration enumerateObjects:JMBigDataCommonModel.className block:^(RLMObject * _Nullable oldObject, RLMObject * _Nullable newObject) {
                newObject[@"elementName"] = @"";
            }];
        }
    };
    //创建realm对象
    self.config.objectClasses = @[JMBigDataCommonModel.self];
}

- (void)insertToRealmDataWithModel:(JMBigDataCommonModel *)model handlerBlock:(void(^)(void))handlerBlock{
    [self.realm transactionWithBlock:^{
        [self.realm addObject:model];
        handlerBlock();
    }];
}

- (void)searchWithModelMaxNum:(NSInteger)maxNum handlerBlock:(void (^)(NSMutableArray * _Nonnull, NSMutableArray<NSString *> * _Nonnull))handlerBlock{
    RLMResults<JMBigDataCommonModel *> *results = [[JMBigDataCommonModel allObjectsInRealm:self.realm] sortedResultsUsingKeyPath:@"eventTime" ascending:YES];
    if (results.count >= maxNum) {
        NSMutableArray *array = [NSMutableArray array];
        NSMutableArray *primaryKeyArray = [NSMutableArray arrayWithCapacity:maxNum];
        for (int i = 0; i < maxNum; i++) {
            NSUInteger objectIndex = results.count - i - 1;
            JMBigDataCommonModel *model = results[objectIndex];
            model.customizeValue = [NSData jm_conversionDataToDic:model.saveCustomizeValue];
            [primaryKeyArray addObject:model.myPrimaryKey];
            [array addObject:model];
        }
        handlerBlock(array, primaryKeyArray);
    }
}

- (void)deleteToRealmDataWithPrimaryKeyList: (NSArray <NSString *>*)primaryKeyList {
    // 把数据库里面的JMBigDataCommonModel按照eventTime正序排好拿出来
    [self.realm transactionWithBlock:^{
        // 按照primaryKey唯一值进行删除，进行已上传数据清理
        [self.realm deleteObjects:[JMBigDataCommonModel objectsInRealm:self.realm where:@"myPrimaryKey IN %@", primaryKeyList]];
    }];
}

@end
