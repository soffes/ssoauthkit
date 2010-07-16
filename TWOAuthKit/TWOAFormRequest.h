//
//  TWOAFormRequest.h
//  TWOAuthKit
//
//  Created by Sam Soffes on 4/7/10.
//  Copyright 2010 Tasteful Works. All rights reserved.
//

#import "ASIFormDataRequest.h"

@class TWOAToken;

@interface TWOAFormRequest : ASIFormDataRequest {
	
	TWOAToken *token;
}

@property (retain) TWOAToken *token;

@end
