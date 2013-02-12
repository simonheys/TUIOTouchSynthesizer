//
//  TuioClient.m
//  TUIO
//
//  Created by Bridger Maxwell on 1/3/08.
//  Copyright 2008 Fiery Ferret. All rights reserved.
//

#import "TuioClient.h"

@interface TuioClient ()
@property (nonatomic, retain) NSMutableDictionary *liveCursors;
@property (nonatomic, retain) NSMutableDictionary *liveObjects;
@property (nonatomic, retain) NSFileHandle *fileHandle;
@end

@implementation TuioClient

- (void)dealloc
{
	CFRunLoopRemoveSource(CFRunLoopGetCurrent(), cfSource, kCFRunLoopDefaultMode);
    CFSocketInvalidate(cfSocket);
	CFRelease(cfSource);
	CFRelease(cfSocket);
	[_fileHandle release];
	[_liveCursors release];
	[_liveObjects release];
	[super dealloc];
}

+ (void)initialize{
	CGAffineTransform transformMatrix = CGAffineTransformMakeScale(1.0,1.26);
	NSData* defaultTransform = [NSData dataWithBytes:&transformMatrix length:sizeof(CGAffineTransformIdentity)];
	
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary
								 dictionaryWithObject:defaultTransform forKey:@"TransformMatrix"];
	
    [defaults registerDefaults:appDefaults];
}

- (id)initWithPortNumber:(int)portNumber
{
	self = [super init];
	if (self)
	{
		self.liveCursors = [[[NSMutableDictionary alloc] init] autorelease];
		self.liveObjects = [[[NSMutableDictionary alloc] init] autorelease];
		int sockHandle = socket(AF_INET, SOCK_DGRAM, 0);
		self.fileHandle = [[[NSFileHandle alloc]
					  initWithFileDescriptor:sockHandle closeOnDealloc:YES] autorelease];
		struct sockaddr_in sa;
		sa.sin_family = AF_INET;
		sa.sin_addr.s_addr = htonl(INADDR_ANY);
		sa.sin_port = htons(portNumber);
		bind(sockHandle, (struct sockaddr *)&sa, sizeof(sa));
		CFSocketContext socketContext = {0, (void *)self.fileHandle, NULL, NULL, NULL};
		cfSocket = CFSocketCreateWithNative(NULL, sockHandle,
											kCFSocketReadCallBack, socketCallback, &socketContext); // CFSocketRef
		cfSource = CFSocketCreateRunLoopSource(NULL, cfSocket, 0); // CFRunLoopSourceRef
		CFRunLoopAddSource(CFRunLoopGetCurrent(), cfSource, kCFRunLoopDefaultMode);
		CFRunLoopAddSource(CFRunLoopGetCurrent(), cfSource, (CFStringRef)UITrackingRunLoopMode);
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self
			   selector:@selector(processOSCBundle:)
				   name:@"OSCBundleReadCompletionNotification" 
				 object:nil];
		
		[nc addObserver:self
			   selector:@selector(processOSCMessage:)
				   name:@"OSCMessageReadCompletionNotification" 
				 object:nil];
	}
	return self;
}



// change this to something lower if you know your messages will be smaller
#define MAX_UDP_DATAGRAM_SIZE 65504

static void socketCallback(CFSocketRef cfSocket, CFSocketCallBackType
						   type, CFDataRef address, const void *data, void *userInfo)
{
	 
	char msg[MAX_UDP_DATAGRAM_SIZE];
	struct sockaddr_in from_addr;
	socklen_t addr_len = sizeof(struct sockaddr_in);
	size_t n = recvfrom(CFSocketGetNative(cfSocket), (void *)&msg,
						MAX_UDP_DATAGRAM_SIZE, 0, (struct sockaddr *)&from_addr, &addr_len);
	
	NSData *messageData = [NSData dataWithBytes:&msg length:(n * sizeof(u_char))];

//	NSString *dataString = [[NSString alloc] initWithBytes:&msg
//												    length:(n * sizeof(u_char))
//												  encoding:NSUTF8StringEncoding];
	
	WSOSCPacket *oscPacket = [[[WSOSCPacket alloc] initWithDataFrom: messageData] autorelease];
	if ([oscPacket type] == 1) { 
		[[NSNotificationCenter defaultCenter]
		 postNotificationName:@"OSCMessageReadCompletionNotification"
		 object:oscPacket.content];
	}else if ([oscPacket type] == 2) {
		 [[NSNotificationCenter defaultCenter]
		  postNotificationName:@"OSCBundleReadCompletionNotification"
		  object:oscPacket.content];
	} 
	
}

- (void) processOSCBundle: (NSNotification *)notification
{
	WSOSCBundle *oscBundle = [notification object];
	NSArray *bundleContents = oscBundle.bundles;
	for (WSOSCMessage* message in bundleContents) {
		[[NSNotificationCenter defaultCenter]
		 postNotificationName:@"OSCMessageReadCompletionNotification"
		 object:message];
	}
}

- (void) processOSCMessage: (NSNotification *)notification
{
	WSOSCMessage *oscMessage = [notification object];
	if ([[oscMessage addressString] isEqualToString:@"/tuio/2Dcur"]) { //If there is a new cursor from an FTIR display
		NSString* cmd = [[oscMessage arguments] objectAtIndex:0];
		if ([cmd isEqualToString:@"set"]){
			
			CGPoint tuioPosition = {[[[oscMessage arguments] objectAtIndex:2] floatValue], 
									[[[oscMessage arguments] objectAtIndex:3] floatValue]};
			tuioPosition = [self calibratedPoint:tuioPosition]; //Calibrate the point to be screen-coordinates
//			printf("Cursor position: %f, %f\r",tuioPosition.x,tuioPosition.y);

			NSNumber* uniqueID = [[oscMessage arguments] objectAtIndex:1];
			TuioCursor* toUpdate = NULL;
			toUpdate = [self.liveCursors objectForKey:uniqueID];
			if (toUpdate == NULL) {
				TuioCursor* newObject = [[[TuioCursor alloc] initWithID:[uniqueID intValue]
															  position:tuioPosition
														 rotationAccel:[[[oscMessage arguments] objectAtIndex:4] floatValue]
														 movementAccel:[[[oscMessage arguments] objectAtIndex:5] floatValue]] autorelease];
				[self.liveCursors setObject:newObject forKey:uniqueID];
								
				if ([self.cursorDelegate conformsToProtocol:@protocol(TuioCursorListener)]) {
					[self.cursorDelegate tuioCursorAdded:newObject];
				}
				
			} else {
				[toUpdate setPosition:tuioPosition];
				[toUpdate setRotationAccel:[[[oscMessage arguments] objectAtIndex:4] floatValue]];
				[toUpdate setMovementAccel:[[[oscMessage arguments] objectAtIndex:5] floatValue]];
				if ([self.cursorDelegate conformsToProtocol:@protocol(TuioCursorListener)]) {
					[self.cursorDelegate tuioCursorUpdated:toUpdate];
				}
			}
		//If this was an alive packet, with a list of all the cursor that are present
		}else if ([cmd isEqualToString:@"alive"]) {
			NSMutableArray* objectList = [oscMessage arguments];
			NSPredicate* filter = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",objectList];
			NSArray* deadObjects = [[self.liveCursors allKeys] filteredArrayUsingPredicate:filter];
			for (NSNumber* deadObjectKey in deadObjects){
				TuioCursor* deadObject = [self.liveCursors objectForKey:deadObjectKey];
				[self.liveCursors removeObjectForKey:deadObjectKey];
				if ([self.cursorDelegate conformsToProtocol:@protocol(TuioCursorListener)]) {
					[self.cursorDelegate tuioCursorRemoved:deadObject];
				}
			}
		}else if ([cmd isEqualToString:@"fseq"]) {
			if ([self.cursorDelegate conformsToProtocol:@protocol(TuioCursorListener)]) {
				[self.cursorDelegate tuioCursorFrameFinished];
			}
		}	
	//If it was not a cursor, but an object (fiducial)
	} else if ([[oscMessage addressString] isEqualToString:@"/tuio/2Dobj"]) {
		NSString* cmd = [[oscMessage arguments] objectAtIndex:0];
		if ([cmd isEqualToString:@"set"]){
			
			CGPoint tuioPosition = {[[[oscMessage arguments] objectAtIndex:2] floatValue], 
									[[[oscMessage arguments] objectAtIndex:3] floatValue]};
//			printf("Cursor position: %d, %d",(int)tuioPosition.x,(int)tuioPosition.y);
			tuioPosition = [self calibratedPoint:tuioPosition]; //Calibrate the point to be screen-coordinates

			NSNumber* uniqueID = [[oscMessage arguments] objectAtIndex:1];
			TuioObject* toUpdate = NULL;
			toUpdate = [self.liveObjects objectForKey:uniqueID];
			
			if (toUpdate == NULL) {
				TuioSpeed tuioSpeed = { [[[oscMessage arguments] objectAtIndex:6] floatValue], 
										[[[oscMessage arguments] objectAtIndex:7] floatValue], 
										[[[oscMessage arguments] objectAtIndex:8] floatValue]};
				
				TuioObject* newObject = [[[TuioObject alloc] initWithID:[uniqueID intValue]
														   fiducialID:[[[oscMessage arguments] objectAtIndex:2] intValue]
															 position:tuioPosition
																angle:[[[oscMessage arguments] objectAtIndex:5] floatValue]
																speed:tuioSpeed
														rotationAccel:[[[oscMessage arguments] objectAtIndex:9] floatValue]
														movementAccel:[[[oscMessage arguments] objectAtIndex:10] floatValue]] autorelease];
				[self.liveObjects setObject:newObject forKey:uniqueID];
			} else {
				[toUpdate setPosition:tuioPosition];
				[toUpdate setAngle: [[[oscMessage arguments] objectAtIndex:5] floatValue]];
				TuioSpeed tuioSpeed = { [[[oscMessage arguments] objectAtIndex:6] floatValue], 
										[[[oscMessage arguments] objectAtIndex:7] floatValue], 
										[[[oscMessage arguments] objectAtIndex:8] floatValue]};
				[toUpdate setSpeed:tuioSpeed];
				[toUpdate setRotationAccel:[[[oscMessage arguments] objectAtIndex:9] floatValue]];
				[toUpdate setMovementAccel:[[[oscMessage arguments] objectAtIndex:10] floatValue]];
			}
		}else if ([cmd isEqualToString:@"alive"]) {
			NSMutableArray* objectList = [oscMessage arguments];
			NSPredicate* filter = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",objectList];
			NSArray* deadObjects = [[self.liveObjects allKeys] filteredArrayUsingPredicate:filter];
			for (NSNumber* deadObjectKey in deadObjects){
				TuioObject* deadObject = [self.liveObjects objectForKey:deadObjectKey];
				[self.liveObjects removeObjectForKey:deadObjectKey];
//				printf("Object ID %d Removed, Fiducial ID %d \r",[deadObject uniqueID],[deadObject fiducialID]);
			}
		}
	}
}

- (CGPoint) calibratedPoint:(CGPoint) point {
    CGPoint newPoint = point;
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    CGRect screen = [window convertRect:[[UIScreen mainScreen] applicationFrame] toView:window.rootViewController.view];    
	newPoint.x = screen.size.width * point.x;
	newPoint.y = screen.size.height * point.y;
	return newPoint;
}

@end
