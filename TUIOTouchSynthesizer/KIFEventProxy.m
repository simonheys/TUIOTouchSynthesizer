//
//  KIFEventProxy.m
//  Extracted from UIView-KIFAdditions.m
//  KIF
//
//  Created by Eric Firestone on 5/20/11.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import <objc/runtime.h>
#import "KIFEventProxy.h"


@implementation KIFEventProxy
@end



@interface NSObject (UIWebDocumentViewInternal)

- (void)tapInteractionWithLocation:(CGPoint)point;

@end

@interface UIView (KIFAdditionsPrivate)

- (UIEvent *)_eventWithTouch:(UITouch *)touch;

@end
