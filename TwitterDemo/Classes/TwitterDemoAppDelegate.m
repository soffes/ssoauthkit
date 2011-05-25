//
//  TwitterDemoAppDelegate.m
//  TwitterDemo
//
//  Created by Sam Soffes on 7/16/10.
//  Copyright Sam Soffes 2010-2011. All rights reserved.
//

#import "TwitterDemoAppDelegate.h"
#import "TwitterDemoViewController.h"

@implementation TwitterDemoAppDelegate

@synthesize window = _window;

#pragma mark -
#pragma mark NSObject

- (void)dealloc {
    [_window release];
    [super dealloc];
}


#pragma mark -
#pragma mark UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	TwitterDemoViewController *viewController = [[TwitterDemoViewController alloc] init];
	_window.rootViewController = viewController;
	[viewController release];
	
    [_window makeKeyAndVisible];
	
	return YES;
}

@end
