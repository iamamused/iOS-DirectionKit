//
//  DKRoute.m
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

#import "DKRoute.h"

@interface DKRoute (PrivateMethods)
- (NSArray *)_decodePoly:(NSString *)encoded;
@end

@implementation DKRoute

@synthesize summary;
@synthesize legs;
@synthesize waypointOrder;
@synthesize overviewPolyline;
@synthesize copyrights;
@synthesize warnings;

@synthesize waypoints;

- (id)init {
	if (self = [super init]) {
		self.legs = [[NSMutableArray array] retain];
	}
	return self;
}

- (id) initWithDict:(NSDictionary *)dict
{
	if (self = [self init]) {
		
		for (NSDictionary *leg in [dict objectForKey:@"legs"]) {
			DKLeg *dkleg = [[DKLeg alloc] initWithDict:leg];
			[self.legs addObject:dkleg];
			[dkleg release];
		}
		
		self.summary           = [dict objectForKey:@"summary"];
		self.waypointOrder     = [dict objectForKey:@"waypoint_order"];
		self.overviewPolyline  = [dict objectForKey:@"overview_polyline"];
		self.copyrights        = [dict objectForKey:@"copyrights"];
		self.warnings          = [dict objectForKey:@"warnings"];
	}
	return self;
}


#pragma mark -
#pragma mark Paths

- (MKPolyline *)polylineWithAccuracy:(kDKRouteAccuracy)accuracy;
{
	NSArray *poly;
	switch (accuracy) {
		default:
		case kDKRouteAccuracyOverview:
			poly = [self _decodePoly:[overviewPolyline objectForKey:@"points"]];
			break;
		case kDKRouteAccuracyFine:
			poly = [NSMutableArray array];
			for (DKLeg *leg in legs) {
				for (DKStep *step in leg.steps) {
					NSArray *decoded = [self _decodePoly:[step.polyline objectForKey:@"points"]];
					[(NSMutableArray *)poly addObjectsFromArray:decoded];
				}		
			}
			break;
	}
	
	
	CLLocationCoordinate2D polyPoints[[poly count]];
	int count = 0;
	for(DKLocation *loc in poly) {
		polyPoints[count++] = (CLLocationCoordinate2D){loc.latitude,loc.longitude};
	}
	
	return [MKPolyline polylineWithCoordinates:polyPoints count:[poly count]];

}

- (NSArray *)_decodePoly:(NSString *)encoded {
	
	NSMutableArray *poly = [NSMutableArray array];
	
	int index = 0, len = [encoded length];
	int lat = 0, lng = 0;
	
	while (index < len) {
		int b, shift = 0, result = 0;
		// Decode latitude
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		int r = (result & 1);
		int dlat = (r != 0 ? ~(result >> 1) : (result >> 1));
		lat += dlat;
		
		// Decode longitude
		shift = 0;
		result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
		lng += dlng;
		
		DKLocation *loc = [[DKLocation alloc] init];
		loc.latitude  = ((double) lat / 1E5);
		loc.longitude = ((double) lng / 1E5);
		[poly addObject:loc];
		[loc release];
	}
	
	return poly;
}

#pragma mark -
#pragma mark Waypoints

/*
- (NSArray *)waypoints;
{
	int position = 1;
	
	// Collect the start location from all the legs.
	NSMutableArray *wps = [NSMutableArray array];
	for (DKLeg *leg in legs) {
		DKWaypoint *wp = [DKWaypoint waypointWithLatitude:leg.startLocation.latitude Longitude:leg.startLocation.longitude];
		[wp setPosition:position++];
		[wps addObject:wp];
		
	}

	// Add the end location from the last leg.
	DKLeg *end = [legs lastObject];
	DKWaypoint *lastWp = [DKWaypoint waypointWithLatitude:end.endLocation.latitude Longitude:end.endLocation.longitude];
	[lastWp setPosition:position++];
	[wps addObject:lastWp];
	
	return wps;
}
*/

#pragma mark -
#pragma mark Memory

- (void)dealloc {
	[summary release];
	[legs release];
	[waypointOrder release];
	[overviewPolyline release];
	[copyrights release];
	[warnings release];
	[super dealloc];
}

@end
