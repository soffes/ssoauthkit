//
//  TwitterDemoViewController.h
//  TwitterDemo
//
//  Created by Sam Soffes on 7/16/10.
//  Copyright Sam Soffes 2010-2011. All rights reserved.
//

#import "SSTwitterOAuthViewController.h"

@interface TwitterDemoViewController : UIViewController <SSTwitterOAuthViewControllerDelegate> {

	UILabel *_userLabel;
}

- (void)login:(id)sender;

@end

