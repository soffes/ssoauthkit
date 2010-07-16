//
//  TWOAToken.h
//  TWOAuthKit
//
//  Created by Sam Soffes on 7/16/10.
//  Copyright 2010 Tasteful Works, Inc. All rights reserved.
//

@interface TWOAToken : NSObject {
	
	NSString *key;
	NSString *secret;
	BOOL authorized;
}

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *secret;
@property (nonatomic, assign) BOOL authorized;

- (id)initWithKey:(NSString *)aKey secret:(NSString *)aSecret;
- (id)initWithUserDefaultsUsingServiceProviderName:(NSString *)provider prefix:(NSString *)prefix;
- (id)initWithHTTPResponseBody:(NSString *)body;
- (void)storeInUserDefaultsWithServiceProviderName:(NSString *)provider prefix:(NSString *)prefix;
- (NSString *)URLEncodedValue;

@end
