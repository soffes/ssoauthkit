//
//  TWOAConsumer.h
//  TWOAuthKit
//
//  Created by Sam Soffes on 7/16/10.
//  Copyright 2010 Tasteful Works, Inc. All rights reserved.
//

@interface TWOAConsumer : NSObject <NSCoding, NSCopying> {

	NSString *key;
	NSString *secret;
}

@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *secret;

// Initializers
- (id)initWithKey:(NSString *)aKey secret:(NSString *)aSecret;
- (id)initWithHTTPResponseBody:(NSString *)body;

@end
