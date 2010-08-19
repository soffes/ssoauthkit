//
//  TWTwitterOAuthViewController.h
//  TWToolkit
//
//  Created by Sam Soffes on 11/3/09.
//  Copyright 2009 Tasteful Works, Inc. All rights reserved.
//

@class TWOAToken;
@protocol TWTwitterOAuthViewControllerDelegate;

@interface TWTwitterOAuthViewController : UINavigationController {
	
	id<TWTwitterOAuthViewControllerDelegate> delegate;
}

@property (nonatomic, assign) id<TWTwitterOAuthViewControllerDelegate> delegate;

- (id)initWithDelegate:(id<TWTwitterOAuthViewControllerDelegate>)aDelegate;
- (void)cancel:(id)sender;

@end


@protocol TWTwitterOAuthViewControllerDelegate <NSObject>

- (void)twitterOAuthViewControllerDidCancel:(TWTwitterOAuthViewController *)twitterOAuthViewController;
- (void)twitterOAuthViewController:(TWTwitterOAuthViewController *)twitterOAuthViewController didFailWithError:(NSError *)error;
- (void)twitterOAuthViewController:(TWTwitterOAuthViewController *)twitterOAuthViewController didAuthorizeWithAccessToken:(TWOAToken *)accessToken userDictionary:(NSDictionary *)userDictionary;

@end
