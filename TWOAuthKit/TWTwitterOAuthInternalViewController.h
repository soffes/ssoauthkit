//
//  TWTwitterOAuthInternalViewController.h
//  TWToolkit
//
//  Created by Sam Soffes on 11/9/09.
//  Copyright 2009 Tasteful Works, Inc. All rights reserved.
//

#import "ASIHTTPRequestDelegate.h"

@class TWOAFormRequest;
@class TWLoadingView;
@class OAConsumer;
@class TWOAToken;

@interface TWTwitterOAuthInternalViewController : UIViewController <UIWebViewDelegate, ASIHTTPRequestDelegate> {

	TWLoadingView *loadingView;
	UIWebView *authorizationView;
	
	TWOAFormRequest *request;
	OAConsumer *consumer;
	TWOAToken *requestToken;
}

@property (nonatomic, retain) OAConsumer *consumer;
@property (nonatomic, retain) TWOAToken *requestToken;

@end
