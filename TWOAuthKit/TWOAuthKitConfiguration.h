//
//  TWOAuthKitConfiguration.h
//  TWOAuthKit
//
//  Created by Sam Soffes on 7/16/10.
//  Copyright 2010 Tasteful Works, Inc. All rights reserved.
//

@interface TWOAuthKitConfiguration : NSObject {

}

+ (void)setConsumerKey:(NSString *)key secret:(NSString *)secret;

+ (void)setConsumerKey:(NSString *)key;
+ (NSString *)consumerKey;

+ (void)setConsumerSecret:(NSString *)key;
+ (NSString *)consumerSecret;

@end
