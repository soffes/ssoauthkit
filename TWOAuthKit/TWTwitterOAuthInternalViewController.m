//
//  TWTwitterOAuthInternalViewController.m
//  TWToolkit
//
//  Created by Sam Soffes on 11/9/09.
//  Copyright 2009 Tasteful Works, Inc. All rights reserved.
//

#import "TWTwitterOAuthInternalViewController.h"
#import "TWTwitterOAuthViewController.h"
#import "OAConsumer.h"
#import "OAToken.h"
#import "TWOAFormRequest.h"
#import "ASIHTTPRequest.h"
#import "NSObject+yajl.h"
#import <TWToolkit/TWLoadingView.h>
#import <TWToolkit/TWCategories.h>

@interface TWTwitterOAuthInternalViewController (Private)

- (TWTwitterOAuthViewController *)_parent;
- (void)_requestRequestToken;
- (void)_requestAccessToken;
- (void)_verifyAccessTokenWithPin:(NSString *)pin;
- (void)_requestUser;

@end


@implementation TWTwitterOAuthInternalViewController

@synthesize consumer;
@synthesize requestToken;
@synthesize accessToken;

#pragma mark -
#pragma mark NSObject
#pragma mark -

- (void)dealloc {
	request.delegate = nil;
	[request cancel];
	[request release];
	
	[loadingView release];
	[authorizationView release];
	self.consumer = nil;
	self.requestToken = nil;
	self.accessToken = nil;
	[super dealloc];
}


#pragma mark -
#pragma mark UIViewController
#pragma mark -

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Authorize";
	
	// Background image
	UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 190.0)];
	backgroundImageView.image = [UIImage imageNamed:@"images/twitter_oauth_background.png" bundle:@"TWOAuthKit.bundle"];
	backgroundImageView.opaque = YES;
	[self.view addSubview:backgroundImageView];
	[backgroundImageView release];
	self.view.backgroundColor = [UIColor colorWithRed:0.753 green:0.875 blue:0.925 alpha:1.0];
	
	// Navigation Bar
	self.navigationItem.hidesBackButton = NO;
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self.navigationController action:@selector(cancel:)];
	self.navigationItem.rightBarButtonItem = cancelButton;
	[cancelButton release];
	
	// Loading
	loadingView = [[TWLoadingView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
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

- (TWTwitterOAuthViewController *)_parent {
	return (TWTwitterOAuthViewController *)self.navigationController;
}


// Step 1
- (void)_requestRequestToken {

	// Update loading text
	loadingView.text = @"Requesting token...";
	
	// Perform request for request token
	NSURL *url = [[NSURL alloc] initWithString:@"http://twitter.com/oauth/request_token"];
	request = [[TWOAFormRequest alloc] initWithURL:url];
	request.delegate = self;
	[request startAsynchronous];
}


// Step 2
- (void)_requestAccessToken {	
	loadingView.text = @"Authorizing...";
	
	NSString *urlString = [[NSString alloc] initWithFormat:@"http://twitter.com/oauth/authorize?oauth_token=%@&oauth_callback=oob", requestToken.key];
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


// Step 3
- (void)_verifyAccessTokenWithPin:(NSString *)pin {
	loadingView.text = @"Verifying...";
	
	[authorizationView fadeOut];
	[authorizationView release];
	authorizationView = nil;	
	
	NSString *urlString = [[NSString alloc] initWithFormat:@"http://twitter.com/oauth/access_token?oauth_token=%@&oauth_verifier=%@", requestToken.key, pin];
	NSURL *url = [[NSURL alloc] initWithString:urlString];

	[request cancel];
	[request release];
	
	request = [[TWOAFormRequest alloc] initWithURL:url];
	request.token = requestToken;
	request.delegate = self;
	[request startAsynchronous];
	
	[url release];
	[urlString release];
}


// Step 4
- (void)_requestUser {
	[request cancel];
	[request release];
	
	// Build Request
	NSURL *url = [[NSURL alloc] initWithString:@"http://twitter.com/account/verify_credentials.json"];
	request = [[TWOAFormRequest alloc] initWithURL:url];
	request.delegate = self;
	request.token = accessToken;
	[request startAsynchronous];
	
	[url release];
}


#pragma mark -
#pragma mark TWURLConnectionDelegate
#pragma mark -

- (void)requestFailed:(ASIHTTPRequest *)aRequest {
	if ([[[self _parent] delegate] respondsToSelector:@selector(twitterOAuthViewController:didFailWithError:)]) {
		[[[self _parent] delegate] twitterOAuthViewController:[self _parent] didFailWithError:[aRequest error]];
	}
}


- (void)requestFinished:(ASIHTTPRequest *)aRequest {
	
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
		OAToken *aToken = [[OAToken alloc] initWithHTTPResponseBody:httpBody];
		
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
		self.requestToken = aToken;
		[aToken release];
		
		// Start authorizing
		[self _requestAccessToken];
		return;
	}
	
	// *** Step 2 - Authorize (web view handles this)
	
	// *** Step 3 - Verify token
	else if ([path isEqualToString:@"/oauth/access_token"]) {
		
		// Get token
		OAToken *aToken = [[OAToken alloc] initWithHTTPResponseBody:[aRequest responseString]];
		
		// Check for token error
		if (!aToken.key || !aToken.secret) {
			[aToken release];
			if ([[[self _parent] delegate] respondsToSelector:@selector(twitterOAuthViewController:didFailWithError:)]) {
				NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"The access token could not be generated", NSLocalizedDescriptionKey, nil];
				NSError *error = [NSError errorWithDomain:@"com.tasetfulworks.twtwitteroauthviewcontroller" code:-1 userInfo:userInfo];
				[[[self _parent] delegate] twitterOAuthViewController:[self _parent] didFailWithError:error];
			}
			return;
		}
		
		// Store token
		self.accessToken = aToken;
		[aToken release];
		
		// Lookup user
		[self _requestUser];
		return;
	}
	
	// *** Step 4 - User lookup
	else if ([path isEqualToString:@"/account/verify_credentials.json"]) {
		
		NSError *error = nil;
		NSDictionary *dictionary = [[aRequest responseString] yajl_JSON:&error];
		if (error) {
			if ([[[self _parent] delegate] respondsToSelector:@selector(twitterOAuthViewController:didFailWithError:)]) {
				[[[self _parent] delegate] twitterOAuthViewController:[self _parent] didFailWithError:[aRequest error]];
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
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)aRequest navigationType:(UIWebViewNavigationType)navigationType {
	NSURL *url = [aRequest URL];
	// TODO: allow signup too
	BOOL allow = ([[url host] isEqual:@"twitter.com"] && [[url path] isEqual:@"/oauth/authorize"]);
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
	
//	// Pretty up form and get height
//	[authorizationView stringByEvaluatingJavaScriptFromString:@"\
//	 $('html, body').css({'width': '320px', 'overflow-x': 'hidden'});\
//	 $('body *').css('-webkit-user-select', 'none');\
//	 $('#header').css('width', '320px');\
//	 $('#twitainer').css({'width': '300px', 'padding': '10px 0', 'overflow': 'hidden'});\
//	 $('#content').css('width', '300px');\
//	 $('.signin-content').css({'width': '280px', 'padding': '10px', '-webkit-border-radius': '5px'});\
//	 $('h2').css({'font-size': '17px', 'font-family': '\\'Lucida Grande\\',sans-serif', 'margin': '0 0 12px'});\
//	 $('.signin-content h2').css('min-height', '73px');\
//	 $('.app-icon').css('margin', '0 12px 12px 0');\
//	 $('h4').css({'font-size': '0.65em', 'font-family': '\\'Lucida Grande\\',sans-serif', 'margin': 0});\
//	 \
//	 $('#signin_form').css('margin-top', '6px');\
//	 $('#signin_form th').css('display', 'none');\
//	 $('input[type=text], input[type=password]').css({'width': '260px', 'font-size': '15px', 'padding': '4px', '-webkit-user-select': 'text'});\
//	 $('input[type=text]').attr({'placeholder': 'Username or Email', 'autocorrect': 'off'});\
//	 $('input[type=password]').attr('placeholder', 'Password');\
//	 \
//	 var tos = $('.tos')[0].innerHTML;\
//	 $('.tos').remove();\
//	 $('.signin-content').append('<div style=\"font-size:0.9em;color:#888;line-height:1.3em;\">'+tos+'</div>');\
//	 \
//	 var deny = $('#deny');\
//	 deny.remove();\
//	 var buttons = $('.buttons');\
//	 buttons.append(deny);\
//	 deny.css({'float': 'left', 'margin-left': '43px'});\
//	 $('#allow').css({'margin-right': '35px', 'margin-left': '10px', 'float': 'right'});\
//	 buttons.append('<div style=\"clear:both\"></div>');\
//	 \
//	 $(document.body).outerWidth(320);"];
//	
//	NSString *height = [authorizationView stringByEvaluatingJavaScriptFromString:@"\
//						$('#twitainer').height() + $('#twitainer').get(0).offsetTop"];
//	
//	// Resize webview scroller
//	CGFloat sizeHeight = [height floatValue] + 20.0;
//	[[authorizationView scroller] setContentSize:CGSizeMake(320.0, sizeHeight)];
	
	// Fade in
	[authorizationView fadeIn];
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

@end
