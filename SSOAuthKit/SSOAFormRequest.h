//
//  SSOAFormRequest.h
//  SSOAuthKit
//
//  Created by Sam Soffes on 4/7/10.
//  Copyright 2010 Sam Soffes. All rights reserved.
//

#import "ASIFormDataRequest.h"

@class SSOAToken;

@interface SSOAFormRequest : ASIFormDataRequest {
	
	SSOAToken *token;
}

@property (copy) SSOAToken *token;

@end
