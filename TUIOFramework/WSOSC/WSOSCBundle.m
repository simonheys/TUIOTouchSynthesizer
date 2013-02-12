//
//  WSOSCBundle.m
//  WSOSC
//
//  Created by Woon Seung Yeo on Fri Mar 05 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "WSOSCBundle.h"

#define TIMETAG_POINTER 8
#define TIMETAG_LENGTH 8
#define BUNDLESIZE_LENGTH 4

@interface WSOSCBundle ()
@property (nonatomic) int numberOfBundles;
@property (nonatomic, retain) NSNumber *bundleTimeTag;
@property (nonatomic, retain) NSMutableArray *bundles;
@end

//int _numberOfBundles; 
//NSNumber *_bundleTimeTag;
//NSMutableArray *_bundles;

@implementation WSOSCBundle

- (void)dealloc {
    [_bundleTimeTag release];
    [_bundles release];
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeInt:self.numberOfBundles forKey:@"OSCNumberOfBundles"];
	[coder encodeObject:self.bundleTimeTag forKey:@"OSCBundleTimeTag"];
	[coder encodeObject:self.bundles forKey:@"OSCBundles"];
}

- (id)initWithCoder:(NSCoder *)coder {
	if (self = [super init]) {
        self.numberOfBundles = [coder decodeIntForKey:@"OSCNumberOfBundles"];
        self.bundleTimeTag = [coder decodeObjectForKey:@"OSCBundleTimeTag"];
        self.bundles  = [coder decodeObjectForKey:@"OSCBundles"];
    }
    return self;
}



- (id)init {
    if (self = [super init]) {
        self.numberOfBundles = 0;
        self.bundleTimeTag = [[[NSNumber alloc] init] autorelease];
        self.bundles = [[[NSMutableArray alloc] init] autorelease];
    }
	return self;
}

- (id)initWithDataFrom:(NSData *)data {
    if (self = [super init]) {
        self.numberOfBundles = 0;
        self.bundleTimeTag = [[[NSNumber alloc] init] autorelease];
        self.bundles = [[[NSMutableArray alloc] init] autorelease];
        [self parseFrom:data];
    }
	return self;
}

+ (id)bundleParsedFrom:(NSData *)data {
    return [[[self alloc] initWithDataFrom:data] autorelease];
}

- (void)parseFrom:(NSData *)data {    
    // Divide data into timetag and bundle(s)
    //const char *timeTagString = 
    //    [[data substringWithRange:NSMakeRange(TIMETAG_POINTER, TIMETAG_LENGTH)] cString];

    // Parse timetag: to be implemented.
    //NSLog(@"Timetag string hahaha: %s", timeTagString);    
    
    // Parse bundles
	int32_t bundleSize;
    int pointer = TIMETAG_POINTER + TIMETAG_LENGTH;
    
    self.numberOfBundles = 0;
    
    while (pointer < [data length]) {
        [data getBytes:&bundleSize range:NSMakeRange(pointer, BUNDLESIZE_LENGTH)];
		//bundleSize = (int32_t) [[data subdataWithRange:NSMakeRange(pointer, BUNDLESIZE_LENGTH)] bytes];
//		bundleSize = EndianS32_BtoN(bundleSize);
        bundleSize = CFSwapInt32BigToHost(bundleSize);
        pointer += BUNDLESIZE_LENGTH;

        WSOSCMessage *message = [[[WSOSCMessage alloc] init] autorelease];
        [message parseFrom:[data subdataWithRange:NSMakeRange(pointer, bundleSize)]];
        [self.bundles addObject:message];
//        [message release];
		//My endian is little!
        self.numberOfBundles ++;
        pointer += bundleSize;
    }
}    

//- (int)numberOfBundles {
//    return _numberOfBundles;
//}
//
//- (NSNumber *)bundleTimeTag {
//    return _bundleTimeTag;
//}
//
//- (NSMutableArray *)bundles {
//    return _bundles;
//}

- (WSOSCMessage *)bundleAtIndex:(int)index {
    return [_bundles objectAtIndex:index];
}


@end
