//
//  JMBigDataDataBaseHelper.h
//  JMBigDataKit
//
//  Created by 马克吐温° on 2019/8/22.
//

#import <Foundation/Foundation.h>
#import "JMBigDataCommonModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface JMBigDataDataBaseHelper : NSObject

/**
 插入数据库数据

 @param model model
 @param handlerBlock 回调
 */
- (void)insertToRealmDataWithModel:(JMBigDataCommonModel *)model handlerBlock:(void(^)(void))handlerBlock;

/**
 搜索数据库数据

 @param maxNum 最大数量
 @param handlerBlock 回调
 */
- (void)searchWithModelMaxNum:(NSInteger)maxNum handlerBlock:(void(^)(NSMutableArray *modelList, NSMutableArray <NSString *>*primaryKeyList))handlerBlock;

/**
 删除数据库数据

 @param primaryKeyList 主键数组
 */
- (void)deleteToRealmDataWithPrimaryKeyList: (NSArray <NSString *>*)primaryKeyList;

@end

NS_ASSUME_NONNULL_END
