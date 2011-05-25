//
//  SSOAConsumer.h
//  SSOAuthKit
//
//  Created by Sam Soffes on 7/16/10.
//  Copyright 2010-2011 Sam Soffes. All rights reserved.
//

@interface SSOAConsumer : NSObject <NSCoding, NSCopying> {

@private
	
	NSString *_key;
	NSString *_secret;
}

@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *secret;

// Initializers
- (id)initWithKey:(NSString *)aKey secret:(NSString *)aSecret;
- (id)initWithHTTPResponseBody:(NSString *)body;

@end
