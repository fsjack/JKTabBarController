//
//  JKAppearenceProxy.m
//  JKTabBarControllerDemo
//
//  Created by Jackie CHEUNG on 13-6-17.
//  Copyright (c) 2013年 Weico. All rights reserved.
//

#import "_JKAppearanceProxy.h"
@interface _JKAppearanceProxy()
@property (nonatomic)           Class customizableClass;
@property (nonatomic,strong)    NSMutableArray *appearanceInvocations;
@end

static NSMutableDictionary *_allAppearances = nil;

@implementation _JKAppearanceProxy
#pragma mark - static methods
+ (id)appearanceForClass:(Class)class{
    // create the dictionary if not exists
    // use a dispatch to avoid problems in case of concurrent calls
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_allAppearances)
            _allAppearances = [[NSMutableDictionary alloc]init];
    });
    
    if (![_allAppearances objectForKey:NSStringFromClass(class)]){
        _JKAppearanceProxy *appearance = [[_JKAppearanceProxy alloc] init];
        appearance.customizableClass = class;
        [_allAppearances setObject:appearance forKey:NSStringFromClass(class)];
        
        return appearance;
    }else{
        return [_allAppearances objectForKey:NSStringFromClass(class)];
    }
}

#pragma mark - property
- (NSMutableArray *)appearanceInvocations{
    if(!_appearanceInvocations){
        _appearanceInvocations = [NSMutableArray array];
    }
    return _appearanceInvocations;
}

#pragma mark - invocation
- (void)forwardInvocation:(NSInvocation *)anInvocation;{
    // tell the invocation to retain arguments
    [anInvocation retainArguments];
    
    // add the invocation to the array
    [self.appearanceInvocations addObject:anInvocation];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [self.customizableClass instanceMethodSignatureForSelector:aSelector];
}

#pragma mark - public methods
- (void)startForwarding:(id)sender{
    if(![sender isKindOfClass:self.customizableClass]) {
        [[NSException exceptionWithName:NSInvalidArgumentException reason:@"argument should belong to the class that call 'appearanceForClass'" userInfo:nil] raise];
        return;
    }
    
    for (NSInvocation *invocation in self.appearanceInvocations) {
        [invocation setTarget:sender];
        [invocation invoke];
    }
}

#pragma mark - description
- (NSString *)description{
    return [NSString stringWithFormat:@"%@ <Customizable class: %@> with invocations %@",[super description],self.customizableClass,self.appearanceInvocations];
}

@end
