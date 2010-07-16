//
//  TWOAuthKitConfiguration.m
//  TWOAuthKit
//
//  Created by Sam Soffes on 7/16/10.
//  Copyright 2010 Tasteful Works, Inc. All rights reserved.
//

#import "TWOAuthKitConfiguration.h"
#import "OAConsumer.h"

static NSString *consumerKey = nil;
static NSString *consumerSecret = nil;

@implementation TWOAuthKitConfiguration

+ (OAConsumer *)consumer {
	return [[[OAConsumer alloc] initWithKey:[self consumerKey] secret:[self consumerSecret]] autorelease];
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
