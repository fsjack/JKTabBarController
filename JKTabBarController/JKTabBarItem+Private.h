//
//  JKTabBarItem+Private.h
//  JKTabBarControllerDemo
//
//  Created by Jackie CHEUNG on 13-6-16.
//  Copyright (c) 2013年 Weico. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, JKTabBarItemType) {
    JKTabBarItemTypeButton,
    JKTabBarItemTypeCustomView
};

@interface JKTabBarItem (Private)
@property (nonatomic, readonly) JKTabBarItemType   itemType;
@property (nonatomic, readonly) UIView             *contentView;

//methods below wont efficent if itemType is JKTabBarItemTypeCustomView
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event;
- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents;

@end