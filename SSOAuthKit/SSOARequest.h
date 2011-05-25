//
//  SSOARequest.h
//  SSOAuthKit
//
//  Created by Sam Soffes on 1/25/10.
//  Copyright 2010-2011 Sam Soffes. All rights reserved.
//

#import "ASIHTTPRequest.h"

@class SSOAToken;

@interface SSOARequest : ASIHTTPRequest {

@private
	
	SSOAToken *_token;
}

@property (nonatomic, retain) SSOAToken *token;

@end
