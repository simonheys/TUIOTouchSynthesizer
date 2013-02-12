//
//  TuioObject.m
//  TUIO
//
//  Created by Bridger Maxwell on 2/16/08.
//  Copyright 2008 Fiery Ferret. All rights reserved.
//

#import "TuioObject.h"


@implementation TuioObject

- (id) initWithID:(unsigned int)sID 
	   fiducialID:(unsigned int) fID 
		 position:(CGPoint)pos 
			angle:(float)angle 
			speed:(TuioSpeed)speed 
	rotationAccel:(float)rotAccel 
	movementAccel:(float)moveAccel {
	if (self = [super initWithID:sID 
						position:pos 
				   rotationAccel:rotAccel
				   movementAccel:moveAccel]) {
		_fidID = fID;
		_angle = angle;
		_speed = speed;
    }
	return self;

}

- (void) printInfo{
	printf("sid: %d fid: %d 's Info:\rPosition: %f , %f \rAngle: %f \r\r",_sID,_fidID,_pos.x,_pos.y,_angle);
}


@synthesize fiducialID = _fidID;
@synthesize angle = _angle;
@synthesize speed = _speed;

@end
