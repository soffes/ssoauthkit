//
//  SSOAuthKitConfiguration.m
//  SSOAuthKit
//
//  Created by Sam Soffes on 7/16/10.
//  Copyright 2010 Sam Soffes, Inc. All rights reserved.
//

#import "SSOAuthKitConfiguration.h"
#import "SSOAConsumer.h"

static NSString *consumerKey = nil;
static NSString *consumerSecret = nil;

@implementation SSOAuthKitConfiguration

+ (SSOAConsumer *)consumer {
	return [[[SSOAConsumer alloc] initWithKey:[self consumerKey] secret:[self consumerSecret]] autorelease];
}


+ (void)setConsumerKey:(NSString *)key secret:(NSString *)secret {
	[self setConsumerKey:key];
	[self setConsumerSecret:secret];
}


+ (void)setConsumerKey:(NSString *)key {
	[consumerKey release];
	consumerKey = [key retain];
}


+ (NSString *)consumerKey {
	return consumerKey;
}


+ (void)setConsumerSecret:(NSString *)key {
	[consumerSecret release];
	consumerSecret = [key retain];
}


+ (NSString *)consumerSecret {
	return consumerSecret;
}

@end
