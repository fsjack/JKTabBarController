//
//  JKTabBarItem.m
//  JKTabBarControllerDemo
//
//  Created by Jackie CHEUNG on 13-6-7.
//  Copyright (c) 2013年 Weico. All rights reserved.
//

#import "JKTabBarItem.h"
#import "JKTabBarItem+Private.h"
#import <QuartzCore/QuartzCore.h>
static CGFloat const JKTabBarButtonImageVerticalOffset = 5.0f;
static CGFloat const JKTabBarBadgeViewPopAnimationDuration = 0.6f;

@interface JKTabBarItem ()
@property (nonatomic)  JKTabBarItemType itemType;
@property (nonatomic, strong)  UIView      *contentView;
@property (nonatomic, strong)  UIButton    *contentButton;
@property (nonatomic, strong)  UIButton    *badgeButton;
@end

@interface JKTabBarButton : UIButton
@end

@implementation JKTabBarButton
- (void)setHighlighted:(BOOL)highlighted{
    //To stop button show UIControlStateHighlight state
    [super setHighlighted:NO];
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
@end

@implementation JKTabBarItem
#pragma mark - private methods
- (void)_configureDefault{
}

#pragma mark - initialziation
- (id)initWithTitle:(NSString *)title image:(UIImage *)image{
    self = [super init];
    if(self){
        _itemType = JKTabBarItemTypeButton;
        
        JKTabBarButton *button = [JKTabBarButton buttonWithType:UIButtonTypeCustom];
        _contentButton = button;
        [button setTitle:title forState:UIControlStateNormal];
        [button setImage:image forState:UIControlStateNormal];
        [button setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [button setAdjustsImageWhenHighlighted:NO];
        [button setAdjustsImageWhenDisabled:NO];
        
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:10]];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected|UIControlStateDisabled];
        
        [self _configureDefault];
    }
    return self;
}

- (id)initWithCustomView:(UIView *)customView{
    self = [super init];
    if(self){
        _itemType = JKTabBarItemTypeCustomView;
        _contentView = customView;
        [self _configureDefault];
    }
    return self;
}

#pragma mark - public methods
- (void)setFinishedSelectedImage:(UIImage *)selectedImage withFinishedUnselectedImage:(UIImage *)unselectedImage{
    [self.contentButton setImage:selectedImage forState:UIControlStateSelected|UIControlStateDisabled];
    [self.contentButton setImage:unselectedImage forState:UIControlStateNormal];
}

#pragma mark - property
- (UIImage *)finishedSelectedImage{
    return [self.contentButton imageForState:UIControlStateSelected];
}

- (UIImage *)finishedUnselectedImage{
    return [self.contentButton imageForState:UIControlStateDisabled];
}

- (UIEdgeInsets)imageInsets{
    return self.contentButton.imageEdgeInsets;
}

- (void)setImageInsets:(UIEdgeInsets)imageInsets{
    [self.contentButton setImageEdgeInsets:imageInsets];
}

- (NSInteger)tag{
    if(self.contentButton)
        return self.contentButton.tag;
    else
        return self.contentView.tag;
}

- (void)setTag:(NSInteger)tag{
    [self.contentButton setTag:tag];
    [self.contentView setTag:tag];
}

- (void)setEnabled:(BOOL)enabled{
    [self.contentButton setEnabled:enabled];
}

- (BOOL)isEnabled{
    return self.contentButton.isEnabled;
}

- (NSString *)title{
    return [self.contentButton titleForState:UIControlStateNormal];
}

- (void)setTitle:(NSString *)title{
    [self.contentButton setTitle:title forState:UIControlStateNormal];
}

- (UIImage *)image{
    return [self.contentButton imageForState:UIControlStateNormal];
}

- (void)setImage:(UIImage *)image{
    [self.contentButton setImage:image forState:UIControlStateNormal];
}

- (void)setTitlePositionAdjustment:(UIOffset)adjustment{
}

- (UIOffset)titlePositionAdjustment{
    return UIOffsetZero;
}


#pragma mark - badge
- (UIButton *)badgeButton{
    if(!_badgeButton){
        _badgeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _badgeButton.enabled = NO;
    }
    return _badgeButton;
}

- (void)setBadgeValue:(NSString *)badgeValue{
    [self.badgeButton setTitle:badgeValue forState:UIControlStateNormal];
    [self.badgeButton.layer addAnimation:[self popAnimation] forKey:@"Pop"];
}

- (NSString *)badgeValue{
    return [self.badgeButton titleForState:UIControlStateNormal];
}

#pragma mark - animation
- (CAAnimation *)popAnimation{
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.values = @[
                              [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.2, 0.2, 1)],
                              [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05, 1.05, 1)],
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

@end
