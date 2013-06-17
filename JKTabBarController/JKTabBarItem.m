//
//  JKTabBarItem.m
//  JKTabBarControllerDemo
//
//  Created by Jackie CHEUNG on 13-6-7.
//  Copyright (c) 2013年 Weico. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "JKTabBarItem.h"
#import "JKTabBarItem+Private.h"
#import "JKAppearanceProxy.h"

static CGFloat const JKTabBarButtonImageVerticalOffset = 5.0f;

static CGFloat const JKTabBarBadgeViewPopAnimationDuration = 0.4f;
static CGFloat const JKTabBarBadgeViewFadeAnimationDuration = 0.2f;

static UIOffset const JKTabBarBadgeViewDefaultCenterOffset = (UIOffset){ 15.0f , 10.0f };
static CGSize const JKTabBarBadgeViewMinmumSize = (CGSize){ 32.0f , 32.0f };

@interface JKTabBarItem ()
@property (nonatomic)  JKTabBarItemType     itemType;
@property (nonatomic, strong)  UIView      *itemView;
@property (nonatomic, strong)  UIButton    *itemButton;

@property (nonatomic, strong)  UIButton    *badgeButton;
@end

@interface JKTabBarButton : UIButton
@property (weak, nonatomic) JKTabBarItem *tabBarItem;
@end

@implementation JKTabBarButton
- (void)setHighlighted:(BOOL)highlighted{
    [super setHighlighted:NO]; //To stop button from showing UIControlStateHighlight state
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    [super setEnabled:!selected];
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    CGRect imageRect = [super imageRectForContentRect:contentRect];
    
    BOOL hasText = ([self titleForState:UIControlStateNormal].length ? YES : NO);
    if(hasText){
        UIEdgeInsets imageInsets = self.imageEdgeInsets;
        imageRect.origin.x = contentRect.size.width/2 - imageRect.size.width/2 - imageInsets.left;
        imageRect.origin.y = contentRect.size.height/2 - imageRect.size.height/2 - imageInsets.top - JKTabBarButtonImageVerticalOffset;
        imageRect.size.width  = imageRect.size.width - imageInsets.right;
        imageRect.size.height = imageRect.size.height - imageInsets.bottom;
    }

    return imageRect;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    CGRect titleRect = [super titleRectForContentRect:contentRect];
    CGRect imageRect = [self imageRectForContentRect:contentRect];
    
    UIEdgeInsets titleInsets = self.titleEdgeInsets;
    titleRect.origin.x = contentRect.size.width/2 - titleRect.size.width/2 - titleInsets.left;
    titleRect.origin.y = CGRectGetMaxY(imageRect) - titleInsets.top;
    titleRect.size.width  = titleRect.size.width - titleInsets.right;
    titleRect.size.height = titleRect.size.height - titleInsets.bottom;
    
    return titleRect;
}

#pragma mark - Appearence
- (void)didMoveToWindow{
    [super didMoveToWindow];
    /* excute appearance recoraded invocation when button is moved to window. */    
    [[JKAppearanceProxy appearanceForClass:[JKTabBarItem class]] startForwarding:self.tabBarItem];
}

@end

@implementation JKTabBarItem
#pragma mark - appearence
+ (instancetype)appearance{
    return [JKAppearanceProxy appearanceForClass:self];
}

#pragma mark - property
- (UIView *)contentView{
    if(self.itemType == JKTabBarItemTypeButton)
        return self.itemButton;
    else
        return self.itemView;
}

- (UIImage *)finishedSelectedImage{
    return [self.itemButton imageForState:UIControlStateSelected];
}

- (UIImage *)finishedUnselectedImage{
    return [self.itemButton imageForState:UIControlStateDisabled];
}

- (UIEdgeInsets)imageInsets{
    return self.itemButton.imageEdgeInsets;
}

- (void)setImageInsets:(UIEdgeInsets)imageInsets{
    [self.itemButton setImageEdgeInsets:imageInsets];
}

- (NSInteger)tag{
    return self.contentView.tag;
}

- (void)setTag:(NSInteger)tag{
    [self.contentView setTag:tag];
}

- (void)setEnabled:(BOOL)enabled{
    [self.itemButton setEnabled:enabled];
}

- (BOOL)isEnabled{
    return self.itemButton.isEnabled;
}

- (NSString *)title{
    return [self.itemButton titleForState:UIControlStateNormal];
}

- (void)setTitle:(NSString *)title{
    [self.itemButton setTitle:title forState:UIControlStateNormal];
}

- (UIImage *)image{
    return [self.itemButton imageForState:UIControlStateNormal];
}

- (void)setImage:(UIImage *)image{
    [self.itemButton setImage:image forState:UIControlStateNormal];
}

- (void)setTitlePositionAdjustment:(UIOffset)adjustment{
    [self.itemButton setTitleEdgeInsets:UIEdgeInsetsMake(adjustment.vertical, adjustment.horizontal, -adjustment.vertical, -adjustment.horizontal)];
}

- (UIOffset)titlePositionAdjustment{
    return UIOffsetMake(self.itemButton.titleEdgeInsets.left, self.itemButton.titleEdgeInsets.top);
}

- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state{
    /*!Need FIX: Need to compatiable with iOS 5 and iOS 7. */    
    [self.itemButton.titleLabel setFont:attributes[UITextAttributeFont]];
    [self.itemButton.titleLabel setShadowOffset:[attributes[UITextAttributeTextShadowOffset] CGSizeValue]];
    [self.itemButton setTitleColor:attributes[UITextAttributeTextColor] forState:state];
    [self.itemButton setTitleShadowColor:attributes[UITextAttributeTextShadowColor] forState:state];
}

- (NSDictionary *)titleTextAttributesForState:(UIControlState)state{
    /*!Need FIX: Need to compatiable with iOS 5 and iOS 7. */    
    return @{
             UITextAttributeFont                : self.itemButton.titleLabel.font,
             UITextAttributeTextShadowOffset    : [NSValue valueWithCGSize:self.itemButton.titleLabel.shadowOffset],
             UITextAttributeTextColor           : [self.itemButton titleColorForState:state],
             UITextAttributeTextShadowColor     : [self.itemButton titleShadowColorForState:state]
             };
}

#pragma mark - initialziation
- (id)initWithTitle:(NSString *)title image:(UIImage *)image{
    self = [super init];
    if(self){
        _itemType = JKTabBarItemTypeButton;
        
        JKTabBarButton *button = [JKTabBarButton buttonWithType:UIButtonTypeCustom];
        _itemButton         = button;
        button.tabBarItem   = self;
        [button setTitle:title forState:UIControlStateNormal];
        [button setImage:image forState:UIControlStateNormal];
        [button setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [button setAdjustsImageWhenHighlighted:NO];
        [button setAdjustsImageWhenDisabled:NO];
        
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:10]];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected|UIControlStateDisabled];
    }
    return self;
}

- (id)initWithCustomView:(UIView *)customView{
    self = [super init];
    if(self){
        _itemType = JKTabBarItemTypeCustomView;
        _itemView = customView;
    }
    return self;
}

#pragma mark - public methods
- (void)setFinishedSelectedImage:(UIImage *)selectedImage withFinishedUnselectedImage:(UIImage *)unselectedImage{
    [self.itemButton setImage:selectedImage forState:UIControlStateSelected|UIControlStateDisabled];
    [self.itemButton setImage:unselectedImage forState:UIControlStateNormal];
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents{
    [self.itemButton addTarget:target action:action forControlEvents:controlEvents];
}

- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents{
    [self.itemButton removeTarget:target action:action forControlEvents:controlEvents];
}

#pragma mark - animation
- (CAAnimation *)popAnimation{
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.values = @[
                              [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.2, 0.2, 1)],
                              [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1)],
                              [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)]
                              ];
    scaleAnimation.keyTimes = @[ @(0.0f) , @(0.3f) , @(0.5f) ];
    
    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.values = @[ @(0.0f) , @(0.1f) , @(1.0f) ];
    
    opacityAnimation.keyTimes = @[ @(0.0f) , @(0.1f) , @(0.4f) ];
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:scaleAnimation, opacityAnimation, nil];
    animationgroup.duration = JKTabBarBadgeViewPopAnimationDuration;
    
    return animationgroup;
}

#pragma mark - badge
- (CGSize)badgeSize{
    [self.badgeButton sizeToFit];
    CGSize badgeSize = self.badgeButton.bounds.size;
    
    if(CGRectGetWidth(self.badgeButton.bounds) < JKTabBarBadgeViewMinmumSize.width) badgeSize.width = JKTabBarBadgeViewMinmumSize.width;
    if(CGRectGetHeight(self.badgeButton.bounds) < JKTabBarBadgeViewMinmumSize.height) badgeSize.height = JKTabBarBadgeViewMinmumSize.height;
    
    badgeSize.width     = badgeSize.width - self.badgeInsets.right;
    badgeSize.height    = badgeSize.height - self.badgeInsets.bottom;
    
    return badgeSize;
}

- (UIButton *)badgeButton{
    if(!_badgeButton){
        UIButton *badgeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _badgeButton = badgeButton;
        
        [badgeButton.titleLabel setFont:[UIFont systemFontOfSize:10]];
        badgeButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
        [badgeButton setTitleShadowColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [badgeButton setAdjustsImageWhenDisabled:NO];
        [badgeButton setEnabled:NO];
    }
    return _badgeButton;
}

- (NSString *)badgeValue{
    return [self.badgeButton titleForState:UIControlStateNormal];
}

static NSString * const JKTabBarItemBadgePopAnimationKey = @"JKTabBarItemBadgePopAnimationKey";
- (void)setBadgeValue:(NSString *)badgeValue{
    [self setBadgeValue:badgeValue animated:NO];
}

- (void)setBadgeValue:(NSString *)badgeValue animated:(BOOL)animated;{
    if(badgeValue.length){
        [self.badgeButton setTitle:badgeValue forState:UIControlStateNormal];
        
        self.badgeButton.frame = (CGRect){
            CGRectGetMidX(self.contentView.bounds) - self.badgeSize.width/2 + JKTabBarBadgeViewDefaultCenterOffset.horizontal + self.badgeInsets.left ,
            CGRectGetMidY(self.contentView.bounds) - self.badgeSize.height/2 - JKTabBarBadgeViewDefaultCenterOffset.vertical + self.badgeInsets.top ,
            self.badgeSize
        };
        self.badgeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [self.contentView addSubview:self.badgeButton];
        if(![self.badgeButton.layer animationForKey:JKTabBarItemBadgePopAnimationKey] && animated)
            [self.badgeButton.layer addAnimation:[self popAnimation] forKey:JKTabBarItemBadgePopAnimationKey];
    }else{
        [UIView animateWithDuration:(animated ? JKTabBarBadgeViewFadeAnimationDuration : 0.0f)
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.badgeButton.alpha = 0.0f;
                         } completion:^(BOOL finished) {
                             [self.badgeButton removeFromSuperview];
                             [self.badgeButton.layer removeAnimationForKey:JKTabBarItemBadgePopAnimationKey];
                         }];
    }
}

#pragma mark - badge property 
- (void)setBadgeTextAttributeds:(NSDictionary *)badgeTextAttributeds{
    /*!Need FIX: Need to compatiable with iOS 5 and iOS 7. */
    [self.badgeButton setTitleColor:badgeTextAttributeds[UITextAttributeTextColor] forState:UIControlStateNormal];
    [self.badgeButton setTitleShadowColor:badgeTextAttributeds[UITextAttributeTextShadowColor] forState:UIControlStateNormal];
    [self.badgeButton.titleLabel setFont:badgeTextAttributeds[UITextAttributeFont]];
    [self.badgeButton.titleLabel setShadowOffset:[badgeTextAttributeds[UITextAttributeTextShadowOffset] CGSizeValue]];
}

- (NSDictionary *)badgeTextAttributeds{
    /*!Need FIX: Need to compatiable with iOS 5 and iOS 7. */    
    return @{
             UITextAttributeTextColor          : [self.badgeButton titleColorForState:UIControlStateNormal],
             UITextAttributeTextShadowColor    : [self.badgeButton titleShadowColorForState:UIControlStateNormal],
             UITextAttributeFont               : self.badgeButton.titleLabel.font,
             UITextAttributeTextShadowOffset   : [NSValue valueWithCGSize:self.badgeButton.titleLabel.shadowOffset]
             };
}

- (UIImage *)badgeBackgroundImage{
    return [self.badgeButton backgroundImageForState:UIControlStateNormal];
}

- (void)setBadgeBackgroundImage:(UIImage *)badgeBackgroundImage{
    [self.badgeButton setBackgroundImage:badgeBackgroundImage forState:UIControlStateNormal];
}

@end