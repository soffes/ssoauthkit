//
//  SSTwitterAuthViewControllerDelegate.h
//  SSOAuthKit
//
//  Created by Sam Soffes on 5/24/11.
//  Copyright 2011 Sam Soffes. All rights reserved.
//

@class SSOAToken;

@protocol SSTwitterAuthViewControllerDelegate <NSObject>

@optional

- (void)twitterAuthViewControllerDidCancel:(UIViewController *)viewController;
- (void)twitterAuthViewController:(UIViewController *)viewController didFailWithError:(NSError *)error;
- (void)twitterAuthViewController:(UIViewController *)viewController didAuthorizeWithAccessToken:(SSOAToken *)accessToken userDictionary:(NSDictionary *)userDictionary;

@end
