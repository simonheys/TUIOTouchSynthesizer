//
//  WSOSCMessage.h
//  WSOSC
//
//  Created by Woon Seung Yeo on Fri Mar 05 2004.
//  Copyright (c) 2004 CCRMA, Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WSOSCMessage : NSObject {
}
@property (nonatomic, readonly) BOOL hasTypeTag;
@property (nonatomic, retain, readonly) NSString *addressString;
@property (nonatomic, retain, readonly) NSArray *addressPattern;
@property (nonatomic, retain, readonly) NSString *typeTagString;
@property (nonatomic, retain, readonly) NSMutableArray *arguments;

- (id)initWithDataFrom:(NSData *)data;
+ (id)messageParsedFrom:(NSData *)data;

- (void)parseFrom:(NSData *)data;

//- (BOOL)hasTypeTag;
//
//- (NSString *)addressString;
//- (NSArray *)addressPattern;
//- (NSString *)typeTagString;
//- (NSMutableArray *)arguments;

- (int)numberOfAddressPatterns;
- (NSString *)addressPatternAtIndex:(int)index;
- (int)byteOffSet:(char) toFind inData:(NSData*) data;


- (char)typeTagAtIndex:(int)index;

- (int)numberOfArguments;
- (id)argumentAtIndex:(int)index;

@end
