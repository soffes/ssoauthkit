//
//  TwitterDemoViewController.m
//  TwitterDemo
//
//  Created by Sam Soffes on 7/16/10.
//  Copyright Sam Soffes 2010-2011. All rights reserved.
//

#import "TwitterDemoViewController.h"
#import <SSOAuthKit/SSOAuthKit.h>

@implementation TwitterDemoViewController

#pragma mark NSObject

- (void)dealloc {
	[_userLabel release];
	[super dealloc];
}


#pragma mark UIViewController

- (void)viewDidLoad {
	#error Please set your consumer key and secret below and remove this line
	[SSOAuthKitConfiguration setConsumerKey:@"COMSUMER_KEY" secret:@"COMSUMER_SECRET"];
	
	// Login button
	UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	button.frame = CGRectMake(20.0, 20.0, 280.0, 44.0);
	[button setTitle:@"Login" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:button];
	
	// User label
	_userLabel = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 100.0, 300.0, 20.0)];
	[self.view addSubview:_userLabel];
}


#pragma mark Actions

- (void)login:(id)sender {
	SSTwitterOAuthViewController *viewController = [[SSTwitterOAuthViewController alloc] initWithDelegate:self];
	viewController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentModalViewController:viewController animated:YES];
	[viewController release];
}


#pragma mark SSTwitterOAuthViewControllerDelegate

- (void)twitterOAuthViewControllerDidCancel:(SSTwitterOAuthViewController *)twitterOAuthViewController {
	NSLog(@"Canceled");
	[self dismissModalViewControllerAnimated:YES];
}


- (void)twitterOAuthViewController:(SSTwitterOAuthViewController *)twitterOAuthViewController didFailWithError:(NSError *)error {
	NSLog(@"Failed with error: %@", error);
	[self dismissModalViewControllerAnimated:YES];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}


- (void)twitterOAuthViewController:(SSTwitterOAuthViewController *)twitterOAuthViewController didAuthorizeWithAccessToken:(SSOAToken *)accessToken userDictionary:(NSDictionary *)userDictionary {
	NSLog(@"Finished! %@", userDictionary);
	[self dismissModalViewControllerAnimated:YES];
	
	_userLabel.text = [NSString stringWithFormat:@"Logged in as @%@", [userDictionary objectForKey:@"screen_name"]];
}

@end
