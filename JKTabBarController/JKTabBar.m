//
//  JKTabBar.m
//  JKTabBarControllerDemo
//
//  Created by Jackie CHEUNG on 13-6-7.
//  Copyright (c) 2013年 Weico. All rights reserved.
//

#import "JKTabBar.h"
#import "JKTabBarItem.h"
#import "JKTabBar+Orientation.h"
#import "JKTabBarItem+Private.h"
#import "JKAppearanceProxy.h"

static NSUInteger const JKTabBarItemDefaultSelectedIndex = 0;

static CGFloat const JKTabBarShadowDefaultHeight    = 10.f;
static CGFloat const JKTabBarButtonItemPadding      = 0.0f;

static CGFloat const JKTabBarButtonItemTopMargin    = 0.0f;
static CGFloat const JKTabBarButtonItemLeftMargin   = 0.0f;

CGFloat const JKTabBarSelectionIndicatorAnimationDuration = 0.3f;

@interface JKTabBar ()
@property (weak, nonatomic)   UIImageView   *backgroundImageView;
@property (weak, nonatomic)   UIImageView   *shadowImageView;
@property (weak, nonatomic)   UIImageView   *selectionIndicatorImageView;

@property (readonly, nonatomic) NSArray *allCustomButtonView;
@property (readonly, nonatomic) CGSize itemButtonSize;

@property (nonatomic) JKTabBarOrientation orientation;
@end

@implementation JKTabBar
#pragma mark - Init
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self _setupAppearence];
    }
    return self;
}

#pragma mark - Public Methods
- (void)beginCustomizingItems:(NSArray *)items{
    
}
- (BOOL)endCustomizingAnimated:(BOOL)animated{
    return NO;
}

- (BOOL)isCustomizing{
    return NO;
}

- (void)setOrientation:(JKTabBarOrientation)orientation{
    if(_orientation == orientation) return;
    _orientation = orientation;
    [self setNeedsLayout];
}

#pragma mark - Privte
- (void)_setupAppearence{
    /* Need FIX: frame is different depend on tabbar position
    //Set up ShadowImageView
    UIImageView *shadowImageView = [[UIImageView alloc] initWithFrame:(CGRect){ 0,-JKTabBarShadowDefaultHeight,CGRectGetWidth(self.bounds),JKTabBarShadowDefaultHeight }];
    self.shadowImageView = shadowImageView;
    shadowImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:shadowImageView];
     */
    
    //Set up backgroundImageView
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.backgroundImageView = backgroundImageView;
    backgroundImageView.userInteractionEnabled = YES;
    backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:backgroundImageView];
    
    //Set up selection indicator image ivew
    UIImageView *selectionIndicatorImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.selectionIndicatorImageView = selectionIndicatorImageView;
    selectionIndicatorImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:selectionIndicatorImageView];
}

- (void)_setupTabBarItems{
    [self.items enumerateObjectsUsingBlock:^(JKTabBarItem *itemButton, NSUInteger idx, BOOL *stop) {
        [itemButton.contentView removeFromSuperview];
    }];
    
    __weak __typeof(&*self)weakSelf = self;
    [self.items enumerateObjectsUsingBlock:^(JKTabBarItem *item, NSUInteger idx, BOOL *stop) {
        item.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [item addTarget:self action:@selector(_selecteButtonItem:) forControlEvents:UIControlEventTouchDown];
        [weakSelf addSubview:item.contentView];
        if(JKTabBarItemDefaultSelectedIndex == idx) [weakSelf _selecteButtonItem:item.contentView];
        item.tag = idx;
    }];
}

- (JKTabBarItem *)tabBarItemForItemButton:(UIButton *)itemButton{
    NSUInteger itemIndex = itemButton.tag;
    NSAssert(itemIndex < self.items.count, @"Item index is out of range");
    return self.items[itemIndex];
}

#pragma mark - Action
- (void)_selecteButtonItem:(id)sender{
    UIButton *button = sender;
    JKTabBarItem *item = [self tabBarItemForItemButton:button];
    if(item == self.selectedItem) return;
    
    UIButton *selectedButton = (UIButton *)self.selectedItem.contentView;
    
    [button setSelected:!button.isSelected];
    [selectedButton setSelected:!selectedButton.isSelected];

    
    UIImageView *indicatorView = self.selectionIndicatorImageView;
    if(self.selectionIndicatorAnimable) self.userInteractionEnabled = NO;
    
    __weak __typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:self.selectionIndicatorAnimable ? JKTabBarSelectionIndicatorAnimationDuration : 0.0f
                          delay:0.0f
                        options:UIViewAnimationCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         indicatorView.frame = button.frame;
                     } completion:^(BOOL finished) {
                         if(finished) weakSelf.userInteractionEnabled = YES;
                     }];
    self.selectedItem = item;
    
    if([self.delegate respondsToSelector:@selector(tabBar:didSelectItem:)])
        [self.delegate tabBar:self didSelectItem:item];
}

#pragma mark - Property
- (void)setBackgroundImage:(UIImage *)backgroundImage{
    if(_backgroundImage == backgroundImage) return;
    _backgroundImage = backgroundImage;
    [self.backgroundImageView setImage:backgroundImage];
}

- (void)setSelectionIndicatorImage:(UIImage *)selectionIndicatorImage{
    if(selectionIndicatorImage == _selectionIndicatorImage) return;
    _selectionIndicatorImage = selectionIndicatorImage;
    [self.selectionIndicatorImageView setImage:selectionIndicatorImage];
}

- (void)setTintColor:(UIColor *)tintColor{
    if(tintColor == _tintColor) return;
    _tintColor = tintColor;
}

- (void)setSelectedImageTintColor:(UIColor *)selectedImageTintColor{
    if(selectedImageTintColor == _selectedImageTintColor) return;
    _selectedImageTintColor = selectedImageTintColor;
}


- (void)setShadowImage:(UIImage *)shadowImage{
    if(shadowImage == _shadowImage) return;
    _shadowImage = shadowImage;
    
    [_shadowImageView setImage:shadowImage];
}

- (void)setItems:(NSArray *)items{
    if(_items == items) return;
    _items = items;
    [self _setupTabBarItems];
}

- (NSArray *)allCustomButtonView{
    return [self.items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.itemType = %d",JKTabBarItemTypeCustomView]];
}

- (CGSize)itemButtonSize{
    CGFloat __block customViewWidth;
    NSArray *customViews = [self allCustomButtonView];
    [customViews enumerateObjectsUsingBlock:^(JKTabBarItem *item, NSUInteger idx, BOOL *stop) {
        customViewWidth += item.contentView.bounds.size.width;
    }];
    
    CGFloat tabBarWidth     = (self.orientation == JKTabBarOrientationHorizontal ? CGRectGetWidth(self.bounds) : CGRectGetHeight(self.bounds));
    CGFloat tabBarHeight    = (self.orientation == JKTabBarOrientationHorizontal ? CGRectGetHeight(self.bounds) : CGRectGetWidth(self.bounds));
    
    CGFloat itemButtonWidth = (tabBarWidth - customViewWidth - (JKTabBarButtonItemPadding * self.items.count-1) - JKTabBarButtonItemLeftMargin*2) / (self.items.count - customViews.count);
    
    return rotateSize(CGSizeMake(itemButtonWidth, tabBarHeight - JKTabBarButtonItemTopMargin*2 ), self.orientation);
}

#pragma mark - Layout
- (void)layoutSubviews{
    [super layoutSubviews];
    
    //set tab bar button frame
    CGSize itemButtonSize = self.itemButtonSize;
    
    CGFloat __block itemButtonOffsetX = JKTabBarButtonItemLeftMargin;
    __weak __typeof(&*self)weakSelf = self;
    [self.items enumerateObjectsUsingBlock:^(JKTabBarItem *item, NSUInteger idx, BOOL *stop) {
        UIView *itemContentView = item.contentView;
        if(item.itemType == JKTabBarItemTypeButton){
            itemContentView.frame = rotateFrame((CGRect){ itemButtonOffsetX , JKTabBarButtonItemTopMargin , itemButtonSize },weakSelf.orientation);
            
            CGFloat offsetLength = (weakSelf.orientation == JKTabBarOrientationHorizontal ? itemButtonSize.width : itemButtonSize.height);
            itemButtonOffsetX += (offsetLength + JKTabBarButtonItemPadding);
            
        }else if(item.itemType == JKTabBarItemTypeCustomView){
            itemContentView.frame = rotateFrame((CGRect){ itemButtonOffsetX , JKTabBarButtonItemTopMargin , itemContentView.bounds.size },weakSelf.orientation);
            
            CGFloat offsetLength = (weakSelf.orientation == JKTabBarOrientationHorizontal ? itemContentView.bounds.size.width : itemContentView.bounds.size.height);
            itemButtonOffsetX += (offsetLength + JKTabBarButtonItemPadding);
        }
    }];
    
    //set selection indictor image frame
    self.selectionIndicatorImageView.frame = self.selectedItem.contentView.frame;
}

#pragma mark - Uility
CGSize rotateSize(CGSize oldSize,JKTabBarOrientation orientation){
    if(orientation == JKTabBarOrientationHorizontal)
        return oldSize;
    else
        return CGSizeMake(oldSize.height, oldSize.width);
}

CGPoint rotateOrigin(CGPoint oldPoint,JKTabBarOrientation orientation){
    if(orientation == JKTabBarOrientationHorizontal)
        return oldPoint;
    else
        return CGPointMake(oldPoint.y, oldPoint.x);
}

CGRect rotateFrame(CGRect frame,JKTabBarOrientation orientation){
    if(orientation == JKTabBarOrientationHorizontal)
        return frame;
    else
        return CGRectMake(frame.origin.y, frame.origin.x, frame.size.width, frame.size.height);
}

@end