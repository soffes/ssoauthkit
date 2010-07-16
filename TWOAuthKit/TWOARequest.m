//
//  TWOARequest.m
//  TWOAuthKit
//
//  Created by Sam Soffes on 1/25/10.
//  Copyright 2010 Tasteful Works. All rights reserved.
//

#import "TWOARequest.h"
#import "OAuth.h"
#import "TWOAToken.h"
#import "TWOAuthKitConfiguration.h"

@implementation TWOARequest

@synthesize token;

- (void)dealloc {
	self.token = nil;
	[super dealloc];
}


- (id)initWithURL:(NSURL *)newURL {
	if ((self = [super initWithURL:newURL])) {
		self.useCookiePersistence = NO;
	}
	return self;
}


- (void)setToken:(TWOAToken *)aToken {
	if (aToken == token) {
		return;
	}
	
	[token release];
	token = [aToken retain];
}


- (void)buildRequestHeaders {
	[super buildRequestHeaders];
	
	if ([TWOAuthKitConfiguration consumerKey] == nil || [TWOAuthKitConfiguration consumerSecret] == nil) {
		return;
	}
	
	// Initialize OAuth with consumer credentials
	OAuth *oAuth = [[OAuth alloc] initWithConsumerKey:[TWOAuthKitConfiguration consumerKey] andConsumerSecret:[TWOAuthKitConfiguration consumerSecret]];
	
	// Set token
	if (token) {
		oAuth.oauth_token = [token URLEncodedValue];
	}
	
	// Add header
	NSString *requestHeader = [oAuth oAuthHeaderForMethod:self.requestMethod andUrl:[self.url absoluteString] andParams:nil];
	[self addRequestHeader:@"Authorization" value:requestHeader];
	[oAuth release];
}

@end
