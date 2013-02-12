//
//  TuioTouchSynthesizer.h
//  TUIOTouchSynthesizer
//
//  Created by Simon Heys on 02/02/2013.
//  Copyright (c) 2013 Simon Heys Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TuioTouchSynthesizer : NSObject
@property (nonatomic) BOOL showTouches;
- (id)initWithView:(UIView *)view port:(NSUInteger)port;
- (void)startSynthesizing;
- (void)stopSynthesizing;
@end
