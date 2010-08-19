//
//  TwitterDemoViewController.h
//  TwitterDemo
//
//  Created by Sam Soffes on 7/16/10.
//  Copyright Tasteful Works 2010. All rights reserved.
//

#import "SSTwitterOAuthViewController.h"

@interface TwitterDemoViewController : UIViewController <SSTwitterOAuthViewControllerDelegate> {

	UILabel *userLabel;
}

- (void)login:(id)sender;

@end

