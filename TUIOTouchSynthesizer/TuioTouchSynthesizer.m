//
//  TuioTouchSynthesizer.m
//  TUIOTouchSynthesizer
//
//  Created by Simon Heys 02/02/2013.
//  Copyright (c) 2013 Simon Heys Limited. All rights reserved.
//

#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "TuioTouchSynthesizer.h"
#import "KIFEventProxy.h"
#import "UITouch-KIFAdditions.h"
#import <UIKit/UIEvent.h>
#import "TuioClient.h"

@interface TuioTouchSynthesizer () <TuioCursorListener> {
    CFRunLoopSourceRef runLoopSource;
    NSMutableArray* commands;
}
@property (nonatomic, retain) NSMutableArray *cursorTouches;
@property (nonatomic, retain) TuioClient *tuioClient;
@property (nonatomic, retain) UIView *view;
@property (nonatomic) BOOL shouldSynthesize;
@property (nonatomic) NSUInteger port;
@end

@implementation TuioTouchSynthesizer

- (void)dealloc
{
    self.shouldSynthesize = NO;
    [_tuioClient release];
    [_view release];
    [_cursorTouches release];
    [super dealloc];
}

- (void)startSynthesizing
{
    if ( !self.shouldSynthesize ) {
        self.shouldSynthesize = YES;
        self.tuioClient = [[[TuioClient alloc] initWithPortNumber:self.port] autorelease];
        self.tuioClient.cursorDelegate = self;
    }
}

- (void)stopSynthesizing
{
    if ( self.shouldSynthesize ) {
        self.shouldSynthesize = NO;
        self.tuioClient.cursorDelegate = nil;
        self.tuioClient = nil;
    }
}

- (id)initWithView:(UIView *)view port:(NSUInteger)port
{
    self = [super init];
    if (self) {
        self.cursorTouches = [[NSMutableArray new] autorelease];    
        self.shouldSynthesize = NO;
        self.view = view;
        self.port = port;
    }
    return self;
}


- (void)runEventLoop
{
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    @autoreleasepool {
        NSArray *touches = [self.cursorTouches valueForKeyPath:@"touch"];
        if ( [touches count] > 0 ) {
            NSDictionary *cursorTouch;
            NSMutableArray *touchesToRemove = [[NSMutableArray new] autorelease];
            UIEvent *event = [self _eventWithTouches:touches];                    
            for ( cursorTouch in self.cursorTouches ) {
                if ( self.showTouches ) {
                    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0,0,10,10)] autorelease];
                    view.backgroundColor = [UIColor redColor];
                    TuioCursor *cursor = cursorTouch[@"cursor"];
                    view.center = cursor.position;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [window.rootViewController.view addSubview:view];
                        [UIView animateWithDuration:0.1f animations:^{
                            view.alpha = 0.0f;
                        }
                        completion:^(BOOL finished) {
                            [view removeFromSuperview];
                        }];
                    });
                }
                UITouch *touch = cursorTouch[@"touch"];
                if ( touch.phase == UITouchPhaseEnded ) {
                    [touchesToRemove addObject:cursorTouch];
                }
            }
            if ( [touchesToRemove count] > 0 ) {
                NSLog(@"touchesToRemove:%@",touchesToRemove);
                [self.cursorTouches removeObjectsInArray:touchesToRemove];
            }
            [[UIApplication sharedApplication] sendEvent:event];
        }
    }
}

// ____________________________________________________________________________________________________ touch simulation

#pragma mark - touch simulation

- (UITouch *)touchForCursor:(TuioCursor *)cursor
{
    NSDictionary *cursorTouch;    
    for ( cursorTouch in self.cursorTouches ) {
        if ( [cursorTouch[@"cursor"] isEqual:cursor] ) {
            return cursorTouch[@"touch"];
        }
    }    
    return nil;
}

- (void)removeTouchForCursor:(TuioCursor *)cursor
{
    NSDictionary *cursorTouch;
    NSMutableArray *touchesToRemove = [[NSMutableArray new] autorelease];    
    for ( cursorTouch in self.cursorTouches ) {
        if ( [cursorTouch[@"cursor"] isEqual:cursor] ) {
            [touchesToRemove addObject:cursorTouch];
        }
    }
    [self.cursorTouches removeObjectsInArray:touchesToRemove];
}

- (void)tuioCursorAdded:(TuioCursor *)newCursor
{
    NSLog(@"tuioCursorAdded:%@",newCursor);
    
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    UITouch *touch = [[[UITouch alloc] initAtPoint:newCursor.position inView:self.view] autorelease];
    [touch setLocationInWindow:[window convertPoint:newCursor.position fromView:self.view]];
    
    NSDictionary *cursorTouch = @{
        @"cursor":newCursor,
        @"touch":touch
    };
    [self.cursorTouches addObject:cursorTouch];
}

- (void)tuioCursorUpdated:(TuioCursor *)updatedCursor
{
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    UITouch *touch = [self touchForCursor:updatedCursor];
    if ( nil != touch ) {
        [touch setLocationInWindow:[window convertPoint:updatedCursor.position fromView:self.view]];
        [touch setPhase:UITouchPhaseMoved];
    }
}

- (void)tuioCursorRemoved:(TuioCursor *)deadCursor
{
    UITouch *touch = [self touchForCursor:deadCursor];
    if ( nil != touch ) {
        [touch setPhase:UITouchPhaseEnded];
    }
}

- (void)tuioCursorFrameFinished
{
    [self runEventLoop];
}

// ____________________________________________________________________________________________________ event creation

#pragma mark - event creation

- (UIEvent *)_eventWithTouches:(NSArray *)touches
{
    UIEvent *event = [[UIApplication sharedApplication] performSelector:@selector(_touchesEvent)];
    
    CGPoint location = [touches[0] locationInView:((UITouch *)touches[0]).window];
    KIFEventProxy *eventProxy = [[KIFEventProxy alloc] init];
    eventProxy->x1 = location.x;
    eventProxy->y1 = location.y;
    eventProxy->x2 = location.x;
    eventProxy->y2 = location.y;
    eventProxy->x3 = location.x;
    eventProxy->y3 = location.y;
    eventProxy->sizeX = 0.0;
    eventProxy->sizeY = 5.0;
    eventProxy->flags = ([touches[0] phase] == UITouchPhaseEnded) ? 0x1010180 : 0x3010180;
    eventProxy->type = 3001;	

    NSSet *allTouches = [event allTouches];
    [event _clearTouches];
    [allTouches makeObjectsPerformSelector:@selector(autorelease)];
    [event _setGSEvent:(struct __GSEvent *)eventProxy];
    for ( UITouch *touch in touches ) {
        [event _addTouch:touch forDelayedDelivery:NO];
    }
    [eventProxy release];
    
    return event;
}

@end

// ____________________________________________________________________________________________________ event timestamp

#pragma mark - event timestamp

/*
UIEvent created with _touchesEvent does not have a correct timestamp, so this category adds one
A correct timestamp results in better behaviour with UIScrollView flicking
*/

NSString *const kSynthesizedTimestampKey = @"kSynthesizedTimestampKey";

@implementation UIEvent (SynthesizeTimestamp)

- (id)init
{
    self = [super init];
    if (self) {
        [self synthesizeTimestamp];
    }
    return self;
}

- (void)synthesizeTimestamp
{
	objc_setAssociatedObject(self, kSynthesizedTimestampKey, @([[NSProcessInfo processInfo] systemUptime]), OBJC_ASSOCIATION_COPY);
}

- (NSTimeInterval)timestamp
{
    id synthetizeTimestamp = objc_getAssociatedObject(self, kSynthesizedTimestampKey);
    if ( nil != synthetizeTimestamp ) {
        return [synthetizeTimestamp floatValue];
    }
    return [[NSProcessInfo processInfo] systemUptime];
}
@end

