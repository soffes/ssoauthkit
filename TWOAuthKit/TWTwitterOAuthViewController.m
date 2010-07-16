//
//  TWTwitterOAuthViewController.m
//  TWToolkit
//
//  Created by Sam Soffes on 11/3/09.
//  Copyright 2009 Tasteful Works, Inc. All rights reserved.
//

#import "TWTwitterOAuthViewController.h"
#import "TWTwitterOAuthInternalViewController.h"
#import "TWOAuthKitConfiguration.h"

@implementation TWTwitterOAuthViewController

@synthesize delegate;

#pragma mark Initalizer

- (id)initWithDelegate:(id<TWTwitterOAuthViewControllerDelegate>)aDelegate {
	TWTwitterOAuthInternalViewController *internalViewController = [[TWTwitterOAuthInternalViewController alloc] initWithNibName:nil bundle:nil];
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
