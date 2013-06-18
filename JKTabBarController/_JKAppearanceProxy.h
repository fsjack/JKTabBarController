//
//  JKAppearenceProxy.h
//  JKTabBarControllerDemo
//
//  Created by Jackie CHEUNG on 13-6-17.
//  Copyright (c) 2013年 Weico. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 JKAppearanceProxy is custom appearance for recoarding invocation from the class that inheird from NSObject but failed to excute UIAppearance protocol methods.
 Example:
 
 1.Overwrite UIAppearance protocol method
 + (instancetype)appearance{
    return [JKAppearanceProxy appearanceForClass:self];
 }
 
 2.Excute startForwarding at the right time.
 - (void)viewWillMoveToSuperView:(UIView *)superView{
    [super viewWillMoveToSuperView:superView];
    [[self appearance] startForwarding:self];
 }
 
 Done.
 */

@interface _JKAppearanceProxy : NSObject
+ (id)appearanceForClass:(Class)class;
- (void)startForwarding:(id)sender; //call this method when view will move to superview or as view init.
@end
