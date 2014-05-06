//
//  TokenFieldExampleAppDelegate.m
//  TokenFieldExample
//
//  Created by Tom Irving on 29/01/2011.
//  Copyright 2011 Tom Irving. All rights reserved.
//

#import "TokenFieldExampleAppDelegate.h"
#import "TokenFieldExampleViewController.h"
#import "TokenTableExampleViewController.h"
@implementation TokenFieldExampleAppDelegate {
	UIWindow * _window;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	TokenTableExampleViewController * viewController = [[TokenTableExampleViewController alloc] init];
	UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    [tabBarController setViewControllers:@[navigationController]];
	
    [_window setRootViewController:tabBarController];
	
    [_window makeKeyAndVisible];
    
    return YES;
}


@end