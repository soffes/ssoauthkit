//
//  TwitterDemoViewController.h
//  TwitterDemo
//
//  Created by Sam Soffes on 7/16/10.
//  Copyright Tasteful Works 2010. All rights reserved.
//

#import "TWTwitterOAuthViewController.h"

@interface TwitterDemoViewController : UIViewController <TWTwitterOAuthViewControllerDelegate> {

	UILabel *userLabel;
}

- (void)login:(id)sender;

@end

