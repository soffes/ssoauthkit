//
//  TwitterDemoAppDelegate.h
//  TwitterDemo
//
//  Created by Sam Soffes on 7/16/10.
//  Copyright Tasteful Works 2010. All rights reserved.
//

@class TwitterDemoViewController;

@interface TwitterDemoAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TwitterDemoViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TwitterDemoViewController *viewController;

@end

