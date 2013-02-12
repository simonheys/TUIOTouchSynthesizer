//
//  WSOSCMessage.m
//  WSOSC
//
//  Created by Woon Seung Yeo on Fri Mar 05 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "WSOSCMessage.h"

@interface WSOSCMessage ()
@property (nonatomic) BOOL hasTypeTag;
@property (nonatomic, retain) NSString *addressString;
@property (nonatomic, retain) NSArray *addressPattern;
@property (nonatomic, retain) NSString *typeTagString;
@property (nonatomic, retain) NSMutableArray *arguments;
@end

@implementation WSOSCMessage

- (void)dealloc {
    [_addressString release];
    [_addressPattern release];
    [_typeTagString release];
    [_arguments release];
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeBool:self.hasTypeTag forKey:@"OSCMessageHasTypeTag"];
    [coder encodeObject:self.addressString forKey:@"OSCAddressString"];
	[coder encodeObject:self.addressPattern forKey:@"OSCAddressPattern"];
	[coder encodeObject:self.typeTagString forKey:@"OSCTypeTagString"];
	[coder encodeObject:self.arguments forKey:@"OSCArguments"];
}

- (id)initWithCoder:(NSCoder *)coder {
	if (self = [super init]) {
        self.hasTypeTag = [coder decodeBoolForKey:@"OSCMessageHasTypeTag"];
        self.addressString = [coder decodeObjectForKey:@"OSCAddressString"];
        self.addressPattern = [coder decodeObjectForKey:@"OSCAddressPattern"];
        self.typeTagString = [coder decodeObjectForKey:@"OSCTypeTagString"];
        self.arguments = [coder decodeObjectForKey:@"OSCArguments"];
    }
    return self;
}


- (id)init {
    if (self = [super init]) {
        self.hasTypeTag = YES;
        self.addressString = [[[NSString alloc] init] autorelease];
        self.addressPattern = [[[NSMutableArray alloc] init] autorelease];
        self.typeTagString = [[[NSString alloc] init] autorelease];
        self.arguments = [[[NSMutableArray alloc] init] autorelease];
    }
	return self;
}


- (id)initWithDataFrom:(NSData *)data {
    if (self = [super init]) {
        self.hasTypeTag = YES;
        self.addressString = [[[NSString alloc] init] autorelease];
        self.addressPattern = [[[NSMutableArray alloc] init] autorelease];
        self.typeTagString = [[[NSString alloc] init] autorelease];
        self.arguments = [[[NSMutableArray alloc] init] autorelease];
        [self parseFrom:data];
    }
	return self;
}

+ (id)messageParsedFrom:(NSData *)data {
    return [[[self alloc] initWithDataFrom:data] autorelease];
}

- (void)parseFrom:(NSData *)data {
    // Variables necessary for parsing arguments
    int32_t argumentInt32;
    float_t argumentFloat32;
	NSSwappedFloat float32Bits;
    NSString *argumentString;

    int index;
    
    // Parse address pattern
	int nullOffset = [self byteOffSet:'\0' inData:data];
    self.addressString = [[[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0,nullOffset)]
										   encoding:NSUTF8StringEncoding] autorelease];
   /// _addressString = [[data componentsSeparatedByString:@"\0"] objectAtIndex:0];
    self.addressPattern = [self.addressString pathComponents];
    
    // Parse typetag string
    int32_t typeTagIndex = [self.addressString length] + (4 - ([self.addressString length]%4) + 1);
    NSData *tagsAndArguments = [data subdataWithRange:NSMakeRange(typeTagIndex,[data length] - typeTagIndex)];

    // Parse typeTag
	nullOffset = [self byteOffSet:'\0' inData:tagsAndArguments];
	self.typeTagString = [[[NSString alloc] initWithData:[tagsAndArguments subdataWithRange:NSMakeRange(0,nullOffset)]
										   encoding:NSUTF8StringEncoding] autorelease];
       //_typeTagString = [[tagsAndArguments componentsSeparatedByString:@"\0"] objectAtIndex:0];
    int pointer = 
        ([self.typeTagString length]+1) + (4 - ( ([self.typeTagString length]+1) % 4 ) - 1);
    
    for (index = 0; index < [self.typeTagString length]; index++) {
        switch ([self.typeTagString characterAtIndex:index]) {
			case 'f':
                //argumentChar = (char *)[tagsAndArguments subdataWithRange:NSMakeRange(pointer,4)];
				//argumentFloat32 = (float *)argumentChar;
				[tagsAndArguments getBytes:&float32Bits range:NSMakeRange(pointer, 4)];
				argumentFloat32 = NSSwapBigFloatToHost(float32Bits);
                [self.arguments addObject:[NSNumber numberWithFloat:argumentFloat32]];
                pointer += 4;
				break;
			case 'i':
				[tagsAndArguments getBytes:&argumentInt32 range:NSMakeRange(pointer, 4)];
                //argumentInt32 = (int *)[tagsAndArguments subdataWithRange:NSMakeRange(pointer,4)];
//				argumentInt32 = EndianS32_BtoN(argumentInt32);
                argumentInt32 = CFSwapInt32BigToHost(argumentInt32);
                [self.arguments addObject:[NSNumber numberWithInt:argumentInt32]];
                pointer += 4;
				break;
			case 's':
				nullOffset = [self byteOffSet:'\0' inData:[tagsAndArguments subdataWithRange:NSMakeRange(pointer,[tagsAndArguments length] - pointer)]];
                argumentString = 
				[[[NSString alloc] initWithData:[tagsAndArguments subdataWithRange:NSMakeRange(pointer,nullOffset)]
									  encoding:NSUTF8StringEncoding] autorelease];
				if (argumentString == nil) {
					printf("found null");
				}
				//argumentString = [[argumentString componentsSeparatedByString:@"\0"] objectAtIndex:0];
               // [[[tagsAndArguments substringFromIndex:pointer]
                [self.arguments addObject:argumentString];
                pointer += [argumentString length] + 4 - ([argumentString length]%4);
                break;

            // From here, types not implemented yet...
			case 'b':
                //arguments = [arguments stringByAppendingString:@", <OSC-blob>"];
                //pointer += 4;
				break;
            case 'h':
                //arguments = [arguments stringByAppendingString:@", <64 bit big-endian two's complement integer>"];
                //pointer += 4;
                break;
            case 't':
                //arguments = [arguments stringByAppendingString:@", <OSC-timetag>"];
                //pointer += 4;
                break;
            case 'd':
                //arguments = [arguments stringByAppendingString:@", <64 bit IEEE 754 floating point>"];
                //pointer += 4;
                break;
            case 'S':
                //arguments = [arguments stringByAppendingString:@", <Alternate type represented as an OSC-string>"];
                //pointer += 4;
                break;
            case 'c':
                //arguments = [arguments stringByAppendingString:@", <32 bit ASCII character>"];
                //pointer += 4;
                break;
            case 'r':
                //arguments = [arguments stringByAppendingString:@", <32 bit RGBA color>"];
                //pointer += 4;
                break;
            case 'm':
                //arguments = [arguments stringByAppendingString:@", <4 byte MIDI message>"];
                //pointer += 4;
                break;
            case 'T':
                //arguments = [arguments stringByAppendingString:@", <True>"];
                //pointer += 4;
                break;
            case 'F':
                //arguments = [arguments stringByAppendingString:@", <False>"];
                //pointer += 4;
                break;
            case 'N':
                //arguments = [arguments stringByAppendingString:@", <Nil>"];
                //pointer += 4;
                break;
            case 'I':
                //arguments = [arguments stringByAppendingString:@", <Infinitum>"];
                //pointer += 4;
                break;
            case '[':
                //arguments = [arguments stringByAppendingString:@", ["];
                //pointer += 4;
                break;
            case ']':
                //arguments = [arguments stringByAppendingString:@", ]"];
                //pointer += 4;
                break;
		}
    }
}    

- (int)byteOffSet:(char) toFind inData:(NSData*) data {
	int counter = 0, length = [data length];
	const char * dataBytes = [data bytes];
	
	while(counter <= length) {
		if (dataBytes[counter]  == toFind) {
			return counter;
		} else {
			counter++;
		}
	}
	return -1;
}


//- (BOOL)hasTypeTag {
//    return _hasTypeTag;
//}
//
//- (NSString *)addressString {
//    return _addressString;
//}
//
//- (NSArray *)addressPattern {
//    return _addressPattern;
//}
//
//- (NSString *)typeTagString {
//    return _typeTagString;
//}
//
//- (NSMutableArray *)arguments {
//    return _arguments;
//}

- (int)numberOfAddressPatterns {
    return [self.addressPattern count];
}

- (NSString *)addressPatternAtIndex:(int)index {
    return [self.addressPattern objectAtIndex:index];
}

- (char)typeTagAtIndex:(int)index {
    return [self.typeTagString characterAtIndex:index];
}

- (int)numberOfArguments {
    return [self.arguments count];
}

- (id)argumentAtIndex:(int)index {
    return [self.arguments objectAtIndex:index];
}

@end
