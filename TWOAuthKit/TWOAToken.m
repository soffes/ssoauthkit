//
//  TWOAToken.m
//  TWOAuthKit
//
//  Created by Sam Soffes on 7/16/10.
//  Copyright 2010 Tasteful Works, Inc. All rights reserved.
//

#import "TWOAToken.h"

@implementation TWOAToken

#pragma mark Initializers

- (id)initWithUserDefaultsUsingServiceProviderName:(NSString *)provider prefix:(NSString *)prefix {
	NSString *aKey = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"OAUTH_%@_%@_KEY", prefix, provider]];
	NSString *aSecret = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"OAUTH_%@_%@_SECRET", prefix, provider]];
	
	self = [self initWithKey:aKey secret:aSecret];
	return self;
}

#pragma mark Utilities

- (void)storeInUserDefaultsWithServiceProviderName:(NSString *)provider prefix:(NSString *)prefix {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:self.key forKey:[NSString stringWithFormat:@"OAUTH_%@_%@_KEY", prefix, provider]];
	[userDefaults setObject:self.secret forKey:[NSString stringWithFormat:@"OAUTH_%@_%@_SECRET", prefix, provider]];
	[userDefaults synchronize];
}


- (NSString *)URLEncodedValue {
	return [NSString stringWithFormat:@"oauth_token=%@&oauth_token_secret=%@", self.key, self.secret];
}

@end
