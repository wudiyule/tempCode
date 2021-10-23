//
//  UIControl+JMBigData.h
//  JMBigDataKit
//
//  Created by 马克吐温° on 2019/8/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIControl (JMBigData)

/**是否主动触发（主动触发后，hook函数内不再触发）*/
@property (nonatomic, assign)BOOL isInitiativeToCall;

@end

NS_ASSUME_NONNULL_END
