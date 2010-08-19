//
//  SSTwitterOAuthViewController.h
//  SSOAuthKit
//
//  Created by Sam Soffes on 11/3/09.
//  Copyright 2009 Sam Soffes, Inc. All rights reserved.
//

@class SSOAToken;
@protocol SSTwitterOAuthViewControllerDelegate;

@interface SSTwitterOAuthViewController : UINavigationController {
	
	id<SSTwitterOAuthViewControllerDelegate> delegate;
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
