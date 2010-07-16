//
//  TwitterDemoViewController.m
//  TwitterDemo
//
//  Created by Sam Soffes on 7/16/10.
//  Copyright Tasteful Works 2010. All rights reserved.
//

#import "TwitterDemoViewController.h"
#import <TWOAuthKit/TWOAuthKit.h>.

@implementation TwitterDemoViewController

- (void)viewDidLoad {
//	#error Please set your consumer key and secret
	[TWOAuthKitConfiguration setConsumerKey:@"MRYaVxPdxijdnFPYBKVQ" secret:@"YCk4IDmXA119BIzqmt569mIXF5R5BBce81F0TQNeSWI"];
	
	// Login button
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.frame = CGRectMake(40.0, 40.0, 300.0, 44.0);
	[button setTitle:@"Login" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:button];
}

#pragma mark Actions

- (void)login:(id)sender {
	TWTwitterOAuthViewController *viewController = [[TWTwitterOAuthViewController alloc] initWithDelegate:self];
	viewController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentModalViewController:viewController animated:YES];
	[viewController release];
}

#pragma mark TWTwitterOAuthViewControllerDelegate

- (void)twitterOAuthViewControllerDidCancel:(TWTwitterOAuthViewController *)viewController {
	NSLog(@"Canceled");
	[self dismissModalViewControllerAnimated:YES];
}


- (void)twitterOAuthViewController:(TWTwitterOAuthViewController *)viewController didFailWithError:(NSError *)error {
	NSLog(@"Failed with error: %@", error);
	[self dismissModalViewControllerAnimated:YES];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}


- (void)twitterOAuthViewController:(TWTwitterOAuthViewController *)viewController didAuthorizeWithAccessToken:(OAToken *)accessToken userDictionary:(NSDictionary *)userDictionary {
	NSLog(@"Finished! %@", userDictionary);
	[self dismissModalViewControllerAnimated:YES];
}

@end
