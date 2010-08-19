//
//  SSOARequest.h
//  SSOAuthKit
//
//  Created by Sam Soffes on 1/25/10.
//  Copyright 2010 Sam Soffes. All rights reserved.
//

#import "ASIHTTPRequest.h"

@class SSOAToken;

@interface SSOARequest : ASIHTTPRequest {

	SSOAToken *token;
}

@property (copy) SSOAToken *token;

@end
