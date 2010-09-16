//
//  SSTwitterOAuthInternalViewController.m
//  SSOAuthKit
//
//  Created by Sam Soffes on 11/9/09.
//  Copyright 2009 Sam Soffes, Inc. All rights reserved.
//

#import "SSTwitterOAuthInternalViewController.h"
#import "SSTwitterOAuthViewController.h"
#import "SSOAToken.h"
#import "SSOAFormRequest.h"
#import "ASIHTTPRequest.h"
#import "JSON.h"
#import <SSToolkit/SSLoadingView.h>
#import <SSToolkit/SSCategories.h>

@interface SSTwitterOAuthInternalViewController (Private)

- (SSTwitterOAuthViewController *)_parent;
- (void)_requestRequestToken;
- (void)_requestAccessToken;
- (void)_verifyAccessTokenWithPin:(NSString *)pin;
- (void)_requestUser;

@end


@implementation SSTwitterOAuthInternalViewController

#pragma mark NSObject

- (void)dealloc {
	request.delegate = nil;
	[request cancel];
	[request release];
	
	[loadingView release];
	[authorizationView release];
	[requestToken release];
	[accessToken release];
	[super dealloc];
}


#pragma mark -
#pragma mark UIViewController
#pragma mark -

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Authorize";
	
	// Background image
	UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 190.0)];
	backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
	backgroundImageView.image = [UIImage imageNamed:@"images/twitter_oauth_background.png" bundle:@"SSOAuthKit.bundle"];
	backgroundImageView.opaque = YES;
	backgroundImageView.contentMode = UIViewContentModeTopLeft;
	[self.view addSubview:backgroundImageView];
	[backgroundImageView release];
	self.view.backgroundColor = [UIColor colorWithRed:0.753 green:0.875 blue:0.925 alpha:1.0];
	
	// Navigation Bar
	self.navigationItem.hidesBackButton = NO;
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self.navigationController action:@selector(cancel:)];
	self.navigationItem.rightBarButtonItem = cancelButton;
	[cancelButton release];
	
	// Loading
	loadingView = [[SSLoadingView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
	loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	loadingView.backgroundColor = [UIColor clearColor];
	loadingView.opaque = NO;
	[self.view addSubview:loadingView];
	
	// Web view
	authorizationView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
	authorizationView.dataDetectorTypes = UIDataDetectorTypeNone;
	authorizationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	authorizationView.delegate = self;
	authorizationView.alpha = 0.0;
	
	[self _requestRequestToken];
}


#pragma mark -
#pragma mark Private Methods
#pragma mark -

- (SSTwitterOAuthViewController *)_parent {
	return (SSTwitterOAuthViewController *)self.navigationController;
}


// *** Step 1
- (void)_requestRequestToken {

	[request release];
	
	// Update loading text
	loadingView.text = @"Requesting token...";
	
	// Perform request for request token
	NSURL *url = [[NSURL alloc] initWithString:@"https://api.twitter.com/oauth/request_token"];
	request = [[SSOAFormRequest alloc] initWithURL:url];
	[url release];
	request.delegate = self;
	[request startAsynchronous];
}


// *** Step 2
- (void)_requestAccessToken {	
	loadingView.text = @"Authorizing...";
	
	NSString *urlString = [[NSString alloc] initWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@&oauth_callback=oob", requestToken.key];
	NSURL *url = [[NSURL alloc] initWithString:urlString];
	NSURLRequest *aRequest = [[NSURLRequest alloc] initWithURL:url];
	[url release];
	[urlString release];
	
	// Setup webView
	CGRect frame = self.view.frame;
	authorizationView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
	authorizationView.dataDetectorTypes = UIDataDetectorTypeNone;
	authorizationView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	authorizationView.delegate = self;
	authorizationView.alpha = 0.0;
	[authorizationView loadRequest:aRequest];
	[self.view addSubview:authorizationView];
	
	[aRequest release];
}


// *** Step 3
- (void)_verifyAccessTokenWithPin:(NSString *)pin {
	loadingView.text = @"Verifying...";
	
	[authorizationView fadeOut];
	[authorizationView release];
	authorizationView = nil;

	request.delegate = nil;
	[request cancel];
	[request release];
	
	NSURL *url = [[NSURL alloc] initWithString:@"https://api.twitter.com/oauth/access_token"];

	request = [[SSOAFormRequest alloc] initWithURL:url];
	request.token = requestToken;
	request.delegate = self;
	[request addPostValue:pin forKey:@"oauth_verifier"];
	[request startAsynchronous];
	
	[url release];
}


// *** Step 4
- (void)_requestUser {
	loadingView.text = @"Saving...";
	
	request.delegate = nil;
	[request cancel];
	[request release];
	
	NSURL *url = [[NSURL alloc] initWithString:@"https://api.twitter.com/1/account/verify_credentials.json"];
	
	request = [[SSOAFormRequest alloc] initWithURL:url];
	request.requestMethod = @"GET";
	request.token = accessToken;
	request.delegate = self;
	[request startAsynchronous];
	
	[url release];
}

#pragma mark -
#pragma mark TWURLConnectionDelegate
#pragma mark -

- (void)requestStarted:(ASIHTTPRequest *)aRequest {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}


- (void)requestFailed:(ASIHTTPRequest *)aRequest {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	if ([[[self _parent] delegate] respondsToSelector:@selector(twitterOAuthViewController:didFailWithError:)]) {
		[[[self _parent] delegate] twitterOAuthViewController:[self _parent] didFailWithError:[aRequest error]];
	}
}


- (void)requestFinished:(ASIHTTPRequest *)aRequest {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	if ([aRequest responseStatusCode] == 500) {
		if ([[[self _parent] delegate] respondsToSelector:@selector(twitterOAuthViewController:didFailWithError:)]) {
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Something went technically wrong on Twitter's end. Maybe try again later.", NSLocalizedDescriptionKey, nil];
			NSError *error = [NSError errorWithDomain:@"com.tasetfulworks.twtwitteroauthviewcontroller" code:-2 userInfo:userInfo];
			[[[self _parent] delegate] twitterOAuthViewController:[self _parent] didFailWithError:error];
		}
		return;
	}
	
	NSString *path = [[aRequest url] path];
	
	// *** Step 1 - Request token
	if ([path isEqualToString:@"/oauth/request_token"]) {
		
		NSString *httpBody = [aRequest responseString];
		
		// Check for token error
		if ([httpBody isEqualToString:@"Failed to validate oauth signature and token"]) {
			if ([[[self _parent] delegate] respondsToSelector:@selector(twitterOAuthViewController:didFailWithError:)]) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:httpBody, NSLocalizedDescriptionKey, nil];
				NSError *error = [NSError errorWithDomain:@"com.tasetfulworks.twtwitteroauthviewcontroller" code:-1 userInfo:userInfo];
				[[[self _parent] delegate] twitterOAuthViewController:[self _parent] didFailWithError:error];
			}
			return;
		}
		
		// Get token
		SSOAToken *aToken = [[SSOAToken alloc] initWithHTTPResponseBody:httpBody];
		
		// Check for token error
		if (!aToken.key || !aToken.secret) {
			[aToken release];
			if ([[[self _parent] delegate] respondsToSelector:@selector(twitterOAuthViewController:didFailWithError:)]) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"The request token could not be generated", NSLocalizedDescriptionKey, nil];
				NSError *error = [NSError errorWithDomain:@"com.tasetfulworks.twtwitteroauthviewcontroller" code:-1 userInfo:userInfo];
				[[[self _parent] delegate] twitterOAuthViewController:[self _parent] didFailWithError:error];
			}
			return;
		}
		
		// Store token
		requestToken = [aToken retain];
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
			if ([[[self _parent] delegate] respondsToSelector:@selector(twitterOAuthViewController:didFailWithError:)]) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"The access token could not be generated", NSLocalizedDescriptionKey, nil];
				NSError *error = [NSError errorWithDomain:@"com.tasetfulworks.twtwitteroauthviewcontroller" code:-1 userInfo:userInfo];
				[[[self _parent] delegate] twitterOAuthViewController:[self _parent] didFailWithError:error];
			}
			return;
		}
		
		accessToken = [aToken retain];
		[aToken release];
		
		// Get user dictionary
		[self _requestUser];
		return;
	}
	
	// *** Step 4 - Get user
	else if ([path isEqualToString:@"/1/account/verify_credentials.json"]) {
		NSDictionary *dictionary = [[aRequest responseString] JSONValue];
		if (!dictionary) {
			// TODO: Pass access token along since we successfully got it already
			if ([[[self _parent] delegate] respondsToSelector:@selector(twitterOAuthViewController:didFailWithError:)]) {
				// TODO: Provide JSON error
				[[[self _parent] delegate] twitterOAuthViewController:[self _parent] didFailWithError:nil];
			}
			return;
		}
		
		// Notify delegate
		if ([[[self _parent] delegate] respondsToSelector:@selector(twitterOAuthViewController:didAuthorizeWithAccessToken:userDictionary:)]) {
			[[[self _parent] delegate] twitterOAuthViewController:[self _parent] didAuthorizeWithAccessToken:accessToken userDictionary:dictionary];
		}
	}
}

#pragma mark -
#pragma mark UIWebViewDelegate
#pragma mark -

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	if ([[[self _parent] delegate] respondsToSelector:@selector(twitterOAuthViewController:didFailWithError:)]) {
		[[[self _parent] delegate] twitterOAuthViewController:[self _parent] didFailWithError:error];
	}
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)aRequest navigationType:(UIWebViewNavigationType)navigationType {
	NSURL *url = [aRequest URL];
	// TODO: allow signup too
	BOOL allow = ([[url host] isEqual:@"api.twitter.com"] && [[url path] isEqual:@"/oauth/authorize"]);
	if (allow) {
		[authorizationView fadeOut];
	}
	return allow;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	// Check for pin
	NSString *pin = [authorizationView stringByEvaluatingJavaScriptFromString:@"document.getElementById('oauth_pin').innerText"];
	if ([pin length] == 7) {
		[self _verifyAccessTokenWithPin:pin];
		return;
	}
	
	// Fade in
	[authorizationView fadeIn];
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

@end
