//
//  JKAppDelegate.m
//  JKTabBarControllerDemo
//
//  Created by Jackie CHEUNG on 13-6-7.
//  Copyright (c) 2013年 Weico. All rights reserved.
//

#import "JKAppDelegate.h"
#import "JKTabBarController.h"
#import "JKViewController.h"
#import "JKTabBarItem.h"

@implementation JKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    JKTabBarController *tabBarController = [[JKTabBarController alloc] init];
    self.tabBarController = tabBarController;
    tabBarController.selectedControllerNavigationItem = YES;
//    tabBarController.shouldAdjustSelectedViewContentInsets = YES;
    
    UIViewController *redViewController = [[JKViewController alloc] initWithNibName:@"JKViewController" bundle:nil];
    redViewController.tabBarItem_jk = [[JKTabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"home_tab_icon_1"]];
    redViewController.view.backgroundColor = [UIColor redColor];
    redViewController.title = @"test";
    
    UIViewController *blueViewController = [[JKViewController alloc] initWithNibName:@"JKViewController" bundle:nil];
    blueViewController.tabBarItem_jk = [[JKTabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"home_tab_icon_2"]];
    blueViewController.view.backgroundColor = [UIColor blueColor];
    blueViewController.title = @"test2";
    
    UIViewController *greenViewController = [[JKViewController alloc] initWithNibName:@"JKViewController" bundle:nil];
    greenViewController.tabBarItem_jk = [[JKTabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"home_tab_icon_3"]];
    greenViewController.view.backgroundColor = [UIColor greenColor];
    
    UIViewController *drakViewController = [[JKViewController alloc] initWithNibName:@"JKViewController" bundle:nil];
    drakViewController.tabBarItem_jk = [[JKTabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"home_tab_icon_4"]];
    drakViewController.view.backgroundColor = [UIColor blackColor];
    
    UIViewController *purpleViewController = [[JKViewController alloc] initWithNibName:@"JKViewController" bundle:nil];
    purpleViewController.tabBarItem_jk = [[JKTabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"home_tab_icon_5"]];
    purpleViewController.view.backgroundColor = [UIColor purpleColor];
    
    
    [tabBarController setViewControllers:@[
                                           [[UINavigationController alloc] initWithRootViewController:redViewController],
                                           [[UINavigationController alloc] initWithRootViewController:blueViewController],
                                           [[UINavigationController alloc] initWithRootViewController:greenViewController],
                                           [[UINavigationController alloc] initWithRootViewController:drakViewController],
                                           [[UINavigationController alloc] initWithRootViewController:purpleViewController],
//                                           [[JKViewController alloc] initWithNibName:@"JKViewController" bundle:nil],
//                                           [[JKViewController alloc] initWithNibName:@"JKViewController" bundle:nil],
     ] animated:YES];
    
    tabBarController.tabBar.selectionIndicatorAnimable = YES;
    [[JKTabBar appearance] setBackgroundImage:[UIImage imageNamed:@"mask_navbar"]];
    [[JKTabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"home_bottom_tab_arrow"]];
    [[JKTabBarItem appearance] setBadgeBackgroundImage:[[UIImage imageNamed:@"number_notify_9"] stretchableImageWithLeftCapWidth:16 topCapHeight:16]];
    
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [redViewController.tabBarItem_jk setBadgeValue:@"0" animated:YES];
        self.tabBarController.customizableViewControllers = self.tabBarController.viewControllers;
    });
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
