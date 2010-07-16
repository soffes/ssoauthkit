//
//  TWOARequest.h
//  TWOAuthKit
//
//  Created by Sam Soffes on 1/25/10.
//  Copyright 2010 Tasteful Works. All rights reserved.
//

#import "ASIHTTPRequest.h"

@class TWOAToken;

@interface TWOARequest : ASIHTTPRequest {

	TWOAToken *token;
}

@property (retain) TWOAToken *token;

@end
