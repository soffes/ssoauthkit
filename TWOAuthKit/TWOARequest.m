//
//  TWOARequest.m
//  TWOAuthKit
//
//  Created by Sam Soffes on 1/25/10.
//  Copyright 2010 Tasteful Works. All rights reserved.
//

#import "TWOARequest.h"
#import "TWOAToken.h"
#import "TWOAuthKitConfiguration.h"
#import "OAHMAC_SHA1SignatureProvider.h"
#import "NSURL+OAuthString.h"
#import <TWToolkit/NSString+TWToolkitAdditions.h>

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


- (NSString *)encodeURL:(NSString *)string {
	NSString *newString = NSMakeCollectable([(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)) autorelease]);
	if (newString) {
		return newString;
	}
	return @"";
}


- (void)buildRequestHeaders {
	[super buildRequestHeaders];
	
	if ([TWOAuthKitConfiguration consumerKey] == nil || [TWOAuthKitConfiguration consumerSecret] == nil) {
		return;
	}
	
	// Signature provider
	id<OASignatureProviding> signatureProvider = [[OAHMAC_SHA1SignatureProvider alloc] init];
	
	// Timestamp
	NSString *timestamp = [NSString stringWithFormat:@"%d", time(NULL)];
	
	// Nonce
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	NSString *nonce = [(NSString *)string autorelease];
	
	// OAuth Spec, Section 9.1.1 "Normalize Request Parameters"
	// Build a sorted array of both request parameters and OAuth header parameters
	NSMutableArray *parameterPairs = [[NSMutableArray alloc] initWithObjects:
									  [NSDictionary dictionaryWithObjectsAndKeys:[TWOAuthKitConfiguration consumerKey], @"value", @"oauth_consumer_key", @"key", nil],
									  [NSDictionary dictionaryWithObjectsAndKeys:[signatureProvider name], @"value", @"oauth_signature_method", @"key", nil],
									  [NSDictionary dictionaryWithObjectsAndKeys:timestamp, @"value", @"oauth_timestamp", @"key", nil],
									  [NSDictionary dictionaryWithObjectsAndKeys:nonce, @"value", @"oauth_nonce", @"key", nil],
									  [NSDictionary dictionaryWithObjectsAndKeys:@"1.0", @"value", @"oauth_version", @"key", nil],
									  nil];
	
	if ([token.key isEqualToString:@""] == NO) {
		[parameterPairs addObject:[NSDictionary dictionaryWithObject:token.key forKey:@"oauth_token"]];
	}
	
	// Sort and concatenate
	NSMutableString *normalizedRequestParameters = [[NSMutableString alloc] init];
	NSArray *sortedPairs = [parameterPairs sortedArrayUsingSelector:@selector(compare:)];
	
	NSUInteger i = 0;
	NSUInteger count = [parameterPairs count] - 1;
	for (NSDictionary *pair in sortedPairs) {
        NSString *string = [NSString stringWithFormat:@"%@=%@%@", [self encodeURL:[pair objectForKey:@"key"]], [self encodeURL:[pair objectForKey:@"value"]], (i < count ?  @"&" : @"")]; 
		[normalizedRequestParameters appendString:string];
		i++;
	}
	[parameterPairs release];
	
	// OAuth Spec, Section 9.1.2 "Concatenate Request Elements"
	NSString *signatureBaseString = [NSString stringWithFormat:@"%@&%@&%@", self.requestMethod,
									 [[self.url OAuthString] URLEncodedString],
									 [normalizedRequestParameters URLEncodedString]];
	[normalizedRequestParameters release];
	
	// Sign
	// Secrets must be urlencoded before concatenated with '&'
	NSString *signature = [signatureProvider signClearText:signatureBaseString withSecret:
						   [NSString stringWithFormat:@"%@&%@", [[TWOAuthKitConfiguration consumerSecret] URLEncodedString], 
							[token.secret URLEncodedString]]];
	
	// Set OAuth headers
	NSString *oauthToken = @"";
	if ([token.key isEqualToString:@""] == NO) {
		oauthToken = [NSString stringWithFormat:@"oauth_token=\"%@\", ", [token.key URLEncodedString]];
	}
	
	NSString *oauthHeader = [NSString stringWithFormat:@"OAuth oauth_consumer_key=\"%@\", %@oauth_signature_method=\"%@\", oauth_signature=\"%@\", oauth_timestamp=\"%@\", oauth_nonce=\"%@\", oauth_version=\"1.0\"",
							 [[TWOAuthKitConfiguration consumerKey] URLEncodedString],
							 oauthToken,
							 [[signatureProvider name] URLEncodedString],
							 [signature URLEncodedString],
							 timestamp,
							 nonce];
	
	// Clean up
	[signatureProvider release];
	
	// Add the header
	[self addRequestHeader:@"Authorization" value:oauthHeader];
}

@end
