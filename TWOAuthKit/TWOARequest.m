//
//  TWOARequest.m
//  TWOAuthKit
//
//  Created by Sam Soffes on 1/25/10.
//  Copyright 2010 Tasteful Works. All rights reserved.
//

#import "TWOARequest.h"
#import "OAuth.h"
#import "OAToken.h"
#import "TWOAuthKitConfiguration.h"

@implementation TWOARequest

@synthesize token;

- (void)dealloc {
	self.token = nil;
	[super dealloc];
}


- (void)setToken:(OAToken *)aToken {
	if (aToken == token) {
		return;
	}
	
	[token release];
	token = [aToken retain];
}


- (void)buildRequestHeaders {
	[super buildRequestHeaders];
	
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
