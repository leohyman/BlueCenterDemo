//
//  UAESCoreBlueManager.m
//  UAESBleDemo
//
//  Created by lvzhao on 2020/4/7.
//  Copyright © 2020 lvzhao. All rights reserved.
//

#import "UAESCoreBlueManager.h"

@interface UAESCoreBlueManager () <CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,assign) NSInteger valueCode;

@end

@implementation UAESCoreBlueManager
@synthesize serviceID = _serviceID;
@synthesize characteristicID = _characteristicID;


//利用单例,
static UAESCoreBlueManager *blueManager = nil;
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        blueManager = [[UAESCoreBlueManager alloc] init];
    });
    
    return blueManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        //CBCentralManagerOptionRestoreIdentifierKey   app中加入状态的保存和恢复功能的方式很简单
        //CBCentralManagerOptionShowPowerAlertKey布尔值，表示如果当前蓝牙没打开，是否弹出alert框
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue() options:@{CBCentralManagerOptionRestoreIdentifierKey:kUaesCentralManagerIdentifier,
            CBCentralManagerOptionShowPowerAlertKey:@(1)}];
    }
    return self;
}
#pragma makr - CBCentralManagerDelegate
/*
 记录之前连接的设备
 */
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict{
    NSArray *peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey];
    for (CBPeripheral *peripheral in peripherals) {
        NSLog(@"做点事情--%s   peripheral.uuid =  %@",__func__,peripheral.identifier);
    }
       
    for (CBPeripheral *peripheral in peripherals) {
        self.peripheral = peripherals.lastObject;
        NSDateFormatter *formatter =[[NSDateFormatter alloc]init];

        //设置日期格式

        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

        //当前日期

        NSDate *currentDate = [NSDate date];

        NSString *currentDateString = [formatter stringFromDate:currentDate];

        NSLog(@"%@",currentDateString);

        UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"连接之前的设备" message:currentDateString delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alterView show];
        [self.centralManager connectPeripheral:peripherals.lastObject options:@{CBConnectPeripheralOptionNotifyOnNotificationKey:@(1)}];
    }

        
    
}

/*!
 *检测蓝牙状态, 实时回调
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
    switch (central.state) {
          case CBCentralManagerStatePoweredOff:{
              NSLog(@"蓝牙没有开启，在设置中打开蓝牙");
              break;
          }
          case CBCentralManagerStateUnknown:{
              NSLog(@"未知蓝牙状态");
              break;
          }

          case CBCentralManagerStateResetting:{
              NSLog(@"蓝牙重置中");
              break;
          }

          case CBCentralManagerStateUnauthorized:{
              NSLog(@"未授权");
              break;
          }
          case CBCentralManagerStateUnsupported:{
              NSLog(@"当前设备不支持蓝牙");
              break;
          }
          case CBCentralManagerStatePoweredOn:{
              NSLog(@"蓝牙开启.开始扫描");
              [self startScanForPeripherals];
              break;

          }
          default:
              break;
      }
}

/**
开始扫描外设
 */
- (void)startScanForPeripherals{
    if(self.centralManager.state == CBCentralManagerStatePoweredOn){
        //CBCentralManagerScanOptionAllowDuplicatesKey值是NSNumber,默认值为NO表示不会重复扫描已经发现的设备,如需要不断获取最新的信号强度RSSI所以一般设为YES了
        [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:self.serviceID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@(1)}];
    } else {
        
        NSLog(@"蓝牙有问题.暂时不能扫描");
    }
}

#pragma mark - CBCentralManagerDelegate
// 中心设备发现外设的时候调用的方法
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI{

    NSLog(@"搜索到外设的UUID === %@  信号量是  === %@",peripheral.identifier,RSSI);
    self.peripheral = peripheral;
    /**
     进行连接
     CBConnectPeripheralOptionNotifyOnNotificationKey: 这是一个NSNumber(Boolean)，表示系统会为获得的外设收到通知后显示一个提示，这个时候应用是被挂起的。
     */
    [self.centralManager connectPeripheral:self.peripheral options:@{CBConnectPeripheralOptionNotifyOnNotificationKey:@(1)}];
}



/** 连接外设失败*/
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"连接到外设 失败！名字：%@ 错误信息：%@", [peripheral name], [error localizedDescription]);
    
    
    UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"连接外设失败" message:peripheral.name delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alterView show];
    
    [self.centralManager connectPeripheral:self.peripheral options:@{CBConnectPeripheralOptionNotifyOnNotificationKey:@(1)}];

}

// 中心设备与已连接的外设断开连接时调用的方法
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    
    
    //先断开
    [self.centralManager cancelPeripheralConnection:self.peripheral];
    UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"中心设备与已连接的外设断开连接时调用的方法" message:peripheral.name delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
          [alterView show];
    
    NSLog(@"中心设备与已连接的外设断开连接时调用的方法");
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:self.serviceID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@(1)}];
}

/*!
 *  @method peripheral:didModifyServices:
 *
 *  @param peripheral     需要更新的设备
 *  @param invalidatedServices  The services that have been invalidated
 *
 *  @discussion         该方法触发当设备的服务改变时候

 *  服务可以被重新发现通过discoverServices: 方法
 */
- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices{
    
    
    
}

/**
 连接外设成功
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    //停止扫描
    [central stopScan];
    NSLog(@"连接外设成功！%@", peripheral.name);
    [peripheral setDelegate:self];
    //获取设备的服务，传nil代表获取所有的服务
    [peripheral discoverServices:@[[CBUUID UUIDWithString:self.serviceID]]];
    
    
    self.valueCode = 0;
    [self.timer invalidate];
    self.timer = nil;
    self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(startSendValue) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}



- (void)startSendValue{
    
    self.valueCode ++;
    
    if(self.valueCode % 10 == 0){
        if(self.writeDataCharacteristic && self.peripheral.state == CBPeripheralStateConnected){
            
            NSString *valueCode = [NSString stringWithFormat:@"数据====:%ld",(long)self.valueCode];
            // 用NSData类型来写入
            NSData *data = [valueCode dataUsingEncoding:NSUTF8StringEncoding];
            // 根据上面的特征self.characteristic来写入数据
            [self.peripheral writeValue:data forCharacteristic:self.writeDataCharacteristic type:CBCharacteristicWriteWithResponse];
            NSLog(@"发送 %@",valueCode);
        }
    }
    
}


#pragma mark - CBPeripheralDelegate
/**
发现服务
*/
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    // 遍历出外设中所有的服务
    for (CBService *service in peripheral.services) {
        NSLog(@"所有的服务：%@",service);
    }
    // 这里仅有一个服务，所以直接获取
    CBService *service = peripheral.services.lastObject;
    // 根据UUID寻找服务中的特征
    [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:self.characteristicID]] forService:service];

}

/** 发现特征回调 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    // 遍历出所需要的特征
    for (CBCharacteristic *characteristic in service.characteristics) {
        // 从外设开发人员那里拿到不同特征的UUID，不同特征做不同事情，比如有读取数据的特征，也有写入数据的特征
        NSLog(@"所有特征：%lu", (unsigned long)characteristic.properties);
    }
    
    if(service.characteristics.count){
        // 这里只获取一个特征，写入数据的时候需要用到这个特征
           self.writeDataCharacteristic = service.characteristics.lastObject;
           
           // 直接读取这个特征数据，会调用didUpdateValueForCharacteristic
           [peripheral readValueForCharacteristic:self.writeDataCharacteristic];
           
           // 订阅通知
           [peripheral setNotifyValue:YES forCharacteristic:self.writeDataCharacteristic];
    }
}

/**
 搜索 Characteristic
 */
//发特征值描述
- (void)discoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic{
    
    NSLog(@"所有特征描述：%@", characteristic.service);
    
}

/**
 接收到数据回调
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    // 拿到外设发送过来的数据
    NSData *data = characteristic.value;
    NSString *value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"----- 外设发过来的数据 %@",value);
}






/**
 订阅状态的改变
 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"订阅失败");
        NSLog(@"%@",error);
    }
    if (characteristic.isNotifying) {
        NSLog(@"订阅成功");
    } else {
        NSLog(@"取消订阅");
    }
}




/**
 写入数据回调
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    NSLog(@"写入成功");
    
}






/**
访问蓝牙权限
创建蓝牙管理者
回调蓝牙的状态
当打开的状态才可以扫描设备
连接外设. 停止扫描
设置外设代理
 
 
 */







#pragma mark - SET
//服务ID
- (void)setServiceID:(NSString *)serviceID{
    _serviceID = serviceID;
}


//特征ID
- (void)setCharacteristicID:(NSString *)characteristicID{
    _characteristicID = characteristicID;
}


#pragma mark - GET
//服务ID
- (NSString *)serviceID{
    return _serviceID;
}

//特征ID
- (NSString *)characteristicID{
    return _characteristicID;
}




/**
 检测蓝牙访问权限
 */
+ (void)checkBlueAuthorityCompletion:(void(^)(BOOL response))completion{
    CBPeripheralManagerAuthorizationStatus authorizetionStatus = [CBPeripheralManager authorizationStatus];
    if(authorizetionStatus == CBPeripheralManagerAuthorizationStatusNotDetermined){
        //授权状态不确定 未知
        NSLog(@"蓝牙授权状态未知");
        if(completion){
            completion(NO);
        }
    } else if((authorizetionStatus == CBPeripheralManagerAuthorizationStatusRestricted)
         ||(authorizetionStatus == CBPeripheralManagerAuthorizationStatusDenied)){
        //授权状态是受限制的  ||授权状态是拒绝的 （未授权）
        NSLog(@"授权状态是受限制的或者是未授权的");
        if(completion){
            completion(NO);
        }
    } else {
        //授权状态是已授权
        NSLog(@"授权状态是已授权");
        if(completion){
           completion(YES);
        }
    }
}






@end
