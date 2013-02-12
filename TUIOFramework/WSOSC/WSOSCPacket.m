//
//  WSOSCPacket.m
//  WSOSC
//
//  Created by Woon Seung Yeo on Thu Mar 04 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "WSOSCPacket.h"

#define BUNDLE  @"#bundle"
#define	SLASH   @"/"

@interface WSOSCPacket ()
@property (nonatomic, retain) id content;
@end

@implementation WSOSCPacket

- (void)dealloc {
    [_content release];
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:_type forKey:@"OSCPacketType"];
    [coder encodeObject:self.content forKey:@"OSCPacketContent"];
}

- (id)initWithCoder:(NSCoder *)coder {
	if (self = [super init]) {
        _type = [coder decodeIntForKey:@"OSCPacketType"];
        self.content = [coder decodeObjectForKey:@"OSCPacketContent"];
    }
    return self;
}


- (id)init {
    self = [super init];
    return self;
}

- (id)initWithDataFrom:(NSData *)data {
    self = [super init];
    [self parseFrom:data];
    return self;
}


+ (id)packetParsedFrom:(NSData *)data {
    return [[[self alloc] initWithDataFrom:data] autorelease];
}

- (void)parseFrom:(NSData *)data {
    // Check the length of string: if not a multiple of 4, invalid.
    if ([data length] % 4) {
        _type = 0;
        NSLog(@"Not a valid OSC packet: size is not a multiple of 4. %d mod 4 = %d",[data length],[data length] % 4);
        return;
    }
    // Check if it's a message or a bundle
	
    if ([[[[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0,7)]
							   encoding:NSUTF8StringEncoding] autorelease] isEqualToString:BUNDLE]) {
        _type = 2;      // Bundle!
        //_content = [[WSOSCBundle alloc] init];
        //[_content parseFrom:data];
        self.content = [[[WSOSCBundle alloc] initWithDataFrom:data] autorelease];
    }
	else if ([[[[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0,1)]
							   encoding:NSUTF8StringEncoding] autorelease] isEqualToString:SLASH]) {
         _type = 1;     // Message!
        //_content = [[WSOSCMessage alloc] init];
        //[_content parseFrom:data];
        self.content = [[[WSOSCMessage alloc] initWithDataFrom:data] autorelease];
    }
    else {
        _type = -1;      // Invalid!
        NSLog(@"Not a valid OSC packet: neither a message nor a bundle.");
    }
    return;
}


- (int)type {
    return _type;
}

@end
