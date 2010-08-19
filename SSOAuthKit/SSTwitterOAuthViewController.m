//
//  SSTwitterOAuthViewController.m
//  SSOAuthKit
//
//  Created by Sam Soffes on 11/3/09.
//  Copyright 2009 Sam Soffes, Inc. All rights reserved.
//

#import "SSTwitterOAuthViewController.h"
#import "SSTwitterOAuthInternalViewController.h"
#import "SSOAuthKitConfiguration.h"

@implementation SSTwitterOAuthViewController

@synthesize delegate;

#pragma mark Initalizer

- (id)initWithDelegate:(id<SSTwitterOAuthViewControllerDelegate>)aDelegate {
	SSTwitterOAuthInternalViewController *internalViewController = [[SSTwitterOAuthInternalViewController alloc] initWithNibName:nil bundle:nil];
	if (self = [super initWithRootViewController:internalViewController]) {
		self.delegate = aDelegate;
	}
	[internalViewController release];
	return self;
}

#pragma mark Actions

- (void)cancel:(id)sender {
	if ([delegate respondsToSelector:@selector(twitterOAuthViewControllerDidCancel:)]) {
		[delegate twitterOAuthViewControllerDidCancel:self];
	}
}

@end
