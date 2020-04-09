//
//  UAESCoreBlueManager.h
//  UAESBleDemo
//
//  Created by lvzhao on 2020/4/7.
//  Copyright © 2020 lvzhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>



NS_ASSUME_NONNULL_BEGIN


#define kUaesCentralManagerIdentifier @"kUaesCentralManagerIdentifier"


@interface UAESCoreBlueManager : NSObject

//特定的服务_UUID
@property (nonatomic,strong) NSString *serviceID;

//特定的特征_UUID
@property (nonatomic,strong) NSString *characteristicID;

//蓝牙中心管理者
@property (nonatomic,strong) CBCentralManager *centralManager;

//搜索到的外设
@property (nonatomic,strong) CBPeripheral *peripheral;

//写入特征
@property (nonatomic,strong) CBCharacteristic *writeDataCharacteristic;

/**
 创建 UAESCoreBlueManager 对象
 */
+ (instancetype)sharedInstance;


/**
 检测蓝牙访问权限, 组好是进入APP就调用, 检测权限
 @param completion block回调 response 成功 失败
 */
+ (void)checkBlueAuthorityCompletion:(void(^)(BOOL response))completion;


/**
开始扫描外设
 */
- (void)startScanForPeripherals;


@end

NS_ASSUME_NONNULL_END
