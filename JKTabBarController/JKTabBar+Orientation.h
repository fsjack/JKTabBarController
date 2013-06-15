//
//  JKTabBar+Private.h
//  JKTabBarControllerDemo
//
//  Created by Jackie CHEUNG on 13-6-16.
//  Copyright (c) 2013年 Weico. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger,JKTabBarOrientation) {
    JKTabBarOrientationHorizontal,
    JKTabBarOrientationVertical
};

@interface JKTabBar (Orientation)
@property (nonatomic, readonly) JKTabBarOrientation orientation;
- (void)setOrientation:(JKTabBarOrientation)orientation;
@end