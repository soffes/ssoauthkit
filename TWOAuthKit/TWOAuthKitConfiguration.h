//
//  TWOAuthKitConfiguration.h
//  TWOAuthKit
//
//  Created by Sam Soffes on 7/16/10.
//  Copyright 2010 Tasteful Works, Inc. All rights reserved.
//

@class OAConsumer;

@interface TWOAuthKitConfiguration : NSObject {

}

+ (OAConsumer *)consumer;

+ (void)setConsumerKey:(NSString *)key secret:(NSString *)secret;

+ (void)setConsumerKey:(NSString *)key;
+ (NSString *)consumerKey;

+ (void)setConsumerSecret:(NSString *)key;
+ (NSString *)consumerSecret;

@end
