//
//  TuioClient.h
//  TUIO
//
//  Created by Bridger Maxwell on 1/3/08.
//  Copyright 2008 Fiery Ferret. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <netinet/in.h>
#import <net/if.h>
#import "WSOSCPacket.h"
#import "TuioObject.h"


@protocol TuioCursorListener <NSObject>
- (void) tuioCursorAdded: (TuioCursor*) newCursor;
- (void) tuioCursorUpdated: (TuioCursor*) updatedCursor;
- (void) tuioCursorRemoved: (TuioCursor*) deadCursor;
- (void) tuioCursorFrameFinished;
@end


@protocol TuioObjectListener <NSObject>
- (void) tuioObjectAdded: (TuioObject*) newObject;
- (void) tuioObjectUpdated: (TuioObject*) updateObject;
- (void) tuioObjectRemoved: (TuioObject*) deadObject;
@end


@interface TuioClient : NSObject {
	CFSocketRef cfSocket;
	CFRunLoopSourceRef cfSource;
}

@property (nonatomic, assign) id<TuioCursorListener> cursorDelegate;
@property (nonatomic, assign) id<TuioObjectListener> objectDelegate;

- (id)initWithPortNumber:(int)pn;
- (void)dealloc;
- (void) processOSCMessage: (NSNotification *)notification;
- (void) processOSCBundle: (NSNotification *)notification;
- (CGPoint) calibratedPoint:(CGPoint) point;

static void socketCallback(CFSocketRef cfSocket, CFSocketCallBackType
						   type, CFDataRef address, const void *data, void *userInfo);

@end
