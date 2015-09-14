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
#import "_JKTabBarMoreViewController.h"
#import "JKTabBarItem+Private.h"
#import <objc/runtime.h>

static CGFloat const JKTabBarDefaultHeight = 45.0f;
NSUInteger const JKTabBarMaximumItemCount = 5;

@interface JKTabBarController (){
@private
    struct{
        unsigned int isTabBarHidden:1;
    }_flags;
}
@property (nonatomic,readonly) BOOL shouldShowMore;
@property (nonatomic,strong) UINavigationController      *moreNavigationController;
@property (nonatomic,strong) _JKTabBarMoreViewController *moreViewController;
@property (nonatomic,strong) JKTabBarItem                *moreTabBarItem;
@property (nonatomic,weak)   UIView                      *containerView;
@property (nonatomic,weak)   JKTabBar                    *tabBar;
@end

@implementation JKTabBarController
#pragma mark - navigation item
- (UINavigationItem *)navigationItem{
    if(self.selectedControllerNavigationItem)
        return self.selectedViewController.navigationItem;
    else
        return [super navigationItem];
}

#pragma mark - Private Methods
- (void)_setupAppearence{
    [self.tabBar removeFromSuperview];
    [self.containerView removeFromSuperview];
    
    JKTabBar *tabBar        = [[JKTabBar alloc] initWithFrame:CGRectZero];
    self.tabBar             = tabBar;
    tabBar.delegate         = self;
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.containerView = containerView;
    
    [self.view addSubview:containerView];
    [self.view addSubview:tabBar];
    
    
    self.tabBarPosition = JKTabBarPositionBottom;
}

- (UIViewController *)_viewControllerForTabBarItem:(JKTabBarItem *)item{
    if (item == nil) {
        return nil;
    }
    
    if(item == self.moreTabBarItem) {
        return self.moreNavigationController;
    }
    
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
        
        BOOL isTabTitleHidden = NO;
        if([viewController respondsToSelector:@selector(tabTitleHidden)])
            isTabTitleHidden = viewController.tabTitleHidden;
        
        if([viewController respondsToSelector:@selector(tabTitle)])
            itemTitle = viewController.tabTitle;
        
        if([viewController respondsToSelector:@selector(selectedTabImage)])
            selectedImage = viewController.selectedTabImage;
        
        if([viewController respondsToSelector:@selector(unselectedTabImage)])
            unselectedImage = viewController.unselectedTabImage;
        
        item = [[JKTabBarItem alloc] initWithTitle:(isTabTitleHidden ? nil : itemTitle) image:selectedImage];
        [item setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:unselectedImage];
        
        viewController.tabBarItem_jk = item;
    }
    return item;
}

- (UIView *)traverseSubviewsToGetViewOfClass:(Class)viewClass inView:(UIView *)view{
    if(!view) return nil;
    
    if([view isKindOfClass:[viewClass class]])
        return view;
    else
        return [self traverseSubviewsToGetViewOfClass:viewClass inView:view.subviews.firstObject];
}

- (void)_selectTabBarItem:(JKTabBarItem *)tabBarItem{
    UIViewController *viewController = [self _viewControllerForTabBarItem:tabBarItem];
    
    if(viewController == self.selectedViewController) return;
    
    [self.selectedViewController willMoveToParentViewController:nil];
    [self.selectedViewController.view removeFromSuperview];
    [self.selectedViewController removeFromParentViewController];
    
    [self addChildViewController:viewController];
    [self.containerView addSubview:viewController.view];
    viewController.view.frame = self.containerView.bounds;
    viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.selectedViewController = viewController;
    _selectedIndex = [self.tabBar.items indexOfObject:tabBarItem];
    [self adjustSelectedViewControllerInsetsIfNeeded];
    
    [viewController didMoveToParentViewController:self];
}

- (void)adjustSelectedViewControllerInsetsIfNeeded {
    if(self.shouldAdjustSelectedViewContentInsets) {
        UIScrollView *toppestScrollView = (UIScrollView *)[self traverseSubviewsToGetViewOfClass:[UIScrollView class] inView:self.selectedViewController.view];
        if(toppestScrollView.contentInset.bottom == 0.0f) { //Won't adjust scrollView contentInsets if scrollview contentInset have already set.
            UIEdgeInsets scrollViewContentInsets = (UIEdgeInsets)toppestScrollView.contentInset;
            scrollViewContentInsets.bottom = CGRectGetHeight(self.tabBar.bounds);
            toppestScrollView.contentInset = scrollViewContentInsets;
        }
    }
}

#pragma mark - Property Methods
- (BOOL)isTabBarHidden{
    CGRect viewBounds = self.view.bounds;
    CGRect tabBarFrame = self.tabBar.frame;
    
    switch (self.tabBarPosition) {
        case JKTabBarPositionTop:
            return (tabBarFrame.origin.y == -[self.class tabBarHeight]);
        case JKTabBarPositionLeft:
            return (tabBarFrame.origin.x == -[self.class tabBarHeight]);
        case JKTabBarPositionRight:
            return (tabBarFrame.origin.x == viewBounds.size.width);
        default:
            return (tabBarFrame.origin.y == viewBounds.size.height);
    }
}

+ (CGFloat)tabBarHeight {
    return JKTabBarDefaultHeight;
}

- (void)setTabBarHidden:(BOOL)tabBarHidden{
    [self setTabBarHidden:tabBarHidden animated:NO];
}

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated{
    _tabBarHidden = hidden;
    
    CGRect tabBarFrame = self.tabBar.frame;
    CGRect viewBounds = self.view.bounds;
    CGRect containerViewFrame = self.containerView.frame;
    
    if(self.shouldAdjustSelectedViewContentInsets) {
        if(hidden){
            tabBarFrame.origin.y = viewBounds.size.height;
        }else{
            tabBarFrame.origin.y = viewBounds.size.height - [self.class tabBarHeight];
        }
        containerViewFrame = viewBounds;
    } else {
        if(hidden){
            tabBarFrame.origin.y = viewBounds.size.height;
            containerViewFrame = viewBounds;
            containerViewFrame.size.height += self.tabBarBackgroundTopInset;
        }else{
            tabBarFrame.origin.y = viewBounds.size.height - [self.class tabBarHeight];
            containerViewFrame.size.height = viewBounds.size.height - [self.class tabBarHeight] + self.tabBarBackgroundTopInset;
        }
    }
    
    self.tabBar.userInteractionEnabled = NO;
    [UIView animateWithDuration:animated ? UINavigationControllerHideShowBarDuration : 0
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.tabBar.frame = tabBarFrame;
                         self.containerView.frame = containerViewFrame;
                     } completion:^(BOOL finished) {
                         self.tabBar.userInteractionEnabled = YES;
                     }];
}

- (void)setTabBarPosition:(JKTabBarPosition)tabBarPosition{
    _tabBarPosition = tabBarPosition;
    
    CGRect tabBarFrame,containerViewFrame;
    CGRectEdge rectEdge;
    NSUInteger tabBarAutoResizingMask;
    switch (tabBarPosition) {
        case JKTabBarPositionTop:
            rectEdge = CGRectMinYEdge;
            tabBarAutoResizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
            break;
        case JKTabBarPositionLeft:
            rectEdge = CGRectMinXEdge;
            tabBarAutoResizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
            break;
        case JKTabBarPositionRight:
            rectEdge = CGRectMaxXEdge;
            tabBarAutoResizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
            break;
        default:
            rectEdge = CGRectMaxYEdge;
            tabBarAutoResizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
            break;
    }
    
    CGRectDivide(self.view.bounds, &tabBarFrame, &containerViewFrame, self.class.tabBarHeight , rectEdge);
    self.tabBar.frame = tabBarFrame;
    if(self.shouldAdjustSelectedViewContentInsets) {
        containerViewFrame = self.view.bounds;
    } else {
        containerViewFrame.size.height = containerViewFrame.size.height + self.tabBarBackgroundTopInset;
    }
    self.containerView.frame = containerViewFrame;
    
    self.containerView.autoresizingMask  = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tabBar.autoresizingMask         = tabBarAutoResizingMask;
    
    self.tabBar.orientation = (JKTabBarIsVertical(tabBarPosition) ? JKTabBarOrientationVertical : JKTabBarOrientationHorizontal);
    [self setTabBarHidden:self.tabBarHidden];
}

- (UINavigationController *)moreNavigationController{
    if(!_moreNavigationController) {
        _JKTabBarMoreViewController *moreViewController = [[_JKTabBarMoreViewController alloc] initWithStyle:UITableViewStylePlain];
        UINavigationController *navigationController    = [[UINavigationController alloc] initWithRootViewController:moreViewController];
        _moreViewController = moreViewController;
        _moreNavigationController = navigationController;
        _moreViewController.tabBarController = self;
    }
    return _moreNavigationController;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex{
    if(_selectedIndex == selectedIndex) return;
    if(selectedIndex > self.tabBar.items.count-1){
        [[NSException exceptionWithName:NSRangeException reason:@"Selected index is larger than total count of TabBar items" userInfo:nil] raise];
        return;
    }
    
    _selectedIndex = selectedIndex;
    JKTabBarItem *item = self.tabBar.items[selectedIndex];
    [item sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (BOOL)shouldShowMore{
    return (self.viewControllers.count > JKTabBarMaximumItemCount ? YES : NO);
}

- (void)setTabBarBackgroundTopInset:(CGFloat)tabBarBackgroundTopInset{
    _tabBarBackgroundTopInset = tabBarBackgroundTopInset;
    [self setTabBarPosition:self.tabBarPosition];
}

- (void)setShouldAdjustSelectedViewContentInsets:(BOOL)shouldAdjustSelectedViewContentInsets {
    _shouldAdjustSelectedViewContentInsets = shouldAdjustSelectedViewContentInsets;
    [self setTabBarPosition:self.tabBarPosition];
}

#pragma mark - Initialition

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self _setupAppearence];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _setupAppearence];
    }
    return self;
}

#pragma mark - ViewCycle
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setTabBarPosition:self.tabBarPosition];
}

#pragma mark - Public Methods
- (void)setViewControllers:(NSArray *)viewControllers{
    [self setViewControllers:viewControllers animated:NO];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated{
    /*! Need FIX: Not yet impletment animation effect. */
    _viewControllers = [viewControllers copy];
    
    NSMutableArray *items = [NSMutableArray array];
    [viewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *stop) {
        UIViewController *rootViewController = viewController;
        if([viewController isKindOfClass:[UINavigationController class]]){
            /* navigation controller is ignore by default and seek for the root view controller */
            UINavigationController *navigationController = (UINavigationController *)viewController;
            rootViewController = (navigationController.viewControllers.count ? navigationController.viewControllers[0] : rootViewController);
        }
        
        JKTabBarItem *item;
        if(idx == JKTabBarMaximumItemCount-1 && self.shouldShowMore){
            /* add 'more' tab bar item if index is out of maximum count */
            *stop = YES;
            item = [self _tabBarItemsForViewController:self.moreNavigationController];
            self.moreTabBarItem = item;
        }else{
            item = [self _tabBarItemsForViewController:rootViewController];
        }
        [items addObject:item];
        
        if([self.delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)]){
            item.enabled = [self.delegate tabBarController:self shouldSelectViewController:rootViewController];
        }
    }];
    self.tabBar.items = items;
    
    //Realod More TableView Controller to update contents.
    if(self.shouldShowMore) [self.moreViewController.tableView reloadData];
}

#pragma mark - JKTabBarDelegate
- (void)tabBar:(JKTabBar *)tabBar didSelectItem:(JKTabBarItem *)item{
    
    if([self.delegate respondsToSelector:@selector(tabBarController:willSelectViewController:)])
        [self.delegate tabBarController:self willSelectViewController:[self _viewControllerForTabBarItem:item]];
    
    [self _selectTabBarItem:item];
    
    /*! Need FIX: self.navigationController should update it's navigation item */
    if(self.selectedControllerNavigationItem){
        BOOL navigationBarHidden = self.navigationController.navigationBarHidden;
        [self.navigationController setNavigationBarHidden:YES];
        [self.navigationController setNavigationBarHidden:navigationBarHidden];
    }
    
    if([self.delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)])
        [self.delegate tabBarController:self didSelectViewController:[self _viewControllerForTabBarItem:item]];
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
