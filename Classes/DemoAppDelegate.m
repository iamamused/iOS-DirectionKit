//
//  DemoAppDelegate.m
//  DirectionKit
//
//  Created by Jeffrey Sambells on 10-06-14.
//  Copyright 2010 TropicalPixels. All rights reserved.
//

#import "DemoAppDelegate.h"
#import "DemoViewController.h"

@implementation DemoAppDelegate

@synthesize window;
@synthesize viewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch    
	
	// Add the split view controller's view to the window and display.
   [window addSubview:viewController.view];
   [window makeKeyAndVisible];
	
	return YES;
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
