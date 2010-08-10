//
//  DKMap.h
//  DirectionKit
//
//  The MIT License
//
//  Copyright (c) 2010 Jeffrey Sambells, TropicalPixels
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "DirectionKit.h"

@class DKGoogleDirections;
@class DKWaypointControl;

// http://stackoverflow.com/questions/1121889/intercepting-hijacking-iphone-touch-events-for-mkmapview/1298330

@interface DKMapView : MKMapView <DKDirectionsDelegate, MKMapViewDelegate> {
	UIView *map;
	DKGoogleDirections *directions;
	MKPolyline *routePoly;
	DKWaypointControl *routeControl;
	NSArray *routes;
	
@private
	
}

- (void)loadDirectionsThroughWaypoints:(NSArray *)waypoints travelMode:(kDKTravelMode)travelMode;
- (void)centerOnWaypointIndex:(int)index;
- (void)centerOnWaypoint:(DKWaypoint *)waypoint;

- (void)removeRouteAndAnnotations;
- (void)showRoute:(DKRoute *)route;
- (void)zoomToWaypoints:(NSArray *)waypoints;

@end
