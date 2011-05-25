//
//  SSOAFormRequest.h
//  SSOAuthKit
//
//  Created by Sam Soffes on 4/7/10.
//  Copyright 2010-2011 Sam Soffes. All rights reserved.
//

#import "ASIFormDataRequest.h"

@class SSOAToken;

@interface SSOAFormRequest : ASIFormDataRequest {
	
@private
	
	SSOAToken *_token;
}

@property (nonatomic, retain) SSOAToken *token;

@end
