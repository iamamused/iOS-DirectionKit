//
//  DKMap.m
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

#import "DKMapView.h"

@interface DKMapView (PrivateMethods)
@end

@implementation DKMapView

- (void)awakeFromNib;
{
	//self.multipleTouchEnabled = YES;
	self.showsUserLocation = YES;
	[self setDelegate:self];
}

- (id)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
    	//self.multipleTouchEnabled = YES;
		self.showsUserLocation = YES;
		[self setDelegate:self];
	}
    return self;
}


#pragma mark -
#pragma mark Load Directions

- (void)loadDirectionsThroughWaypoints:(NSArray *)waypoints;
{
	[directions release];
	directions = [[DKGoogleDirections alloc] initWithDelegate:self];
	[directions loadDirectionsThroughWaypoints:waypoints];
}

#pragma mark -
#pragma mark DKDirectionsDelegate

- (void)didFinishWithRoutes:(NSArray *)newRoutes;
{
	[routes release];
	routes = nil;
	
	if (newRoutes == nil) return;
	
	routes = [newRoutes retain];
	if ([routes count] > 0) {
		[self showRoute:[routes objectAtIndex:0]];
	}
}


#pragma mark -
#pragma mark Routing

- (void)hideRoute {
	[self removeOverlay:routePoly];
	[self removeAnnotations:self.annotations];
}

- (void)showRoute:(DKRoute *)route {
	if (routePoly != nil) {
		[self removeOverlay:routePoly];
		[self removeAnnotations:self.annotations];
	}
	routePoly = [[route polylineWithAccuracy:kDKRouteAccuracyFine] retain];
	[self addOverlay:routePoly];
	
	NSArray *waypoints = [route waypoints];

	[self addAnnotations:waypoints];
	
	[self zoomToWaypoints:waypoints];
	
	if (routeControl != nil) {
		[routeControl removeFromSuperview];
		[routeControl release];
		routeControl = nil;
	}
	routeControl = [[DKWaypointControl alloc] initWithRoute:route map:self];
	
	
}

#pragma mark -
#pragma mark Map Interaction

- (void)centerOnWaypointIndex:(int)index;
{
	NSArray *waypoints = [[routes objectAtIndex:0] waypoints];
	[self centerOnWaypoint:[waypoints objectAtIndex:index]];
}

- (void)centerOnWaypoint:(DKWaypoint *)waypoint;
{
	[self setCenterCoordinate:waypoint.coordinate animated:YES];
	
	[self selectAnnotation:waypoint animated:YES];
}

- (void)zoomToWaypoints:(NSArray *)waypoints;
{
	
	// Calculate the extents of the trip points that were passed in, 
	// and zoom in to that area.
	CLLocationDegrees maxLat = -90;
	CLLocationDegrees maxLon = -180;
	CLLocationDegrees minLat = 90;
	CLLocationDegrees minLon = 180;
	
	for( DKWaypoint *wp in waypoints ) {
		if(wp.coordinate.latitude > maxLat) {
			maxLat = wp.coordinate.latitude;
		}
		if(wp.coordinate.latitude < minLat) {
			minLat = wp.coordinate.latitude;
		}
		if(wp.coordinate.longitude > maxLon) {
			maxLon = wp.coordinate.longitude;
		}
		if(wp.coordinate.longitude < minLon) {
			minLon = wp.coordinate.longitude;
		}
	}
	
	MKCoordinateRegion region;
	region.center.latitude     = (maxLat + minLat) / 2;
	region.center.longitude    = (maxLon + minLon) / 2;
	region.span.latitudeDelta  = maxLat - minLat;
	region.span.longitudeDelta = maxLon - minLon;
	
	[self setRegion:region animated:YES];
}

#pragma mark -
#pragma mark Map Delegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated;
{}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated;
{}
- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView;
{ }
- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView;
{ }
- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error;
{ }

#pragma mark -
#pragma mark MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
	// TODO move this to the route object and make in an overlay protocol
    MKPolylineView *plv = [[[MKPolylineView alloc] initWithOverlay:overlay] autorelease];
    plv.strokeColor = [UIColor blueColor];
    plv.lineWidth = 3.0;
	plv.alpha = 0.8f;
    return plv;
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
	}
    
    if ([annotation isKindOfClass:[DKWaypoint class]]) {
		return [(DKWaypoint *)annotation pinViewForMap:self];
    }
	
    return nil;
}

#pragma mark -
#pragma mark Touch Interaction

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	[routeControl showInterface];
	return [super hitTest:point withEvent:event];
}

/*
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent*)event
{
	[routeControl showInterface];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    [map touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    [super touchesEnded:touches withEvent:event];
}
*/

- (void)dealloc {
	[directions release];
	[routes release];
	[routePoly release];
	[super dealloc];
}
				  
@end
