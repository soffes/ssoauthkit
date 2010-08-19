//
//  SSTwitterOAuthInternalViewController.h
//  SSOAuthKit
//
//  Created by Sam Soffes on 11/9/09.
//  Copyright 2009 Sam Soffes, Inc. All rights reserved.
//

#import "ASIHTTPRequestDelegate.h"

@class SSOAFormRequest;
@class SSLoadingView;
@class SSOAToken;

@interface SSTwitterOAuthInternalViewController : UIViewController <UIWebViewDelegate, ASIHTTPRequestDelegate> {

	SSLoadingView *loadingView;
	UIWebView *authorizationView;
	
	SSOAFormRequest *request;
	SSOAToken *requestToken;
	SSOAToken *accessToken;
}

@end
