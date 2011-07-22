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
#import "SSTwitterAuthViewControllerDelegate.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import <SSToolkit/SSLoadingView.h>
#import <SSToolkit/UIImage+SSToolkitAdditions.h>
#import <SSToolkit/UIView+SSToolkitAdditions.h>
#import <SSToolkit/NSDictionary+SSToolkitAdditions.h>

@interface SSTwitterOAuthViewController (Private)
- (void)_requestRequestToken;
- (void)_requestAccessToken;
- (void)_verifyAccessToken:(NSString *)verifier;
@end

@implementation SSTwitterOAuthViewController

#pragma mark -
#pragma mark NSObject

- (void)dealloc {
	[_authorizationView release];
	[_requestToken release];
	[super dealloc];
}


#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Background image
	UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 100.0f)];
	backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
	backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"images/twitter_oauth_background.png" bundle:@"SSOAuthKit.bundle"]];
	backgroundView.opaque = YES;
	[self.view addSubview:backgroundView];
	[backgroundView release];
	self.view.backgroundColor = [UIColor colorWithRed:0.753f green:0.875f blue:0.925f alpha:1.0f];
	
	// Loading
	self.loadingView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
	[self.view addSubview:self.loadingView];
	
	// Web view
	_authorizationView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
	_authorizationView.dataDetectorTypes = UIDataDetectorTypeNone;
	_authorizationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_authorizationView.delegate = self;
	_authorizationView.alpha = 0.0f;
	
	[self _requestRequestToken];
}


#pragma mark -
#pragma mark Private Methods

// *** Step 1
- (void)_requestRequestToken {
	[self cancelRequest];
	
	// Update loading text
	self.loadingView.text = @"Requesting token...";
	
	// Perform request for request token
	NSURL *url = [[NSURL alloc] initWithString:@"https://api.twitter.com/oauth/request_token"];
	SSOAFormRequest *aRequest = [[SSOAFormRequest alloc] initWithURL:url];
	aRequest.delegate = self;
	self.request = aRequest;
	[aRequest release];
	[url release];
	
	[self.request startAsynchronous];
}


// *** Step 2
- (void)_requestAccessToken {	
	self.loadingView.text = @"Authorizing...";
	
	NSString *urlString = [[NSString alloc] initWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@&oauth_callback=oob", _requestToken.key];
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	NSURLRequest *aRequest = [[NSURLRequest alloc] initWithURL:url];
	[url release];
	[urlString release];
	
	// Setup webView
	CGRect frame = self.view.frame;
	_authorizationView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
	_authorizationView.dataDetectorTypes = UIDataDetectorTypeNone;
	_authorizationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_authorizationView.delegate = self;
	_authorizationView.alpha = 0.0f;
	[_authorizationView loadRequest:aRequest];
	[self.view addSubview:_authorizationView];
	
	[aRequest release];
}


// *** Step 3
- (void)_verifyAccessToken:(NSString *)verifier {
	_verifying = YES;
	self.loadingView.text = @"Verifying...";
	
	[_authorizationView fadeOut];
	[_authorizationView release];
	_authorizationView = nil;
	
	[self cancelRequest];
	
	NSURL *url = [[NSURL alloc] initWithString:@"https://api.twitter.com/oauth/access_token"];
	
	SSOAFormRequest *aRequest = [[SSOAFormRequest alloc] initWithURL:url];
	aRequest.token = _requestToken;
	aRequest.delegate = self;
	[aRequest addPostValue:verifier forKey:@"oauth_verifier"];
	self.request = aRequest;
	[aRequest release];
	[url release];
	
	[self.request startAsynchronous];
}


#pragma mark -
#pragma mark ASIHTTPRequestDelegate

- (void)requestFinished:(ASIHTTPRequest *)aRequest {
	[super requestFinished:aRequest];
	
	NSString *path = [[aRequest url] path];
	
	// *** Step 1 - Request token
	if ([path isEqualToString:@"/oauth/request_token"]) {
		// Create request token
		NSString *httpBody = [aRequest responseString];
		
		// Check for token error
		if ([httpBody isEqualToString:@"Failed to validate oauth signature and token"]) {
			[self failWithErrorString:httpBody code:-1];
			return;
		}
		
		// Get token
		SSOAToken *aToken = [[SSOAToken alloc] initWithHTTPResponseBody:httpBody];
		
		// Check for token error
		if (!aToken.key || !aToken.secret) {
			[aToken release];
			[self failWithErrorString:@"The request token could not be generated" code:-1];
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
			[self failWithErrorString:@"The access token could not be generated" code:-1];
			return;
		}
		
		self.accessToken = aToken;
		[aToken release];
		
		// Get user dictionary
		[self requestUser];
		return;
	}
	
	// *** Step 2 - Get user (super class handles this)
}


#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[self failWithError:error];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)aRequest navigationType:(UIWebViewNavigationType)navigationType {
	if (self.accessToken) {
		return NO;
	}
	
	NSURL *url = [aRequest URL];
	NSLog(@"url: %@", url);
	
	// Allow the user to change users
	if ([[url host] isEqualToString:@"api.twitter.com"] && [[url path] isEqualToString:@"/logout"]) {
		return YES;
	}
	
	NSString *body = [[NSString alloc] initWithData:[aRequest HTTPBody] encoding:NSUTF8StringEncoding];
	NSDictionary *params = [NSDictionary dictionaryWithFormEncodedString:body];
	[body release];
	
	// TODO: allow signup too
	if ([[url host] isEqualToString:@"api.twitter.com"] && [[url path] isEqualToString:@"/oauth/authorize"]) {
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
	NSString *pin = [_authorizationView stringByEvaluatingJavaScriptFromString:@"document.querySelectorAll.apply(document, ['div#oauth_pin code'])[0].innerHTML"];
	if ([pin length] == 7) {
		[self _verifyAccessToken:pin];
		return;
	}
	
	// Fade in
	if (!self.accessToken && _verifying == NO) {
		[_authorizationView fadeIn];
	}
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

@end
