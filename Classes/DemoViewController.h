//
//  DemoViewController.h
//  DirectionKit
//
//  Created by Jeffrey Sambells on 10-06-14.
//  Copyright 2010 TropicalPixels. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DirectionKit/DirectionKit.h>
#import "DemoDetailViewController.h"

@interface DemoViewController : UIViewController <DKWaypointDelegate>
{
    DemoDetailViewController *detailViewController;
}

@property (nonatomic, retain) DemoDetailViewController *detailViewController;

@end

