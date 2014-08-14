//
//  JKTabBarController.h
//  JKTabBarControllerDemo
//
//  Created by Jackie CHEUNG on 13-6-7.
//  Copyright (c) 2013年 Weico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JKTabBar.h"

/*!
 JKTabBarController manages a button bar and transition view, for an application with multiple top-level modes.
 
 To use in your application, add its view to the view hierarchy, then add top-level view controllers in order.
 Most clients will not need to subclass JKTabBarController.
 
 If more than five view controllers are added to a tab bar controller, only the first four will display.
 The rest will be accessible under an automatically generated More item.
 
 JKTabBarController is rotatable if all of its view controllers are rotatable.
 */

/*
 Feature of JKTabBarController
 * Custom tab bar item,you can put a view in tabBar if you like.
 * Custom tab bar position.Provide four option for choosing,you can put it on top bottom left or right.No support for middle yet:)
 * One may not count as feature but we waste time implementing this,which is customizeable view controller.You can customize the count of items to display in customizedViewController we provide or you write your own.x
 */

extern NSUInteger const JKTabBarMaximumItemCount;

typedef NS_ENUM(NSUInteger, JKTabBarPosition){
    JKTabBarPositionBottom,
    JKTabBarPositionTop,
    JKTabBarPositionLeft,
    JKTabBarPositionRight
};

NS_INLINE BOOL JKTabBarIsVertical(JKTabBarPosition position) {
    return position == JKTabBarPositionLeft || position == JKTabBarPositionRight;
}

NS_INLINE BOOL JKTabBarIsHorizontal(JKTabBarPosition position) {
    return position == JKTabBarPositionTop || position == JKTabBarPositionBottom;
}

@class JKTabBarItem;
@protocol JKTabBarControllerDelegate;
@interface JKTabBarController : UIViewController<JKTabBarDelegate>
@property (nonatomic)       JKTabBarPosition    tabBarPosition UI_APPEARANCE_SELECTOR; //Defualt is JKTabBarPositionBottom.
@property (nonatomic,copy)  NSArray             *viewControllers;
// If the number of view controllers is greater than the number displayable by a tab bar, a "More" navigation controller will automatically be shown.
// The "More" navigation controller will not be returned by -viewControllers, but it may be returned by -selectedViewController.
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;

@property (nonatomic,weak)      UIViewController *selectedViewController; // This may return the "More" navigation controller if it exists.
@property (nonatomic)           NSUInteger selectedIndex;

@property (nonatomic, readonly, strong)  UINavigationController *moreNavigationController;
@property (nonatomic, readonly, weak)  JKTabBar *tabBar; // Provided for -[UIActionSheet showFromTabBar:]. Attempting to modify the contents of the tab bar directly will throw an exception.
@property (nonatomic)           CGFloat tabBarBackgroundTopInset;

@property (nonatomic) BOOL tabBarHidden;
- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated;

@property (nonatomic,copy)      NSArray *customizableViewControllers; // If non-nil, then the "More" view will include an "Edit" button that displays customization UI for the specified controllers. By default, all view controllers are customizable.
@property (nonatomic,weak)      id<JKTabBarControllerDelegate> delegate;

@property (nonatomic) BOOL selectedControllerNavigationItem; //NO by default.Set YES could let navigation controller of tabbar controller show selected controller's navigation item.
@property (nonatomic) BOOL shouldAdjustSelectedViewContentInsets; //Default is NO.

- (void)adjustSelectedViewControllerInsetsIfNeeded;

@end

@protocol JKTabBarControllerDelegate <NSObject>
@optional
- (BOOL)tabBarController:(JKTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;
- (void)tabBarController:(JKTabBarController *)tabBarController willSelectViewController:(UIViewController *)viewController;
- (void)tabBarController:(JKTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController;

- (void)tabBarController:(JKTabBarController *)tabBarController willBeginCustomizingViewControllers:(NSArray *)viewControllers;
- (void)tabBarController:(JKTabBarController *)tabBarController willEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed;
- (void)tabBarController:(JKTabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed;
@end

@protocol JKTabBarDatasource <NSObject>
@optional
@property (nonatomic,readonly) BOOL     tabTitleHidden;
@property (nonatomic,readonly) UIImage  *selectedTabImage; //Overwrite this method in view controller to provide its own tab icon image.If tabBarItem is set this property will be ignored by default.
@property (nonatomic,readonly) UIImage  *unselectedTabImage;
@property (nonatomic,readonly) NSString *tabTitle; //Overwrite this method in view controller to provide its own tab title.If tabBarItem is set this property will be ignored by default.
@end

@interface UIViewController (JKTabBarControllerItem) <JKTabBarDatasource>
@property (nonatomic,retain) JKTabBarItem *tabBarItem_jk; // Automatically created lazily with the view controller's title if it's not set explicitly.
@property (nonatomic,readonly,retain) JKTabBarController *tabBarController_jk; // If the view controller has a tab bar controller as its ancestor, return it. Returns nil otherwise.
@end