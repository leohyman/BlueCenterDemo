//
//  AppDelegate.m
//  BlueCenterDemo
//
//  Created by lvzhao on 2020/4/9.
//  Copyright © 2020 lvzhao. All rights reserved.
//

#import "AppDelegate.h"
#import "UAESCoreBlueManager.h"




#define SERVICE_UUID @"8D54ECDE-7A78-4B62-9F44-780A0588B5CE"
#define CHARACTERISTIC_UUID @"04392C1C-00AF-4A29-B8BB-E02CEEC52C43"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    //检测蓝牙权限
    [UAESCoreBlueManager checkBlueAuthorityCompletion:^(BOOL response) {
        
    }];
    //搜索特定的服务ID
    [UAESCoreBlueManager sharedInstance].serviceID = SERVICE_UUID;
    [UAESCoreBlueManager sharedInstance].characteristicID = CHARACTERISTIC_UUID;
    
    NSArray *identifiers = launchOptions[UIApplicationLaunchOptionsBluetoothCentralsKey];
    if(identifiers.count > 0){
        for (NSString *identifier in identifiers){
            if ([identifier isEqualToString:kUaesCentralManagerIdentifier]) {
                
                //最关键的, 这里什么时候有值. 连接成功以后, 点击按钮, 等带蓝牙外设自动连接,进入APP这时就有值了.. 很关键
                //最关键的, 这里什么时候有值. 连接成功以后, 点击按钮, 等带蓝牙外设自动连接,进入APP这时就有值了.. 很关键
                //最关键的, 这里什么时候有值. 连接成功以后, 点击按钮, 等带蓝牙外设自动连接,进入APP这时就有值了.. 很关键

                //因为最低兼容8.0 偷懒直接用UIAlertView...
                UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"identifiers 有值了" message:identifier delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                [alterView show];
                //开始扫描
                [[UAESCoreBlueManager sharedInstance] startScanForPeripherals];
            }
        }
    }
    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
