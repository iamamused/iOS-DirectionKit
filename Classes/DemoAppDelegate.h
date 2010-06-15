//
//  DemoAppDelegate.h
//  DirectionKit
//
//  Created by Jeffrey Sambells on 10-06-14.
//  Copyright 2010 TropicalPixels. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DemoViewController;

@interface DemoAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    DemoViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet DemoViewController *viewController;

@end

