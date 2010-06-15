//
//  DemoViewController.m
//  DirectionKit
//
//  Created by Jeffrey Sambells on 10-06-14.
//  Copyright 2010 TropicalPixels. All rights reserved.
//

#import "DemoViewController.h"
#import <DirectionKit/DirectionKit.h>

@implementation DemoViewController

@synthesize detailViewController;


- (void)loadView {
	UIScreen *screen = [UIScreen mainScreen];
	self.view = [[DKMapView alloc] initWithFrame:[screen bounds]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:NO animated:NO];
}

- (void)viewDidLoad
{
    [(MKMapView *)self.view setMapType:MKMapTypeStandard];
	[(DKMapView *)self.view loadDirectionsThroughWaypoints:[NSArray arrayWithObjects:
											[DKWaypoint waypointWithLatitude:43.643995f Longitude:-79.388237f], // CN Tower
											[DKWaypoint waypointWithLatitude:43.668038f Longitude:-79.394948f], // Royal Ontario Museum
											[DKWaypoint waypointWithLatitude:43.638451f Longitude:-79.405231f], // Fort York
											[DKWaypoint waypointWithLatitude:43.716333f Longitude:-79.338734f], // Science Center
											nil]];
}

- (void)viewDidUnload {
    self.detailViewController = nil;
}

- (void)dealloc {
    [detailViewController release];
	[super dealloc];
}



- (void)showDetails:(id)sender
{
    // the detail view does not want a toolbar so hide it
    [self.navigationController setToolbarHidden:YES animated:NO];
    [self.navigationController pushViewController:self.detailViewController animated:YES];
}

@end
