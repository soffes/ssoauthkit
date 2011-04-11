//
//  SSTwitterOAuthViewController.h
//  SSOAuthKit
//
//  Created by Sam Soffes on 11/3/09.
//  Copyright 2009-2011 Sam Soffes. All rights reserved.
//

#import "ASIHTTPRequestDelegate.h"

@class SSOAFormRequest;
@class SSLoadingView;
@class SSOAToken;

@protocol SSTwitterOAuthViewControllerDelegate;

@interface SSTwitterOAuthViewController : UIViewController <UIWebViewDelegate, ASIHTTPRequestDelegate> {
	
	id<SSTwitterOAuthViewControllerDelegate> _delegate;
	
	SSLoadingView *_loadingView;
	UIWebView *_authorizationView;
	
	SSOAFormRequest *_request;
	SSOAToken *_requestToken;
	SSOAToken *_accessToken;
}

@property (nonatomic, assign) id<SSTwitterOAuthViewControllerDelegate> delegate;

- (id)initWithDelegate:(id<SSTwitterOAuthViewControllerDelegate>)aDelegate;
- (void)cancel:(id)sender;

@end


@protocol SSTwitterOAuthViewControllerDelegate <NSObject>

- (void)twitterOAuthViewControllerDidCancel:(SSTwitterOAuthViewController *)twitterOAuthViewController;
- (void)twitterOAuthViewController:(SSTwitterOAuthViewController *)twitterOAuthViewController didFailWithError:(NSError *)error;
- (void)twitterOAuthViewController:(SSTwitterOAuthViewController *)twitterOAuthViewController didAuthorizeWithAccessToken:(SSOAToken *)accessToken userDictionary:(NSDictionary *)userDictionary;

@end
