//
//  SSOAuthKitConfiguration.m
//  SSOAuthKit
//
//  Created by Sam Soffes on 7/16/10.
//  Copyright 2010-2011 Sam Soffes. All rights reserved.
//

#import "SSOAuthKitConfiguration.h"
#import "SSOAConsumer.h"

static NSString *SSOAuthKitConfigurationConsumerKey = nil;
static NSString *SSOAuthKitConfigurationConsumerSecret = nil;

@implementation SSOAuthKitConfiguration

+ (SSOAConsumer *)consumer {
	return [[[SSOAConsumer alloc] initWithKey:[self consumerKey] secret:[self consumerSecret]] autorelease];
}


+ (void)setConsumerKey:(NSString *)key secret:(NSString *)secret {
	[self setConsumerKey:key];
	[self setConsumerSecret:secret];
}


+ (void)setConsumerKey:(NSString *)key {
	if (key == SSOAuthKitConfigurationConsumerKey) {
		return;
	}
	[SSOAuthKitConfigurationConsumerKey release];
	SSOAuthKitConfigurationConsumerKey = [key retain];
}


+ (NSString *)consumerKey {
	return SSOAuthKitConfigurationConsumerKey;
}


+ (void)setConsumerSecret:(NSString *)secret {
	if (secret == SSOAuthKitConfigurationConsumerSecret) {
		return;
	}
	[SSOAuthKitConfigurationConsumerSecret release];
	SSOAuthKitConfigurationConsumerSecret = [secret retain];
}


+ (NSString *)consumerSecret {
	return SSOAuthKitConfigurationConsumerSecret;
}

@end
