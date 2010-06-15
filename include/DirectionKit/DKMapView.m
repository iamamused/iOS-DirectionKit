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


@implementation DKMapView

- (void)awakeFromNib;
{
	//self.multipleTouchEnabled = true;
	[self setDelegate:self];
}

- (id)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
    	self.multipleTouchEnabled = true;
		[self setDelegate:self];
	}
    return self;
}



#pragma mark -
#pragma mark Load Directions

- (void)loadDirectionsThroughWaypoints:(NSArray *)waypoints;
{
	directions = [[DKGoogleDirections alloc] initWithDelegate:self];
	[directions loadDirectionsThroughWaypoints:waypoints];
}

#pragma mark -
#pragma mark DKDirectionsDelegate

- (void)didFinishWithRoutes:(NSArray *)newRoutes;
{
	routes = [newRoutes retain];
	[self showRoute:[routes objectAtIndex:0]];
}


#pragma mark -
#pragma mark Routing

- (void)showRoute:(DKRoute *)route {

	if (routeView != nil) {
		[routeView removeFromSuperview];
		[routeView release];
		routeView = nil;
		[self removeAnnotations:self.annotations];
	}
	routeView = [[DKRouteView alloc] initWithRoute:route map:self];
	[routeView zoomToRoute];
	
	[self addAnnotations:[route waypoints]];
	
}

#pragma mark -
#pragma mark Map Delegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated;
{
	// turn off the view of the route as the map is chaning regions. This prevents
	// the line from being displayed at an incorrect positoin on the map during the
	// transition. 
	routeView.hidden = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated;
{
	// re-enable and re-poosition the route display. 
	routeView.hidden = NO;
	[routeView setNeedsDisplay];
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView;
{ }
- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView;
{ }
- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error;
{ }

#pragma mark -
#pragma mark MKMapViewDelegate

- (void)showDetails:(id)sender
{
	//TODO call our DK delegate...
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
	}
    
    if ([annotation isKindOfClass:[DKWaypoint class]]) {

		// Try to dequeue an existing pin view first
        static NSString* WaypointAnnotationIdentifier = @"waypointAnnotationIdentifier";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)
		[self dequeueReusableAnnotationViewWithIdentifier:WaypointAnnotationIdentifier];
        
		if (!pinView) {
			
            // If an existing pin view was not available, create one
            MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]
												   initWithAnnotation:annotation reuseIdentifier:WaypointAnnotationIdentifier] autorelease];
            customPinView.pinColor = MKPinAnnotationColorRed;
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            
			UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            
			[rightButton addTarget:self
                            action:@selector(showDetails:)
                  forControlEvents:UIControlEventTouchUpInside];
            
			customPinView.rightCalloutAccessoryView = rightButton;
            
			return customPinView;
			
        } else {
            pinView.annotation = annotation;
        }
		
        return pinView;
    }
	
    return nil;
}

#pragma mark -
#pragma mark Touch Interaction

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	return [super hitTest:point withEvent:event];
	
    //map = [super hitTest:point withEvent:event];
    //return self;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    //NSLog(@"%s", __FUNCTION__);
    //[map touchesCancelled:touches withEvent:event];
	[super touchesCancelled:touches withEvent:event];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent*)event
{
	[routeView setNeedsDisplay];
    //NSLog(@"%s", __FUNCTION__);
    //[map touchesBegan:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
	[routeView setNeedsDisplay];
    //NSLog(@"%s", __FUNCTION__);
    [map touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	[routeView setNeedsDisplay];
    //NSLog(@"%s", __FUNCTION__);
    //[map touchesEnded:touches withEvent:event];
    [super touchesEnded:touches withEvent:event];
}
				  
- (void)dealloc {
	[directions release];
	[routes release];
	[routeView release];
	[super dealloc];
}
				  
@end
