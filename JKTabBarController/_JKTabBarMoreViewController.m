//
//  _JKTabBarMoreViewController.m
//  JKTabBarControllerDemo
//
//  Created by Jackie CHEUNG on 13-6-18.
//  Copyright (c) 2013年 Weico. All rights reserved.
//

#import "_JKTabBarMoreViewController.h"
#import "JKTabBarController.h"
#import "JKTabBarItem.h"
@interface _JKTabBarMoreViewController ()
@property (nonatomic,readonly) NSArray *viewControllers;
@end

@implementation _JKTabBarMoreViewController
#pragma mark - dealloc
- (void)dealloc{
    [_tabBarController removeObserver:self forKeyPath:@"customizableViewControllers"];
}

#pragma mark - view
- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"More", @"");
}

#pragma mark - property
- (NSArray *)viewControllers{
    if (self.tabBarController.viewControllers.count < JKTabBarMaximumItemCount) return nil;
    NSUInteger totalViewControllersCount = self.tabBarController.viewControllers.count;
    NSUInteger fromIndex = JKTabBarMaximumItemCount-1;
    return  [self.tabBarController.viewControllers subarrayWithRange:NSMakeRange(fromIndex,
                                                                                 totalViewControllersCount-fromIndex
                                                                                 )];
}

- (void)setTabBarController:(JKTabBarController *)tabBarController{
    if(_tabBarController == tabBarController) return;
    [_tabBarController removeObserver:self forKeyPath:@"customizableViewControllers"];
    _tabBarController = tabBarController;
    [_tabBarController addObserver:self forKeyPath:@"customizableViewControllers" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"customizableViewControllers"]){
        NSArray *customizableViewControllers = change[NSKeyValueChangeNewKey];
        if(customizableViewControllers.count)
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)];
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - action
- (void)editAction:(UIBarButtonItem *)item{
}

#pragma mark - uitableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.viewControllers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    UIViewController *viewController = self.viewControllers[indexPath.row];
    JKTabBarItem *item   = viewController.tabBarItem_jk;
    if(item){
        cell.textLabel.text  = item.title;
        cell.imageView.image = item.image;
    }else{
        cell.textLabel.text  = NSLocalizedString(@"No Title", @"");
    }
    
    return cell;
}

#pragma mark - uitableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *selectedViewController = self.viewControllers[indexPath.row];
    if([selectedViewController isKindOfClass:[UINavigationController class]]){
        [self.navigationController presentViewController:selectedViewController animated:YES completion:nil];
    }else
        [self.navigationController pushViewController:self.viewControllers[indexPath.row] animated:YES];
}

@end
