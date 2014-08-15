//
//  WeakRefrenceObject.m
//  WhistleIm
//
//  Created by liuke on 13-12-2.
//  Copyright (c) 2013年 Ruijie. All rights reserved.
//

#import "WeakReferenceObject.h"

@interface WeakReferenceObject()
{
    __weak id baseObject;
}

@end

@implementation WeakReferenceObject

@synthesize baseObject;

- (id)initWithObject:(id)anObject {
    self = [super init];
    if (self) {
        baseObject = anObject;
    }
    return self;
}
+ (WeakReferenceObject *)weakReferenceObjectWithObject:(id)anObject
{
    return [[self alloc] initWithObject:anObject];
}

@end
