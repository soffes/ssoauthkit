//
//  NSDictionary+oaCompareKeys.m
//  SSOAuthKit
//
//  Created by Sam Soffes on 7/16/10.
//  Copyright 2010-2011 Sam Soffes. All rights reserved.
//

#import "NSDictionary+oaCompareKeys.h"

@implementation NSDictionary (oaCompareKeys)

- (NSComparisonResult)oaCompareKeys:(NSDictionary *)other {
	return [[self objectForKey:@"key"] compare:[other objectForKey:@"key"]];
}

@end
