//
//  JKTabBarController.m
//  JKTabBarControllerDemo
//
//  Created by Jackie CHEUNG on 13-6-7.
//  Copyright (c) 2013年 Weico. All rights reserved.
//

#import "JKTabBarController.h"
#import "JKTabBarItem.h"
#import "JKTabBar+Orientation.h"
#import <objc/runtime.h>

static CGFloat const JKTabBarDefaultHeight = 50.0f;
static NSUInteger const JKTabBarMaximumItemCount = 5;

@interface JKTabBarController (){
@private
    struct{
        unsigned int isTabBarHidden:1;
    }_flags;
}
@property (nonatomic,readonly) BOOL shouldShowMore;
@property (nonatomic,strong) UINavigationController *moreNavigationController;
@property (nonatomic,strong) JKTabBarItem           *moreTabBarItem;
@property (nonatomic,weak)   UIView   *containerView;
@property (nonatomic,weak)   JKTabBar *tabBar;
@end

@implementation JKTabBarController
#pragma mark - Private Methods
- (void)_setupAppearence{
    JKTabBar *tabBar        = [[JKTabBar alloc] initWithFrame:CGRectZero];
    self.tabBar             = tabBar;
    tabBar.delegate         = self;    
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.containerView = containerView;
    
    containerView.autoresizingMask  = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tabBar.autoresizingMask         = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:containerView];
    [self.view addSubview:tabBar];
    
    
    self.tabBarPosition = JKTabBarPositionBottom;
}

- (UIViewController *)_viewControllerForTabBarItem:(JKTabBarItem *)item{
    if(item == self.moreTabBarItem) return self.moreNavigationController;
    
    NSArray *fileterViewControllers = [self.viewControllers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIViewController *evaluatedObject, NSDictionary *bindings) {
        if(evaluatedObject.tabBarItem_jk == item)
            return YES;
        
        else if([evaluatedObject isKindOfClass:[UINavigationController class]]){
            UINavigationController *navigationController = (UINavigationController *)evaluatedObject;
            UIViewController *rootViewController = navigationController.viewControllers[0];
            
            if(rootViewController.tabBarItem_jk == item)
                return YES;
            else
                return NO;
        }else
            return NO;
        
    }]];
    
    return (fileterViewControllers.count ? fileterViewControllers[0] : nil);
}

- (JKTabBarItem *)_tabBarItemsForViewController:(UIViewController *)viewController{
    JKTabBarItem *item = viewController.tabBarItem_jk;
    if(!item){
        //Need FIX: create items with data provide by protocol JKTabBarDatasource
        NSString *itemTitle = viewController.title;
        
        UIImage *selectedImage,*unselectedImage;
        if([viewController respondsToSelector:@selector(tabTitle)])
            itemTitle = viewController.tabTitle;

        if([viewController respondsToSelector:@selector(selectedTabImage)])
            selectedImage = viewController.selectedTabImage;
        
        if([viewController respondsToSelector:@selector(unselectedTabImage)])
            unselectedImage = viewController.unselectedTabImage;
        
        item = [[JKTabBarItem alloc] initWithTitle:itemTitle image:selectedImage];
        [item setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:unselectedImage];
        
        viewController.tabBarItem_jk = item;
    }
    return item;
}

- (void)_selectTabBarItem:(JKTabBarItem *)tabBarItem{
    UIViewController *viewController = [self _viewControllerForTabBarItem:tabBarItem];
    
    [self addChildViewController:viewController];
    [viewController willMoveToParentViewController:self];
    [self.selectedViewController willMoveToParentViewController:nil];
    
    viewController.view.frame = self.containerView.bounds;
    [self.containerView addSubview:viewController.view];
    [self.selectedViewController.view removeFromSuperview];
    
    [self.selectedViewController removeFromParentViewController];
    [viewController didMoveToParentViewController:self];
    
    self.selectedViewController = viewController;
    self.selectedIndex = [self.tabBar.items indexOfObject:tabBarItem];
}

#pragma mark - Property Methods
- (void)setTabBarPosition:(JKTabBarPosition)tabBarPosition{
    _tabBarPosition = tabBarPosition;
    
    CGRect tabBarFrame,containerViewFrame;
    CGRectEdge rectEdge;
    switch (tabBarPosition) {
        case JKTabBarPositionTop:
            rectEdge = CGRectMinYEdge;
            break;
        case JKTabBarPositionLeft:
            rectEdge = CGRectMinXEdge;
            break;
        case JKTabBarPositionRight:
            rectEdge = CGRectMaxXEdge;
            break;
        default:
            rectEdge = CGRectMaxYEdge;
            break;
    }
    
    CGRectDivide(self.view.bounds, &tabBarFrame, &containerViewFrame, JKTabBarDefaultHeight, rectEdge);
    self.tabBar.frame = tabBarFrame;
    self.containerView.frame = containerViewFrame;
    
    self.tabBar.orientation = (JKTabBarIsVertical(tabBarPosition) ? JKTabBarOrientationVertical : JKTabBarOrientationHorizontal);
}

- (UINavigationController *)moreNavigationController{
    if(!_moreNavigationController) {
        UINavigationController *navigationController = [[UINavigationController alloc] init];
        _moreNavigationController = navigationController;
    }
    return _moreNavigationController;
}

- (JKTabBarItem *)moreTabBarItem{
    if(!_moreTabBarItem){
        JKTabBarItem *item = [self _tabBarItemsForViewController:self.moreNavigationController];
        _moreTabBarItem = item;
    }
    return _moreTabBarItem;
}

- (BOOL)shouldShowMore{
    return (self.viewControllers.count > JKTabBarMaximumItemCount ? YES : NO);
}

#pragma mark - Initialition
- (id)init{
    self = [super init];
    if(self){
        [self _setupAppearence];
    }
    return self;
}

#pragma mark - ViewCycle
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Public Methods
- (void)setViewControllers:(NSArray *)viewControllers{
    [self setViewControllers:viewControllers animated:NO];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated{
    _viewControllers = [viewControllers copy];
    
    NSMutableArray *items = [NSMutableArray array];
    [viewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *stop) {
        UIViewController *rootViewController = viewController;
        if([viewController isKindOfClass:[UINavigationController class]]){
            UINavigationController *navigationController = (UINavigationController *)viewController;
            rootViewController = (navigationController.viewControllers.count ? navigationController.viewControllers[0] : rootViewController);
        }
        
        if(idx == JKTabBarMaximumItemCount-1 && self.shouldShowMore){
            /* add 'more' tab bar item if index is out of maximum count */
            *stop = YES;
            [items addObject:self.moreTabBarItem];
        }else
            [items addObject:[self _tabBarItemsForViewController:rootViewController]];
    }];
    self.tabBar.items = items;
}

#pragma mark - JKTabBarDelegate
- (void)tabBar:(JKTabBar *)tabBar didSelectItem:(JKTabBarItem *)item{
    UIViewController *viewController = [self _viewControllerForTabBarItem:item];
    
    BOOL shouldSelectViewController = YES;
    if([self.delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)])
        shouldSelectViewController = [self.delegate tabBarController:self shouldSelectViewController:viewController];
    
    if(shouldSelectViewController){
        [self _selectTabBarItem:item];
        if([self.delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)])
            [self.delegate tabBarController:self didSelectViewController:viewController];
    }
}

- (void)tabBar:(JKTabBar *)tabBar willBeginCustomizingItems:(NSArray *)items{
    if([self.delegate respondsToSelector:@selector(tabBarController:willBeginCustomizingViewControllers:)])
        [self.delegate tabBarController:self willBeginCustomizingViewControllers:self.viewControllers];
}

- (void)tabBar:(JKTabBar *)tabBar didBeginCustomizingItems:(NSArray *)items{
}

- (void)tabBar:(JKTabBar *)tabBar willEndCustomizingItems:(NSArray *)items changed:(BOOL)changed{
    if([self.delegate respondsToSelector:@selector(tabBarController:didEndCustomizingViewControllers:changed:)])
        [self.delegate tabBarController:self willEndCustomizingViewControllers:self.viewControllers changed:YES];
}

- (void)tabBar:(JKTabBar *)tabBar didEndCustomizingItems:(NSArray *)items changed:(BOOL)changed{
    if([self.delegate respondsToSelector:@selector(tabBarController:didEndCustomizingViewControllers:changed:)])
        [self.delegate tabBarController:self didEndCustomizingViewControllers:self.viewControllers changed:YES];
}

@end


@implementation UIViewController (JKTabBarControllerItem)
static char *JKTabBarItemAssociationKey;
- (void)setTabBarItem_jk:(JKTabBarItem *)tabBarItem_jk{
    objc_setAssociatedObject(self, &JKTabBarItemAssociationKey, tabBarItem_jk, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (JKTabBarItem *)tabBarItem_jk{
    return objc_getAssociatedObject(self, &JKTabBarItemAssociationKey);
}

- (JKTabBarController *)tabBarController_jk{
    if([self.parentViewController isKindOfClass:[JKTabBarController class]])
        return (JKTabBarController *)self.parentViewController;
    else
        return nil;
}

@end