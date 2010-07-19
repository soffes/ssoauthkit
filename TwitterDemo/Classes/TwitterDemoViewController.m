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

#pragma mark NSObject

- (void)dealloc {
	[userLabel release];
	[super dealloc];
}

#pragma mark UIViewController

- (void)viewDidLoad {
	#error Please set your consumer key and secret below and remove this line
	[TWOAuthKitConfiguration setConsumerKey:@"CONSUMER_KEY_GOES_HERE" secret:@"CONSUMER_SECRET_GOES_HERE"];
	
	// Login button
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.frame = CGRectMake(40.0, 40.0, 300.0, 44.0);
	[button setTitle:@"Login" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:button];
	
	// User label
	userLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 100.0, 300.0, 20.0)];
	[self.view addSubview:userLabel];
}

#pragma mark Actions

- (void)login:(id)sender {
	TWTwitterOAuthViewController *viewController = [[TWTwitterOAuthViewController alloc] initWithDelegate:self];
	viewController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentModalViewController:viewController animated:YES];
	[viewController release];
}

#pragma mark TWTwitterOAuthViewControllerDelegate

- (void)twitterOAuthViewControllerDidCancel:(TWTwitterOAuthViewController *)twitterOAuthViewController {
	NSLog(@"Canceled");
	[self dismissModalViewControllerAnimated:YES];
}


- (void)twitterOAuthViewController:(TWTwitterOAuthViewController *)twitterOAuthViewController didFailWithError:(NSError *)error {
	NSLog(@"Failed with error: %@", error);
	[self dismissModalViewControllerAnimated:YES];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}


- (void)twitterOAuthViewController:(TWTwitterOAuthViewController *)twitterOAuthViewController didAuthorizeWithAccessToken:(TWOAToken *)accessToken userDictionary:(NSDictionary *)userDictionary {
	NSLog(@"Finished! %@", userDictionary);
	[self dismissModalViewControllerAnimated:YES];
	
	userLabel.text = [NSString stringWithFormat:@"Logged in as @%@", [userDictionary objectForKey:@"screen_name"]];
}

@end
