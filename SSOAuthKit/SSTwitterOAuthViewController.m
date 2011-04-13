//
//  SSTwitterOAuthViewController.m
//  SSOAuthKit
//
//  Created by Sam Soffes on 11/3/09.
//  Copyright 2009-2011 Sam Soffes. All rights reserved.
//

#import "SSTwitterOAuthViewController.h"
#import "SSOAuthKitConfiguration.h"
#import "SSOAToken.h"
#import "SSOAFormRequest.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import <SSToolkit/SSLoadingView.h>
#import <SSToolkit/SSCategories.h>

static NSString *kSSTwitterOAuthViewControllerErrorDomain = @"com.samsoffes.sstwitteroauthviewcontroller";

@interface SSTwitterOAuthViewController (Private)
- (void)_requestRequestToken;
- (void)_requestAccessToken;
- (void)_verifyAccessToken:(NSString *)verifier;
- (void)_requestUser;
- (void)_failWithError:(NSError *)error;
- (void)_failWithErrorString:(NSString *)message code:(NSInteger)code;
@end

@implementation SSTwitterOAuthViewController

@synthesize delegate = _delegate;

#pragma mark NSObject

- (id)init {
	if ((self = [super init])) {
		self.modalPresentationStyle = UIModalPresentationFormSheet;
	}
	return self;
}


- (void)dealloc {
	_delegate = nil;
	
	_request.delegate = nil;
	[_request cancel];
	[_request release];
	
	[_loadingView release];
	[_authorizationView release];
	[_requestToken release];
	[_accessToken release];
	[super dealloc];
}


#pragma mark UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Authorize";
	
	// Background image
	UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 100.0)];
	backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
	backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"images/twitter_oauth_background.png" bundle:@"SSOAuthKit.bundle"]];
	backgroundView.opaque = YES;
	[self.view addSubview:backgroundView];
	[backgroundView release];
	self.view.backgroundColor = [UIColor colorWithRed:0.753 green:0.875 blue:0.925 alpha:1.0];
	
	// Loading
	_loadingView = [[SSLoadingView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
	_loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_loadingView.backgroundColor = [UIColor clearColor];
	_loadingView.opaque = NO;
	[self.view addSubview:_loadingView];
	
	// Web view
	_authorizationView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
	_authorizationView.dataDetectorTypes = UIDataDetectorTypeNone;
	_authorizationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_authorizationView.delegate = self;
	_authorizationView.alpha = 0.0;
	
	[self _requestRequestToken];
}


#pragma mark Initalizer

- (id)initWithDelegate:(id<SSTwitterOAuthViewControllerDelegate>)aDelegate {
	if ((self = [self init])) {
		self.delegate = aDelegate;
	}
	return self;
}


#pragma mark Actions

- (void)cancel:(id)sender {
	if ([_delegate respondsToSelector:@selector(twitterOAuthViewControllerDidCancel:)]) {
		[_delegate twitterOAuthViewControllerDidCancel:self];
	}
}


#pragma mark Private Methods

// *** Step 1
- (void)_requestRequestToken {
	
	[_request release];
	
	// Update loading text
	_loadingView.text = @"Requesting token...";
	
	// Perform request for request token
	NSURL *url = [[NSURL alloc] initWithString:@"https://api.twitter.com/oauth/request_token"];
	_request = [[SSOAFormRequest alloc] initWithURL:url];
	[url release];
	_request.delegate = self;
	[_request startAsynchronous];
}


// *** Step 2
- (void)_requestAccessToken {	
	_loadingView.text = @"Authorizing...";
	
	NSString *urlString = [[NSString alloc] initWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@&oauth_callback=oob", _requestToken.key];
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	NSURLRequest *aRequest = [[NSURLRequest alloc] initWithURL:url];
	[url release];
	[urlString release];
	
	// Setup webView
	CGRect frame = self.view.frame;
	_authorizationView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
	_authorizationView.dataDetectorTypes = UIDataDetectorTypeNone;
	_authorizationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_authorizationView.delegate = self;
	_authorizationView.alpha = 0.0;
	[_authorizationView loadRequest:aRequest];
	[self.view addSubview:_authorizationView];
	
	[aRequest release];
}


// *** Step 3
- (void)_verifyAccessToken:(NSString *)verifier {
	_verifying = YES;
	_loadingView.text = @"Verifying...";
	
	[_authorizationView fadeOut];
	[_authorizationView release];
	_authorizationView = nil;
	
	_request.delegate = nil;
	[_request cancel];
	[_request release];
	
	NSURL *url = [[NSURL alloc] initWithString:@"https://api.twitter.com/oauth/access_token"];
	
	_request = [[SSOAFormRequest alloc] initWithURL:url];
	_request.token = _requestToken;
	_request.delegate = self;
	[_request addPostValue:verifier forKey:@"oauth_verifier"];
	[_request startAsynchronous];
	
	[url release];
}


// *** Step 4
- (void)_requestUser {
	_loadingView.text = @"Saving...";
	
	_request.delegate = nil;
	[_request cancel];
	[_request release];
	
	NSURL *url = [[NSURL alloc] initWithString:@"https://api.twitter.com/1/account/verify_credentials.json"];
	
	_request = [[SSOAFormRequest alloc] initWithURL:url];
	_request.requestMethod = @"GET";
	_request.token = _accessToken;
	_request.delegate = self;
	[_request startAsynchronous];
	
	[url release];
}


- (void)_failWithError:(NSError *)error {
	if ([_delegate respondsToSelector:@selector(twitterOAuthViewController:didFailWithError:)]) {
		[_delegate twitterOAuthViewController:self didFailWithError:error];
	}
}


- (void)_failWithErrorString:(NSString *)message code:(NSInteger)code {
	if ([_delegate respondsToSelector:@selector(twitterOAuthViewController:didFailWithError:)]) {
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:message, NSLocalizedDescriptionKey, nil];
		NSError *error = [NSError errorWithDomain:kSSTwitterOAuthViewControllerErrorDomain code:code userInfo:userInfo];
		[_delegate twitterOAuthViewController:self didFailWithError:error];
	}
}


#pragma mark TWURLConnectionDelegate

- (void)requestStarted:(ASIHTTPRequest *)aRequest {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}


- (void)requestFailed:(ASIHTTPRequest *)aRequest {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[self _failWithError:[aRequest error]];
}


- (void)requestFinished:(ASIHTTPRequest *)aRequest {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	if ([aRequest responseStatusCode] == 500) {
		[self _failWithErrorString:@"Something went technically wrong on Twitter's end. Maybe try again later." code:-2];
		return;
	}
	
	NSString *path = [[aRequest url] path];
	
	// *** Step 1 - Request token
	if ([path isEqualToString:@"/oauth/request_token"]) {
		
		NSString *httpBody = [aRequest responseString];
		
		// Check for token error
		if ([httpBody isEqualToString:@"Failed to validate oauth signature and token"]) {
			[self _failWithErrorString:httpBody code:-1];
			return;
		}
		
		// Get token
		SSOAToken *aToken = [[SSOAToken alloc] initWithHTTPResponseBody:httpBody];
		
		// Check for token error
		if (!aToken.key || !aToken.secret) {
			[aToken release];
			[self _failWithErrorString:@"The request token could not be generated" code:-1];
			return;
		}
		
		// Store token
		_requestToken = [aToken retain];
		[aToken release];
		
		// Start authorizing
		[self _requestAccessToken];
		return;
	}
	
	// *** Step 2 - Authorize (web view handles this)
	
	// *** Step 3 - Verify token
	else if ([path isEqualToString:@"/oauth/access_token"]) {
		
		// Get token
		SSOAToken *aToken = [[SSOAToken alloc] initWithHTTPResponseBody:[aRequest responseString]];
		
		// Check for token error
		if (aToken == nil) {
			[self _failWithErrorString:@"The access token could not be generated" code:-1];
			return;
		}
		
		_accessToken = [aToken retain];
		[aToken release];
		
		// Get user dictionary
		[self _requestUser];
		return;
	}
	
	// *** Step 4 - Get user
	else if ([path isEqualToString:@"/1/account/verify_credentials.json"]) {
		NSError *jsonError = nil;
		NSDictionary *dictionary = [[aRequest responseData] objectFromJSONDataWithParseOptions:0 error:&jsonError];
		if (!dictionary) {
			// TODO: Pass access token along since we successfully got it already
			NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
									  jsonError, NSUnderlyingErrorKey,
									  _accessToken, @"accessToken",
									  @"Failed to get Twitter profile.", NSLocalizedDescriptionKey,
									  nil];			
			NSError *error = [NSError errorWithDomain:kSSTwitterOAuthViewControllerErrorDomain code:-3 userInfo:userInfo];
			[userInfo release];
			[self _failWithError:error];
			return;
		}
		
		// Notify delegate
		if ([_delegate respondsToSelector:@selector(twitterOAuthViewController:didAuthorizeWithAccessToken:userDictionary:)]) {
			[_delegate twitterOAuthViewController:self didAuthorizeWithAccessToken:_accessToken userDictionary:dictionary];
		}
	}
}


#pragma mark UIWebViewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[self _failWithError:error];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)aRequest navigationType:(UIWebViewNavigationType)navigationType {
	if (_accessToken) {
		return NO;
	}
	
	NSURL *url = [aRequest URL];
	NSString *body = [[NSString alloc] initWithData:[aRequest HTTPBody] encoding:NSUTF8StringEncoding];
	NSDictionary *params = [NSDictionary dictionaryWithFormEncodedString:body];
	[body release];
	
	// TODO: allow signup too
	if ([[url host] isEqual:@"api.twitter.com"] && [[url path] isEqual:@"/oauth/authorize"]) {
		// Handle cancel
		if ([params objectForKey:@"cancel"]) {
			[self cancel:self];
			return NO;
		}
		
		[_authorizationView fadeOut];
		return YES;
	}
	
	// Check for completion redirect instead of pin
	NSString *currentURLString = [_authorizationView stringByEvaluatingJavaScriptFromString:@"location.href"];
	if ([currentURLString isEqualToString:@"https://api.twitter.com/oauth/authorize"]) {
		[self _verifyAccessToken:[params objectForKey:@"oauth_verifier"]];
	}
	
	return NO;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	// Check for pin
	NSString *pin = [_authorizationView stringByEvaluatingJavaScriptFromString:@"document.getElementById('oauth_pin').innerText"];
	if ([pin length] == 7) {
		[self _verifyAccessToken:pin];
		return;
	}
	
	// Fade in
	if (!_accessToken && _verifying == NO) {
		[_authorizationView fadeIn];
	}
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

@end
