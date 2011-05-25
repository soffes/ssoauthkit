//
//  SSTwitterAuthViewController.m
//  SSOAuthKit
//
//  Created by Sam Soffes on 5/24/11.
//  Copyright 2011 Sam Soffes. All rights reserved.
//

#import "SSTwitterAuthViewController.h"
#import "SSTwitterAuthViewControllerDelegate.h"
#import "SSOAFormRequest.h"
#import "SSOAToken.h"
#import "JSONKit.h"
#import <SSToolkit/SSLoadingView.h>

static NSString *kSSTwitterAuthViewControllerErrorDomain = @"com.samsoffes.sstwitteroauthviewcontroller";

@implementation SSTwitterAuthViewController

@synthesize delegate = _delegate;
@synthesize request = _request;
@synthesize accessToken = _accessToken;
@synthesize loadingView = _loadingView;

#pragma mark -
#pragma mark NSObject

- (id)init {
	if ((self = [super init])) {
		self.modalPresentationStyle = UIModalPresentationFormSheet;
	}
	return self;
}


- (void)dealloc {
	_delegate = nil;
	[self cancelRequest];
	[_loadingView release];
	self.accessToken = nil;	
	[super dealloc];
}


#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"Twitter";
	
	// Cancel button
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	
	// Loading
	_loadingView = [[SSLoadingView alloc] initWithFrame:CGRectZero];
	_loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_loadingView.backgroundColor = [UIColor clearColor];
	_loadingView.opaque = NO;
}


#pragma mark -
#pragma mark Initalizer

- (id)initWithDelegate:(id<SSTwitterAuthViewControllerDelegate>)aDelegate {
	if ((self = [self init])) {
		self.delegate = aDelegate;
	}
	return self;
}


#pragma mark -
#pragma mark Actions

- (void)cancel:(id)sender {
	[self cancelRequest];
	
	if ([_delegate respondsToSelector:@selector(twitterAuthViewControllerDidCancel:)]) {
		[_delegate twitterAuthViewControllerDidCancel:self];
	}
}


#pragma mark -
#pragma mark Internal

- (void)cancelRequest {
	self.request.delegate = nil;
	[self.request cancel];
	self.request = nil;
}


- (void)requestUser {
	[self cancelRequest];
	
	_loadingView.text = @"Saving...";
	
	NSURL *url = [[NSURL alloc] initWithString:@"https://api.twitter.com/1/account/verify_credentials.json"];
	
	SSOAFormRequest *aRequest = [[SSOAFormRequest alloc] initWithURL:url];
	aRequest.requestMethod = @"GET";
	aRequest.token = _accessToken;
	aRequest.delegate = self;
	self.request = aRequest;
	[aRequest release];
	[url release];
	
	[self.request startAsynchronous];
}


- (void)failWithError:(NSError *)error {
	if ([_delegate respondsToSelector:@selector(twitterAuthViewController:didFailWithError:)]) {
		[_delegate twitterAuthViewController:self didFailWithError:error];
	}
}


- (void)failWithErrorString:(NSString *)message code:(NSInteger)code {
	if ([_delegate respondsToSelector:@selector(twitterAuthViewController:didFailWithError:)]) {
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:message, NSLocalizedDescriptionKey, nil];
		NSError *error = [NSError errorWithDomain:kSSTwitterAuthViewControllerErrorDomain code:code userInfo:userInfo];
		[_delegate twitterAuthViewController:self didFailWithError:error];
	}
}


#pragma mark -
#pragma mark ASIHTTPRequestDelegate

- (void)requestStarted:(ASIHTTPRequest *)aRequest {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}


- (void)requestFailed:(ASIHTTPRequest *)aRequest {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[self failWithError:[aRequest error]];
}


- (void)requestFinished:(ASIHTTPRequest *)aRequest {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	if ([aRequest responseStatusCode] >= 500) {
		[self failWithErrorString:@"Something went technically wrong on Twitter's end. Maybe try again later." code:-2];
		return;
	}
	
	NSString *path = [[aRequest url] path];
	
	// Get user
	if ([path isEqualToString:@"/1/account/verify_credentials.json"]) {
		NSError *jsonError = nil;
		NSDictionary *dictionary = [[aRequest responseData] objectFromJSONDataWithParseOptions:0 error:&jsonError];
		if (!dictionary) {
			// Pass access token along since we successfully got it already
			NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
									  jsonError, NSUnderlyingErrorKey,
									  _accessToken, @"accessToken",
									  @"Failed to get Twitter profile.", NSLocalizedDescriptionKey,
									  nil];			
			NSError *error = [NSError errorWithDomain:kSSTwitterAuthViewControllerErrorDomain code:-3 userInfo:userInfo];
			[userInfo release];
			[self failWithError:error];
			return;
		}
		
		// Notify delegate
		if ([self.delegate respondsToSelector:@selector(twitterAuthViewController:didAuthorizeWithAccessToken:userDictionary:)]) {
			[self.delegate twitterAuthViewController:self didAuthorizeWithAccessToken:_accessToken userDictionary:dictionary];
		}
	}
}

@end
