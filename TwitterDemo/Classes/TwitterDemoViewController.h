//
//  TwitterDemoViewController.h
//  TwitterDemo
//
//  Created by Sam Soffes on 7/16/10.
//  Copyright Sam Soffes 2010-2011. All rights reserved.
//

#import "SSTwitterAuthViewControllerDelegate.h"

@interface TwitterDemoViewController : UIViewController <SSTwitterAuthViewControllerDelegate> {

@private
	
	UILabel *_userLabel;
}

- (void)loginWithOAuth:(id)sender;
- (void)loginWithXAuth:(id)sender;

@end

