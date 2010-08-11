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
{}

- (void)viewDidLoad
{
	
	DKWaypoint *cn = [DKWaypoint waypointWithLatitude:43.643995f Longitude:-79.388237f]; // CN Tower
	[cn setTitle:@"Start @ CN Tower"];
	[cn setPinFillColor:[UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.75f]];
	[cn setPinStrokeColor:[UIColor colorWithRed:0.6f green:0.0f blue:0.0f alpha:1.0f]];
	[cn setDelegate:self];
	
	DKWaypoint *rom = [DKWaypoint waypointWithLatitude:43.668038f Longitude:-79.394948f]; // Royal Ontario Museum
	[rom setTitle:@"Royal Ontario Museum"];
	[rom setDelegate:self];

	DKWaypoint *fy = [DKWaypoint waypointWithLatitude:43.638451f Longitude:-79.405231f]; // Fort York
	[fy setTitle:@"Fort York"];
	[fy setDelegate:self];

	DKWaypoint *sc = [DKWaypoint waypointWithLatitude:43.716333f Longitude:-79.338734f]; // Science Center
	[sc setTitle:@"Ontario Science Center"];
	[sc setDelegate:self];

    [(MKMapView *)self.view setMapType:MKMapTypeStandard];
	[(DKMapView *)self.view loadDirectionsThroughWaypoints:[NSArray arrayWithObjects: cn, rom, fy, sc, nil] 
												travelMode:kDKTravelModeWalking];
	
}

- (void)viewDidUnload {
    self.detailViewController = nil;
}

- (void)dealloc {
    [detailViewController release];
	[super dealloc];
}


#pragma mark -
#pragma mark DKWaypointDelegate

- (void)waypointShowDetails:(DKWaypoint *)waypoint;
{
	
	if (self.detailViewController == nil) {
		DemoDetailViewController *detail = [[DemoDetailViewController alloc] initWithNibName:@"DemoDetailViewController" bundle:nil];
		[self setDetailViewController:detail];
		[detail release];
	}
	
	[self presentModalViewController:self.detailViewController animated:YES];
	
}

@end
