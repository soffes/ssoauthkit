//
//  SSOAToken.h
//  SSOAuthKit
//
//  Created by Sam Soffes on 7/16/10.
//  Copyright 2010-2011 Sam Soffes. All rights reserved.
//

#import "SSOAConsumer.h"

@interface SSOAToken : SSOAConsumer {
	
}

- (id)initWithUserDefaultsUsingServiceProviderName:(NSString *)provider prefix:(NSString *)prefix;

// Utilities
- (void)storeInUserDefaultsWithServiceProviderName:(NSString *)provider prefix:(NSString *)prefix;
- (NSString *)URLEncodedValue;

@end
