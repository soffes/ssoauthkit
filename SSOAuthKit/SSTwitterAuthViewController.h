//
//  SSTwitterAuthViewController.h
//  SSOAuthKit
//
//  Created by Sam Soffes on 5/24/11.
//  Copyright 2011 Sam Soffes. All rights reserved.
//

#import "ASIHTTPRequestDelegate.h"

@protocol SSTwitterAuthViewControllerDelegate;
@class SSOAFormRequest;
@class SSOAToken;
@class SSLoadingView;

@interface SSTwitterAuthViewController : UIViewController <ASIHTTPRequestDelegate> {

@private
	
	id<SSTwitterAuthViewControllerDelegate> _delegate;
	SSOAFormRequest *_request;
	SSOAToken *_accessToken;
	SSLoadingView *_loadingView;
}

@property (nonatomic, assign) id<SSTwitterAuthViewControllerDelegate> delegate;

- (id)initWithDelegate:(id<SSTwitterAuthViewControllerDelegate>)aDelegate;
- (void)cancel:(id)sender;

#pragma mark Internal

// Use the following if you are subclassing

@property (nonatomic, retain) SSOAFormRequest *request;
@property (nonatomic, retain) SSOAToken *accessToken;
@property (nonatomic, retain, readonly) SSLoadingView *loadingView;

- (void)cancelRequest;
- (void)requestUser;
- (void)failWithError:(NSError *)error;
- (void)failWithErrorString:(NSString *)message code:(NSInteger)code;

@end
