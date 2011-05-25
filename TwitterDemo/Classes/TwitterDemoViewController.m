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

#pragma mark -
#pragma mark NSObject

- (void)dealloc {
	[_userLabel release];
	[super dealloc];
}


#pragma mark -
#pragma mark UIViewController

- (void)viewDidLoad {
	#error Please set your consumer key and secret below and remove this line
	[SSOAuthKitConfiguration setConsumerKey:@"COMSUMER_KEY" secret:@"COMSUMER_SECRET"];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	// Login with OAuth button
	UIButton *oAuthButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	oAuthButton.frame = CGRectMake(20.0, 20.0, 280.0, 44.0);
	[oAuthButton setTitle:@"Login with OAuth" forState:UIControlStateNormal];
	[oAuthButton addTarget:self action:@selector(loginWithOAuth:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:oAuthButton];
	
	// Login with xAuth button
	UIButton *xAuthButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	xAuthButton.frame = CGRectMake(20.0, 84.0, 280.0, 44.0);
	[xAuthButton setTitle:@"Login with xAuth" forState:UIControlStateNormal];
	[xAuthButton addTarget:self action:@selector(loginWithXAuth:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:xAuthButton];
	
	// User label
	_userLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 148.0, 280.0, 20.0)];
	[self.view addSubview:_userLabel];
}


#pragma mark -
#pragma mark Actions

- (void)loginWithOAuth:(id)sender {
	SSTwitterOAuthViewController *viewController = [[SSTwitterOAuthViewController alloc] initWithDelegate:self];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentModalViewController:navigationController animated:YES];
	[viewController release];
	[navigationController release];
}


- (void)loginWithXAuth:(id)sender {
	SSTwitterXAuthViewController *viewController = [[SSTwitterXAuthViewController alloc] initWithDelegate:self];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentModalViewController:navigationController animated:YES];
	[viewController release];
	[navigationController release];
}


#pragma mark -
#pragma mark SSTwitterOAuthViewControllerDelegate

- (void)twitterAuthViewControllerDidCancel:(UIViewController *)viewController {
	NSLog(@"Canceled");
	[self dismissModalViewControllerAnimated:YES];
}


- (void)twitterAuthViewController:(UIViewController *)viewController didFailWithError:(NSError *)error {
	NSLog(@"Failed with error: %@", error);
	[self dismissModalViewControllerAnimated:YES];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}


- (void)twitterAuthViewController:(UIViewController *)viewController didAuthorizeWithAccessToken:(SSOAToken *)accessToken userDictionary:(NSDictionary *)userDictionary {
	NSLog(@"Finished! %@", userDictionary);
	[self dismissModalViewControllerAnimated:YES];
	
	_userLabel.text = [NSString stringWithFormat:@"Logged in as @%@", [userDictionary objectForKey:@"screen_name"]];
}

@end
