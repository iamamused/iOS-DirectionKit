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

int kDKWaypointPinCornerRadius = 5.0f;

int kDKWaypointPinBottomPadding = 5;
int kDKWaypointPinSidePadding = 5;
int kDKWaypointPinTopPadding = 5;

int kDKWaypointPinLabelPadding = 10;
int kDKWaypointPinLabelHeight = 10;

int kDKWaypointPinDescenderHeight = 9;
int kDKWaypointPinDescenderWidth = 12;


@interface DKWaypoint (PrivateMethods)
- (UIImage *)pinWithRect:(CGRect)rect label:(NSString *)label;
@end
	
@implementation DKWaypoint


@synthesize delegate;
@synthesize coordinate, position;
@synthesize title, subtitle;
@synthesize hideDetails;

@synthesize info;

+ (DKWaypoint *)waypointWithLatitude:(float)lat Longitude:(float)lng;
{
	DKWaypoint *wp = [[DKWaypoint alloc] init];	
	wp.coordinate = (CLLocationCoordinate2D){lat,lng};
	[wp autorelease];
	return wp;
}

- (MKAnnotationView *)pinViewForMap:(DKMapView *)map; 
{
	// Try to dequeue an existing pin view first
	static NSString* WaypointAnnotationIdentifier = @"waypointAnnotationIdentifier";
	MKAnnotationView* pinView = (MKAnnotationView *)
	[map dequeueReusableAnnotationViewWithIdentifier:WaypointAnnotationIdentifier];
	
	if (!pinView) {
		// If an existing pin view was not available, create one
		pinView = [[[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:WaypointAnnotationIdentifier] autorelease];
	} 
	
	//view.animatesDrop = YES;
	pinView.canShowCallout = YES;
	NSString *pinLabel;
	if (position == 1) {
		pinLabel= @"S";
	} else {
		pinLabel= [NSString stringWithFormat:@"%c", 63 + position];
	}
	pinView.image = [self pinWithRect:CGRectMake(0, 0, 36, 44) label:pinLabel];
	pinView.centerOffset = CGPointMake(0, -22);
	pinView.opaque = NO;
	
	pinView.annotation = self;

	if (delegate != nil && hideDetails != YES) {		
		UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[rightButton addTarget:self
						action:@selector(showDetails:)
			  forControlEvents:UIControlEventTouchUpInside];
		
		pinView.rightCalloutAccessoryView = rightButton;
	} else {
		pinView.rightCalloutAccessoryView = nil;
	}
	
	return pinView;
}

- (void)showDetails:(id)sender;
{	
	if (delegate && !hideDetails) {
		[delegate waypointShowDetails:self];
	}
}

- (UIImage *)pinWithRect:(CGRect)rect label:(NSString *)label;
{	
	
	CGFloat decenderHeight = kDKWaypointPinDescenderHeight;
	CGFloat decenderWidth = kDKWaypointPinDescenderWidth;
	
	CGRect rrect = CGRectMake(rect.origin.x + kDKWaypointPinSidePadding, 
							  rect.origin.y + kDKWaypointPinTopPadding, 
							  rect.size.width - kDKWaypointPinSidePadding - kDKWaypointPinSidePadding,
							  rect.size.height - kDKWaypointPinTopPadding - kDKWaypointPinBottomPadding - decenderHeight);
	
	
	UIGraphicsBeginImageContext(rect.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	// Drawing with a white stroke color
	CGContextSetRGBStrokeColor(context, 0, 0, 0, 1.0);
	// And draw with a translucent fill color
	CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.75);
	
	
	CGFloat radius = kDKWaypointPinCornerRadius;
	// NOTE: At this point you may want to verify that your radius is no more than half
	// the width and height of your rectangle, as this technique degenerates for those cases.
	
	// In order to draw a rounded rectangle, we will take advantage of the fact that
	// CGContextAddArcToPoint will draw straight lines past the start and end of the arc
	// in order to create the path from the current position and the destination position.
	
	// In order to create the 4 arcs correctly, we need to know the min, mid and max positions
	// on the x and y lengths of the given rectangle.
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
	
	// Next, we will go around the rectangle in the order given by the figure below.
	//       minx    midx    maxx
	// miny    2       3       4
	// midy   1 9              5
	// maxy    8       7       6
	// Which gives us a coincident start and end point, which is incidental to this technique, but still doesn't
	// form a closed path, so we still need to close the path to connect the ends correctly.
	// Thus we start by moving to point 1, then adding arcs through each pair of points that follows.
	// You could use a similar tecgnique to create any shape with rounded corners.
	
	CGContextSetLineWidth(context, 1);
	
	// Start at 1
	CGContextMoveToPoint(context, minx, midy);
	// Add an arc through 2 to 3
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	// Add an arc through 4 to 5
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	// Add an arc through 6 to 7
	CGContextAddArcToPoint(context, maxx, maxy, midx , maxy, radius);
	
	// Add in the tail
	CGContextAddLineToPoint(context, midx + (decenderWidth / 2), maxy );
	CGContextAddLineToPoint(context, midx, maxy + decenderHeight);
	CGContextAddLineToPoint(context, midx - (decenderWidth / 2) , maxy);
	
	// Add an arc through 8 to 9
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	// Close the path
	CGContextClosePath(context);
	// Fill & stroke the path
	CGContextDrawPath(context, kCGPathFillStroke);
	
	
	[[UIColor whiteColor] setFill];
	UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0f];
	[label drawAtPoint:(CGPoint){(rect.size.width/2) - 6.0f,8.0f} forWidth:rect.size.width withFont:font lineBreakMode:UILineBreakModeClip];
	
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();  
	
	CGContextRestoreGState(context);	
	UIGraphicsEndImageContext();
	
	
	return image; 
}


@end
