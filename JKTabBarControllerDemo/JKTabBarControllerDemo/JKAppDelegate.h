//
//  JKAppDelegate.h
//  JKTabBarControllerDemo
//
//  Created by Jackie CHEUNG on 13-6-7.
//  Copyright (c) 2013年 Weico. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JKViewController,JKTabBarController;
@interface JKAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) JKTabBarController *tabBarController;

@end
