//
//  SSTwitterXAuthViewController.m
//  SSOAuthKit
//
//  Created by Sam Soffes on 5/24/11.
//  Copyright 2011 Sam Soffes. All rights reserved.
//

#import "SSTwitterXAuthViewController.h"
#import "SSOAFormRequest.h"
#import "SSOAToken.h"
#import <SSToolkit/SSLoadingView.h>
#import <SSToolkit/UIView+SSToolkitAdditions.h>

@implementation SSTwitterXAuthViewController

@synthesize usernameTextField = _usernameTextField;
@synthesize passwordTextField = _passwordTextField;
@synthesize tableView = _tableView;

#pragma mark -
#pragma mark NSObject

- (void)dealloc {
	_tableView.dataSource = nil;
	_tableView.delegate = nil;
	[_tableView release];
	
	[_usernameTextField release];
	[_passwordTextField release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark UIViewController

- (void)loadView {
	_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	_tableView.dataSource = self;
	_tableView.delegate = self;
	self.view = _tableView;
}


- (void)viewDidLoad {
	[super viewDidLoad];
	
	UIBarButtonItem *signInButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign In" style:UIBarButtonItemStyleDone target:self action:@selector(signIn:)];
	signInButton.enabled = NO;
	self.navigationItem.rightBarButtonItem = signInButton;
	[signInButton release];
	
	UIColor *textColor = [UIColor colorWithRed:0.102f green:0.310f blue:0.498f alpha:1.0f];
	
	_usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 195.0f, 43.0f)];
	_usernameTextField.backgroundColor = [UIColor clearColor];
	_usernameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	_usernameTextField.keyboardType = UIKeyboardTypeEmailAddress;
	_usernameTextField.delegate = self;
	_usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
	_usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_usernameTextField.returnKeyType = UIReturnKeyNext;
	_usernameTextField.textColor = textColor;
	
	_passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 195.0f, 42.0f)];
	_passwordTextField.backgroundColor = [UIColor clearColor];
	_passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	_passwordTextField.secureTextEntry = YES;
	_passwordTextField.delegate = self;
	_passwordTextField.returnKeyType = UIReturnKeyGo;
	_passwordTextField.textColor = textColor;
	
	self.loadingView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f);
	self.loadingView.alpha = 0.0f;
	self.loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
	UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
	[footer addSubview:self.loadingView];
	_tableView.tableFooterView = footer;
	[footer release];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[_usernameTextField becomeFirstResponder];
}


#pragma mark -
#pragma mark Actions

- (void)signIn:(id)sender {
	[self cancelRequest];
	
	_usernameTextField.enabled = NO;
	_passwordTextField.enabled = NO;
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	[self.loadingView fadeIn];
	self.loadingView.text = @"Signing in...";
	
	NSURL *url = [[NSURL alloc] initWithString:@"https://api.twitter.com/oauth/access_token"];
	
	SSOAFormRequest *aRequest = [[SSOAFormRequest alloc] initWithURL:url];
	aRequest.delegate = self;
	
	[aRequest addPostValue:_usernameTextField.text forKey:@"x_auth_username"];
	[aRequest addPostValue:_passwordTextField.text forKey:@"x_auth_password"];
	[aRequest addPostValue:@"client_auth" forKey:@"x_auth_mode"];
	self.request = aRequest;
	[aRequest release];
	[url release];
	
	[self.request startAsynchronous];
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"cellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	// Username
	if (indexPath.row == 0) {
		cell.textLabel.text = @"Username";
		cell.accessoryView = _usernameTextField;
	}
	
	// Password
	else if (indexPath.row == 1) {
		cell.textLabel.text = @"Password";
		cell.accessoryView = _passwordTextField;
	}
	
	return cell;
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSInteger usernameLength = [_usernameTextField.text length];
	NSInteger passwordLength = [_passwordTextField.text length];
	
	if (textField == _usernameTextField) {
		usernameLength += [string length] - range.length;
	} else {
		passwordLength += [string length] - range.length;
	}
	
	self.navigationItem.rightBarButtonItem.enabled = (usernameLength > 0 && passwordLength > 0);
	return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == _usernameTextField) {
		[_passwordTextField becomeFirstResponder];
	} else if (textField == _passwordTextField) {
		[self signIn:_passwordTextField];
	}
	return YES;
}


#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	[_usernameTextField becomeFirstResponder];
}


#pragma mark -
#pragma mark ASIHTTPRequestDelegate

- (void)requestFailed:(ASIHTTPRequest *)aRequest {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	// Handle bad password
	if ([aRequest responseStatusCode] == 401) {
		[self.loadingView fadeOut];
		
		_usernameTextField.enabled = YES;
		_passwordTextField.enabled = YES;
		self.navigationItem.rightBarButtonItem.enabled = YES;
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your username and password could not be verified. Double check that you entered them correctly and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	[self failWithError:[aRequest error]];
}


- (void)requestFinished:(ASIHTTPRequest *)aRequest {
	[super requestFinished:aRequest];

	if ([[[aRequest url] path] isEqualToString:@"/oauth/access_token"]) {
		// Create access token
		SSOAToken *aToken = [[SSOAToken alloc] initWithHTTPResponseBody:[aRequest responseString]];
		
		// Check for token error
		if (aToken == nil) {
			[self failWithErrorString:@"The access token could not be generated" code:-1];
			return;
		}
		
		self.accessToken = aToken;
		[aToken release];
		
		// Get user dictionary
		[self requestUser];
	}
}

@end
