//
//  JKTabBar.h
//  JKTabBarControllerDemo
//
//  Created by Jackie CHEUNG on 13-6-7.
//  Copyright (c) 2013年 Weico. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JKTabBarItem;
@protocol JKTabBarDelegate;

extern CGFloat const JKTabBarSelectionIndicatorAnimationDuration;

@interface JKTabBar : UIView
@property(nonatomic,weak)   id<JKTabBarDelegate>    delegate;     // weak reference. default is nil
@property(nonatomic,copy)   NSArray                 *items;        // get/set visible UITabBarItems. default is nil. changes not animated. shown in order
@property(nonatomic,weak)   JKTabBarItem            *selectedItem; // will show feedback based on mode. default is nil

// Reorder items. This will display a sheet with all the items listed, allow the user to change/reorder items and shows a 'Done' button at the top

- (void)beginCustomizingItems:(NSArray *)items;   // list all items that can be reordered. always animates a sheet up. visible items not listed are fixed in place
- (BOOL)endCustomizingAnimated:(BOOL)animated;    // hide customization sheet. normally you should let the user do it. check list of items to see new layout. returns YES if layout changed
- (BOOL)isCustomizing;


/* tintColor will be applied to the tab bar background
 */
@property (nonatomic,strong) UIColor *tintColor UI_APPEARANCE_SELECTOR;
/* selectedImageTintColor will be applied to the gradient image used when creating the
 selected image. Default is nil and will result in the system bright blue for selected
 tab item images. If you wish to also customize the unselected image appearance, you must
 use -setFinishedSelectedImage:finishedUnselectedImage: on individual tab bar items.
 */

@property (nonatomic,strong) UIColor *selectedImageTintColor UI_APPEARANCE_SELECTOR;
/* The background image will be tiled to fit, even if it was not created via the UIImage resizableImage methods.
 */
@property (nonatomic,strong) UIImage *backgroundImage UI_APPEARANCE_SELECTOR;
/* The selection indicator image is drawn on top of the tab bar, behind the bar item icon.
 */
@property (nonatomic,strong) UIImage *selectionIndicatorImage UI_APPEARANCE_SELECTOR;
/* Default is nil. When non-nil, a custom shadow image to show instead of the default shadow image. For a custom shadow to be shown, a custom background image must also be set with -setBackgroundImage: (if the default background image is used, the default shadow image will be used).
 */
@property (nonatomic,strong) UIImage *shadowImage UI_APPEARANCE_SELECTOR;

/*
  Default is NO.When set,selectionIndicatorImage will move smoothly to selected item.
 */
@property (nonatomic) BOOL selectionIndicatorAnimable UI_APPEARANCE_SELECTOR;

@end


@protocol JKTabBarDelegate<NSObject>
@optional

- (void)tabBar:(JKTabBar *)tabBar didSelectItem:(JKTabBarItem *)item; // called when a new view is selected by the user (but not programatically)

/* called when user shows or dismisses customize sheet. you can use the 'willEnd' to set up what appears underneath.
 changed is YES if there was some change to which items are visible or which order they appear. If selectedItem is no longer visible,
 it will be set to nil.
 */

- (void)tabBar:(JKTabBar *)tabBar willBeginCustomizingItems:(NSArray *)items;                     // called before customize sheet is shown. items is current item list
- (void)tabBar:(JKTabBar *)tabBar didBeginCustomizingItems:(NSArray *)items;                      // called after customize sheet is shown. items is current item list
- (void)tabBar:(JKTabBar *)tabBar willEndCustomizingItems:(NSArray *)items changed:(BOOL)changed; // called before customize sheet is hidden. items is new item list
- (void)tabBar:(JKTabBar *)tabBar didEndCustomizingItems:(NSArray *)items changed:(BOOL)changed;  // called after customize sheet is hidden. items is new item list
@end
