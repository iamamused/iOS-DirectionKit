//
//  DKRouteView.m
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

#import "DKRouteView.h"

@implementation DKRouteView

-(id) initWithRoute:(DKRoute *)route map:(DKMapView *)map;
{
	if (self = [super initWithFrame:CGRectMake(0, 0, map.frame.size.width, map.frame.size.height)]) {

		// Make the route layer transparent.
		[self setBackgroundColor:[UIColor clearColor]];
		
		// Keep the map and route.
		_map = [map retain];
		_route = [route retain];
		
		[_map addSubview:self];
	}
	return self;
}

#pragma mark -
#pragma mark Map Interaction
- (void)zoomToRoute;
{
	if (_route == nil || _map == nil) return;
	
	// Calculate the extents of the trip points that were passed in, 
	// and zoom in to that area.
	CLLocationDegrees maxLat = -90;
	CLLocationDegrees maxLon = -180;
	CLLocationDegrees minLat = 90;
	CLLocationDegrees minLon = 180;
	
	for( DKLocation *loc in [_route polylineWithAccuracy:kDKRouteAccuracyOverview] ) {
		if(loc.latitude > maxLat) {
			maxLat = loc.latitude;
		}
		if(loc.latitude < minLat) {
			minLat = loc.latitude;
		}
		if(loc.longitude > maxLon) {
			maxLon = loc.longitude;
		}
		if(loc.longitude < minLon) {
			minLon = loc.longitude;
		}
	}
	
	MKCoordinateRegion region;
	region.center.latitude     = (maxLat + minLat) / 2;
	region.center.longitude    = (maxLon + minLon) / 2;
	region.span.latitudeDelta  = maxLat - minLat;
	region.span.longitudeDelta = maxLon - minLon;
	
	[_map setRegion:region animated:YES];
}

- (void)drawRect:(CGRect)rect
{
	// only draw our lines if we're not int he moddie of a transition and we 
	// acutally have some points to draw. 
	if(self.hidden || _route == nil) return; 
	
	CGContextRef context = UIGraphicsGetCurrentContext(); 
	
	UIColor *lineColor = [UIColor blueColor];
	
	CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
	CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 0.4);
	CGContextSetLineWidth(context, 3.0);
	
	BOOL start = YES;
	for(DKLocation *loc in [_route polylineWithAccuracy:kDKRouteAccuracyFine]) {
		
		// Get the screen coordinates for the point.
		CGPoint point = [_map convertCoordinate:(CLLocationCoordinate2D){loc.latitude,loc.longitude} toPointToView:self];
		if(start) {
			// Move to the first point.
			CGContextMoveToPoint(context, point.x, point.y);
			start = NO;
		} else {
			// Add a line ot the next point.
			CGContextAddLineToPoint(context, point.x, point.y);
		}
	}

	// Stroke it.
	CGContextStrokePath(context);
	
}

#pragma mark -
#pragma mark Memory Management

-(void) dealloc
{
	[_route release];
	[_map release];
	[super dealloc];
}

@end
