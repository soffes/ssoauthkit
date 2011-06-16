//
//  SSTwitterXAuthViewController.h
//  SSOAuthKit
//
//  Created by Sam Soffes on 5/24/11.
//  Copyright 2011 Sam Soffes. All rights reserved.
//

#import "SSTwitterAuthViewController.h"

@interface SSTwitterXAuthViewController : SSTwitterAuthViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate> {

@private
	
	UITableView *_tableView;
	UITextField *_usernameTextField;
	UITextField *_passwordTextField;
}

@property (nonatomic, retain, readonly) UITextField *usernameTextField;
@property (nonatomic, retain, readonly) UITextField *passwordTextField;
@property (nonatomic, retain, readonly) UITableView *tableView;

- (void)signIn:(id)sender;

@end
