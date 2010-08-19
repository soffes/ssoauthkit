//
//  SSOAuthKitConfiguration.h
//  SSOAuthKit
//
//  Created by Sam Soffes on 7/16/10.
//  Copyright 2010 Sam Soffes, Inc. All rights reserved.
//

@class SSOAConsumer;

@interface SSOAuthKitConfiguration : NSObject {

}

+ (SSOAConsumer *)consumer;

+ (void)setConsumerKey:(NSString *)key secret:(NSString *)secret;

+ (void)setConsumerKey:(NSString *)key;
+ (NSString *)consumerKey;

+ (void)setConsumerSecret:(NSString *)key;
+ (NSString *)consumerSecret;

@end
