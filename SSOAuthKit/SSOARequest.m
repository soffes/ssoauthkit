//
//  SSOARequest.m
//  SSOAuthKit
//
//  Created by Sam Soffes on 1/25/10.
//  Copyright 2010-2011 Sam Soffes. All rights reserved.
//

#import "SSOARequest.h"
#import "SSOAToken.h"
#import "SSOAuthKitConfiguration.h"
#import "OAHMAC_SHA1SignatureProvider.h"
#import "NSURL+OAuthString.h"
#import <SSToolkit/NSString+SSToolkitAdditions.h>

@implementation SSOARequest

@synthesize token = _token;

#pragma mark -
#pragma mark NSObject

- (void)dealloc {
	self.token = nil;
	[super dealloc];
}



#pragma mark -
#pragma mark ASIHTTPRequest

- (id)initWithURL:(NSURL *)newURL {
	if ((self = [super initWithURL:newURL])) {
		self.useCookiePersistence = NO;
	}
	return self;
}


- (NSString *)encodeURL:(NSString *)string {
	NSString *newString = [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)) autorelease];
	if (newString) {
		return newString;
	}
	return @"";
}


- (void)buildRequestHeaders {
	[super buildRequestHeaders];
	
	if ([SSOAuthKitConfiguration consumerKey] == nil || [SSOAuthKitConfiguration consumerSecret] == nil) {
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
									  [NSDictionary dictionaryWithObjectsAndKeys:[SSOAuthKitConfiguration consumerKey], @"value", @"oauth_consumer_key", @"key", nil],
									  [NSDictionary dictionaryWithObjectsAndKeys:[signatureProvider name], @"value", @"oauth_signature_method", @"key", nil],
									  [NSDictionary dictionaryWithObjectsAndKeys:timestamp, @"value", @"oauth_timestamp", @"key", nil],
									  [NSDictionary dictionaryWithObjectsAndKeys:nonce, @"value", @"oauth_nonce", @"key", nil],
									  [NSDictionary dictionaryWithObjectsAndKeys:@"1.0", @"value", @"oauth_version", @"key", nil],
									  nil];
	
	if ([_token.key isEqualToString:@""] == NO) {
		[parameterPairs addObject:[NSDictionary dictionaryWithObject:_token.key forKey:@"oauth_token"]];
	}
	
	// Sort and concatenate
	NSMutableString *normalizedRequestParameters = [[NSMutableString alloc] init];
	NSArray *sortedPairs = [parameterPairs sortedArrayUsingSelector:@selector(compare:)];
	
	NSUInteger i = 0;
	NSUInteger count = [parameterPairs count] - 1;
	for (NSDictionary *pair in sortedPairs) {
        NSString *parameterString = [NSString stringWithFormat:@"%@=%@%@", [self encodeURL:[pair objectForKey:@"key"]], [self encodeURL:[pair objectForKey:@"value"]], (i < count ?  @"&" : @"")];
		[normalizedRequestParameters appendString:parameterString];
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
						   [NSString stringWithFormat:@"%@&%@", [[SSOAuthKitConfiguration consumerSecret] URLEncodedString], 
							[_token.secret URLEncodedString]]];
	
	// Set OAuth headers
	NSString *oauthToken = @"";
	if ([_token.key isEqualToString:@""] == NO) {
		oauthToken = [NSString stringWithFormat:@"oauth_token=\"%@\", ", [_token.key URLEncodedString]];
	}
	
	NSString *oauthHeader = [NSString stringWithFormat:@"OAuth oauth_consumer_key=\"%@\", %@oauth_signature_method=\"%@\", oauth_signature=\"%@\", oauth_timestamp=\"%@\", oauth_nonce=\"%@\", oauth_version=\"1.0\"",
							 [[SSOAuthKitConfiguration consumerKey] URLEncodedString],
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
