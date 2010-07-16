//
//  TWOAFormRequest.m
//  TWOAuthKit
//
//  Created by Sam Soffes on 4/7/10.
//  Copyright 2010 Tasteful Works. All rights reserved.
//

#import "TWOAFormRequest.h"
#import "TWOAuthKitConfiguration.h"
#import "OAuth.h"
#import "OAToken.h"

@implementation TWOAFormRequest

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
	[self setPostValue:token.key forKey:@"oauth_token"];
	[self setPostValue:token.secret forKey:@"oauth_token_secret"];
}


- (void)buildRequestHeaders {
	[super buildRequestHeaders];
		
	// Initialize OAuth with consumer credentials
	OAuth *oAuth = [[OAuth alloc] initWithConsumerKey:[TWOAuthKitConfiguration consumerKey] andConsumerSecret:[TWOAuthKitConfiguration consumerSecret]];
	
	// Set token
	if (token) {
		oAuth.oauth_token = [token URLEncodedValue];
	}
	
	// Convert params
	NSMutableDictionary *convertedParams = [[NSMutableDictionary alloc] init];
	for (NSDictionary *value in postData) {
        [convertedParams setObject:[value objectForKey:@"value"] forKey:[value objectForKey:@"key"]];
	}
	
	// Add header
	NSString *requestHeader = [oAuth oAuthHeaderForMethod:self.requestMethod andUrl:[self.url absoluteString] andParams:convertedParams];
	[convertedParams release];
	[self addRequestHeader:@"Authorization" value:requestHeader];
	[oAuth release];
}

@end
