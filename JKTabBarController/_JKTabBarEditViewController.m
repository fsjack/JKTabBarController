//
//  _JKTabBarEditViewController.m
//  JKTabBarControllerDemo
//
//  Created by Jackie CHEUNG on 13-6-18.
//  Copyright (c) 2013年 Weico. All rights reserved.
//

#import "_JKTabBarEditViewController.h"

@interface _JKTabBarEditViewController ()

@end

@implementation _JKTabBarEditViewController
#pragma mark - view
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"Configuration", @"");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneAction)];
}

#pragma mark - action
- (void)doneAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
