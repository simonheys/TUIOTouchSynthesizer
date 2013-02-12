//
//  TuioCursor.m
//  TUIO
//
//  Created by Bridger Maxwell on 2/16/08.
//  Copyright 2008 Fiery Ferret. All rights reserved.
//

#import "TuioCursor.h"


@implementation TuioCursor

@synthesize uniqueID = _sID;
@synthesize position = _pos;
@synthesize originalPosition = _originalPos;
@synthesize rotationAccel = _rotAccel;
@synthesize movementAccel = _moveAccel;

- (id) initWithID:(unsigned int)sID 
		 position:(CGPoint)pos 
	rotationAccel:(float)rotAccel 
	movementAccel:(float)moveAccel {
	
	if (self = [super init]) {
		_sID = sID;
		_pos = pos;
		_originalPos = pos;
		_rotAccel = rotAccel;
		_moveAccel = moveAccel;
	}
	return self;
	
}


@end
