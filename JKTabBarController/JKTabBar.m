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
#import "_JKAppearanceProxy.h"
#import "_JKTabBarEditViewController.h"

static NSUInteger const JKTabBarItemDefaultSelectedIndex = 0;

static CGFloat const JKTabBarButtonItemPadding      = 0.0f;

static CGFloat const JKTabBarButtonItemTopMargin    = 0.0f;
static CGFloat const JKTabBarButtonItemLeftMargin   = 0.0f;

CGFloat const JKTabBarSelectionIndicatorAnimationDuration = 0.3f;

@interface JKTabBar ()
@property (weak, nonatomic)   UIImageView   *backgroundImageView;
@property (weak, nonatomic)   UIImageView   *shadowImageView;
@property (weak, nonatomic)   UIImageView   *selectionIndicatorImageView;

@property (readonly, nonatomic) NSArray *allCustomButtonView;
@property (readonly, nonatomic) CGFloat itemButtonWidth;

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
    /* Need FIX: frame is different depend on tabbar position */
    //Set up ShadowImageView
    UIImageView *shadowImageView = [[UIImageView alloc] initWithFrame:(CGRect){ {0 , 0} , {CGRectGetWidth(self.bounds), 0} }];
    self.shadowImageView = shadowImageView;
    shadowImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:shadowImageView];
    
    self.backgroundColor = [UIColor clearColor];
    
    //Set up backgroundImageView
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.backgroundImageView = backgroundImageView;
    backgroundImageView.userInteractionEnabled = YES;
    backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:backgroundImageView];
    
    //Set up selection indicator image ivew
    UIImageView *selectionIndicatorImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.selectionIndicatorImageView = selectionIndicatorImageView;
    self.selectionIndicatorImageView.contentMode = UIViewContentModeScaleAspectFit;    
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
        [item addTarget:self action:@selector(_selecteButtonItem:) forControlEvents:UIControlEventTouchUpInside];
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
    JKTabBarItem *item = [self tabBarItemForItemButton:sender];
    
    if ([self.delegate respondsToSelector:@selector(tabBar:shouldSelectItem:)]) {
        BOOL shouldSelected = [self.delegate tabBar:self shouldSelectItem:item];
        if (!shouldSelected) {
            return;
        }
    }
    
    UIButton *selectedButton = (UIButton *)self.selectedItem.contentView;
    
    [item setEnabled:!item.isEnabled];
    [self.selectedItem setEnabled:!selectedButton.isSelected];
    
    UIImageView *indicatorView = self.selectionIndicatorImageView;
    
    [UIView animateWithDuration:self.selectionIndicatorAnimable ? JKTabBarSelectionIndicatorAnimationDuration : 0.0f
                          delay:0.0f
                        options:( UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState )
                     animations:^{
                         indicatorView.frame = button.frame;
                     } completion:^(BOOL finished) {
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
    
    [self.backgroundImageView sizeToFit];
    self.backgroundImageView.frame = (CGRect){
        {self.backgroundImageView.frame.origin.x , self.bounds.size.height - self.backgroundImageView.frame.size.height},
        { self.bounds.size.width, self.backgroundImageView.bounds.size.height }
    };
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
    
    [self.shadowImageView setImage:shadowImage];
}

- (void)setItems:(NSArray *)items{
    if(_items == items) return;
    _items = items;
    [self _setupTabBarItems];
}

- (NSArray *)allCustomButtonView{
    return [self.items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.itemType = %d",JKTabBarItemTypeCustomView]];
}

- (CGFloat)itemButtonWidth{
    CGFloat __block customViewWidth = 0.f;
    NSArray *customViews = [self allCustomButtonView];
    [customViews enumerateObjectsUsingBlock:^(JKTabBarItem *item, NSUInteger idx, BOOL *stop) {
        customViewWidth += item.contentView.bounds.size.width;
    }];
    
    CGFloat tabBarWidth     = (self.orientation == JKTabBarOrientationHorizontal ? CGRectGetWidth(self.bounds) : CGRectGetHeight(self.bounds));
    
    CGFloat itemButtonWidth = (tabBarWidth - customViewWidth - (JKTabBarButtonItemPadding * self.items.count-1) - JKTabBarButtonItemLeftMargin*2) / (self.items.count - customViews.count);
    
    return itemButtonWidth;
}

#pragma mark - Layout
- (void)layoutSubviews{
    [super layoutSubviews];
    
    //set tab bar button frame
    CGFloat itemButtonWidth = self.itemButtonWidth;
    CGSize barSize = self.bounds.size;
    
    CGFloat __block itemButtonOffsetX = JKTabBarButtonItemLeftMargin;
    
    [self.items enumerateObjectsUsingBlock:^(JKTabBarItem *item, NSUInteger idx, BOOL *stop) {
        UIView *itemContentView = item.contentView;
        [itemContentView sizeToFit];
        
        CGFloat itemButtonOffsetY = barSize.height - itemContentView.bounds.size.height + JKTabBarButtonItemTopMargin;
        
        if(item.itemType == JKTabBarItemTypeButton){
            itemContentView.frame = (CGRect){
                { itemButtonOffsetX , itemButtonOffsetY} ,
                { itemButtonWidth , itemContentView.bounds.size.height }
            };
            
            CGFloat offsetLength = itemButtonWidth;
            itemButtonOffsetX += (offsetLength + JKTabBarButtonItemPadding);
            
        }else if(item.itemType == JKTabBarItemTypeCustomView){
            
            itemContentView.frame = (CGRect){
                {itemButtonOffsetX , itemButtonOffsetY} ,
                itemContentView.bounds.size
            };
            
            CGFloat offsetLength = itemContentView.bounds.size.width;
            itemButtonOffsetX += (offsetLength + JKTabBarButtonItemPadding);
        }
    }];
    
    //set selection indictor image frame
    self.selectionIndicatorImageView.frame = self.selectedItem.contentView.frame;
    
    [self.shadowImageView sizeToFit];
    self.shadowImageView.frame = (CGRect){
        { 0 , -CGRectGetHeight(self.shadowImageView.bounds) },
        self.shadowImageView.bounds.size
    };
}

@end
