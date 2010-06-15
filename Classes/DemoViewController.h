//
//  DemoViewController.h
//  DirectionKit
//
//  Created by Jeffrey Sambells on 10-06-14.
//  Copyright 2010 TropicalPixels. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DirectionKit/DirectionKit.h>

@class DKWaypointDetailViewController;

@interface DemoViewController : UIViewController <MKMapViewDelegate>
{
    DKWaypointDetailViewController *detailViewController;
}

@property (nonatomic, retain) DKWaypointDetailViewController *detailViewController;

@end

