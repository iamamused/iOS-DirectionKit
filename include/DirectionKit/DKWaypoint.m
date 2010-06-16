//
//  DKWaypoint.m
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

#import "DKWaypoint.h"


@implementation DKWaypoint

@synthesize delegate;
@synthesize coordinate, position;
@synthesize title, subtitle;

+ (DKWaypoint *)waypointWithLatitude:(float)lat Longitude:(float)lng;
{
	DKWaypoint *wp = [[DKWaypoint alloc] init];	
	wp.coordinate = (CLLocationCoordinate2D){lat,lng};
	[wp autorelease];
	return wp;
}

- (UIView *)pinViewForMap:(DKMapView *)map; 
{
	// Try to dequeue an existing pin view first
	static NSString* WaypointAnnotationIdentifier = @"waypointAnnotationIdentifier";
	MKPinAnnotationView* pinView = (MKPinAnnotationView *)
	[map dequeueReusableAnnotationViewWithIdentifier:WaypointAnnotationIdentifier];
	
	if (!pinView) {
		
		// If an existing pin view was not available, create one
		MKAnnotationView* view = [[[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:WaypointAnnotationIdentifier] autorelease];

		//view.animatesDrop = YES;
		view.canShowCallout = YES;

		UIImage *img = [UIImage imageNamed:@"pin.png"];
		
		
		CGRect resizeRect;
		resizeRect.size = img.size;
		
		/*
		CGSize maxSize = CGRectInset(self.view.bounds,
									 [MapViewController annotationPadding],
									 [MapViewController annotationPadding]).size;
		maxSize.height -= self.navigationController.navigationBar.frame.size.height + [MapViewController calloutHeight];
		if (resizeRect.size.width > maxSize.width)
			resizeRect.size = CGSizeMake(maxSize.width, resizeRect.size.height / resizeRect.size.width * maxSize.width);
		if (resizeRect.size.height > maxSize.height)
			resizeRect.size = CGSizeMake(resizeRect.size.width / resizeRect.size.height * maxSize.height, maxSize.height);
		*/
		
		resizeRect.origin = (CGPoint){0.0f, 0.0f};
		
		UIGraphicsBeginImageContext(resizeRect.size);
		[img drawInRect:resizeRect];
		[[UIColor whiteColor] setFill];
		UIFont *font = [UIFont fontWithName:@"Helvetica" size:18.0f];
		NSString *pos = [NSString stringWithFormat:@"%d", position];
		[pos drawAtPoint:(CGPoint){resizeRect.size.width / 2,4.0f} forWidth:resizeRect.size.width withFont:font lineBreakMode:UILineBreakModeClip];
		UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		view.image = resizedImage;
		
		view.opaque = NO;
		
		
		if (delegate != nil) {
			
			// add a detail disclosure button to the callout which will open a new view controller page
            //
            // note: you can assign a specific call out accessory view, or as MKMapViewDelegate you can implement:
            //  - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
            //
			
			UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
			[rightButton addTarget:self
							action:@selector(showDetails:)
				  forControlEvents:UIControlEventTouchUpInside];
			
			view.rightCalloutAccessoryView = rightButton;
		}
		
		return view;
		
	} else {
		pinView.annotation = self;
	}
	
	return pinView;
}

- (void)showDetails:(id)sender;
{	
	if (delegate) {
		[delegate waypointShowDetails:self];
	}
}

@end
