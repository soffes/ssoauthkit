//
//  SSOAConsumer.m
//  SSOAuthKit
//
//  Created by Sam Soffes on 7/16/10.
//  Copyright 2010-2011 Sam Soffes. All rights reserved.
//

#import "SSOAConsumer.h"

@implementation SSOAConsumer

@synthesize key = _key;
@synthesize secret = _secret;

#pragma mark -
#pragma mark NSObject

- (void)dealloc {
	self.key = nil;
	self.secret = nil;
	[super dealloc];
}


#pragma mark -
#pragma mark Initializers

- (id)initWithKey:(NSString *)aKey secret:(NSString *)aSecret {
	if (aKey == nil || aSecret == nil) {
		return nil;
	}
	
	if ((self = [super init])) {
		self.key = aKey;
		self.secret = aSecret;
	}
	return self;
}


- (id)initWithHTTPResponseBody:(NSString *)body {
	NSString *aKey = nil;
	NSString *aSecret = nil;
	
	NSArray *pairs = [body componentsSeparatedByString:@"&"];
	
	for (NSString *pair in pairs) {
		NSArray *elements = [pair componentsSeparatedByString:@"="];
		if ([[elements objectAtIndex:0] isEqualToString:@"oauth_token"]) {
			aKey = [elements objectAtIndex:1];
		} else if ([[elements objectAtIndex:0] isEqualToString:@"oauth_token_secret"]) {
			aSecret = [elements objectAtIndex:1];
		}
	}
	
	self = [self initWithKey:aKey secret:aSecret];
	return self;
}


#pragma mark -
#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
	if ((self = [super init])) {
		self.key = [decoder decodeObjectForKey:@"key"];
		self.secret = [decoder decodeObjectForKey:@"secret"];
	}
	return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.key forKey:@"key"];
	[encoder encodeObject:self.secret forKey:@"secret"];
}


#pragma mark -
#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
	return [[[self class] alloc] initWithKey:self.key secret:self.secret];
}

@end
