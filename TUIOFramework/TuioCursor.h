//
//  TuioCursor.h
//  TUIO
//
//  Created by Bridger Maxwell on 2/16/08.
//  Copyright 2008 Fiery Ferret. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TuioCursor : NSObject {
	unsigned int _sID;
	CGPoint _pos;
	CGPoint _originalPos;
	float _rotAccel;
	float _moveAccel;
}

- (id) initWithID:(unsigned int)sID 
		 position:(CGPoint)pos 
	rotationAccel:(float)rotAccel 
	movementAccel:(float)moveAccel;

@property (readonly) unsigned int uniqueID;
@property CGPoint position;
@property CGPoint originalPosition;
@property float rotationAccel, movementAccel;


@end
