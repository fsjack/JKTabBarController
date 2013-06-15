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
@property (nonatomic, readonly)  JKTabBarItemType itemType;
@property (nonatomic, strong, readonly)  UIView      *contentView;
@property (nonatomic, strong, readonly)  UIButton    *contentButton;
@end