//
//  SSTwitterOAuthViewController.h
//  SSOAuthKit
//
//  Created by Sam Soffes on 11/3/09.
//  Copyright 2009-2011 Sam Soffes. All rights reserved.
//

#import "SSTwitterAuthViewController.h"

@class SSOAToken;

@interface SSTwitterOAuthViewController : SSTwitterAuthViewController <UIWebViewDelegate> {
	
@private
	
	UIWebView *_authorizationView;
	SSOAToken *_requestToken;
	BOOL _verifying;
}

@end
