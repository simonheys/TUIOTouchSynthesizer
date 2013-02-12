//
//  TuioObject.h
//  TUIO
//
//  Created by Bridger Maxwell on 2/16/08.
//  Copyright 2008 Fiery Ferret. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TuioCursor.h"

typedef struct _TuioSpeed
{
	float x;
	float y;
	float r;
} TuioSpeed;

@interface TuioObject : TuioCursor {
	unsigned int _fidID;
	float _angle;
	TuioSpeed _speed;
}

- (id) initWithID:(unsigned int)sID 
	   fiducialID:(unsigned int) fID 
		 position:(CGPoint)pos 
			angle:(float)angle 
			speed:(TuioSpeed)speed 
	rotationAccel:(float)rotAccel 
	movementAccel:(float)moveAccel;

- (void) printInfo;

@property (readonly) unsigned int fiducialID ;
@property float angle;
@property TuioSpeed speed;

@end
