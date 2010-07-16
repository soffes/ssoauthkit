//
//  TWOARequest.h
//  TWOAuthKit
//
//  Created by Sam Soffes on 1/25/10.
//  Copyright 2010 Tasteful Works. All rights reserved.
//

#import "ASIFormDataRequest.h"

@class OAToken;

@interface TWOARequest : ASIHTTPRequest {

	OAToken *token;
}

@property (retain) OAToken *token;

@end
