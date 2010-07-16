//
//  TWOAToken.h
//  TWOAuthKit
//
//  Created by Sam Soffes on 7/16/10.
//  Copyright 2010 Tasteful Works, Inc. All rights reserved.
//

#import "TWOAConsumer.h"

@interface TWOAToken : TWOAConsumer {
	
}

- (id)initWithUserDefaultsUsingServiceProviderName:(NSString *)provider prefix:(NSString *)prefix;

// Utilities
- (void)storeInUserDefaultsWithServiceProviderName:(NSString *)provider prefix:(NSString *)prefix;
- (NSString *)URLEncodedValue;

@end
