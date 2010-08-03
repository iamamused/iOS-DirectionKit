//
//  DKMapViewInfoWindow.m
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

#import "DKCalloutView.h"
#import "DKMapView.h"
#import "DKWaypointView.h";
#import <QuartzCore/QuartzCore.h>

int kInfoWindowBottomPadding = 10;
int kInfoWindowSidePadding = 7;
int kInfoWindowTopPadding = 3;
int kInfoWindowLabelPadding = 10;
int kInfoWindowLabelHeight = 10;
int kInfoWindowDescenderHeight = 14;

@implementation DKCalloutView

@synthesize marker = _marker;

- (void)dealloc {
	[_label release];
	[_map release];
	[_marker release];
    [super dealloc];
}

- (id)initWithMarker:(DKWaypointView *)marker {
	_marker = [marker retain];
	_map = [_marker.controller retain];
	return [self initWithContent:marker.label anchor:[marker infoWindowAnchorPoint]];
}

- (id)initWithMarker:(DKWaypointView *)marker map:(DKMapView *)map {
	_marker = [marker retain];
	_map = [map retain];
	return [self initWithContent:marker.label anchor:[marker infoWindowAnchorPoint]];
}


- (id)initWithContent:(NSString *)content anchor:(CGPoint)anchor {
	if( self = [super initWithFrame:CGRectZero]) {
		//self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter; 
		//self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter; 
		[self setBackgroundColor:[UIColor clearColor]];
		[self setTitle:_marker.label];
		//[self addTarget:self action:@selector(showInfo)]; 
		
		CGRect screenBounds = [[UIScreen mainScreen] bounds];
		CGRect bounds = CGRectMake(-screenBounds.size.width,
								   -screenBounds.size.height,
								   screenBounds.size.width *3, 
								   screenBounds.size.height *3);
		[self setAnchorPoint:anchor 
				boundaryRect:bounds
					 animate:YES]; 
		
	}
	return self;
}

- (void)showInfo {
}

- (void)updatePosition {
	if ( _marker != nil ) {
		CGPoint anchor = [_marker infoWindowAnchorPoint];
		CGRect screenBounds = [[UIScreen mainScreen] bounds];
		CGRect bounds = CGRectMake(-screenBounds.size.width,
								   -screenBounds.size.height,
								   screenBounds.size.width *3, 
								   screenBounds.size.height *3);
		if( CGRectContainsPoint(bounds, anchor)) {
		[self setAnchorPoint:[_marker infoWindowAnchorPoint] 
				boundaryRect: bounds
					 animate:NO]; 
		} 
		//else if( _marker.controller != nil ) {
		//	[_marker.controller closeInfoWindow];
		//}
		
		[self setNeedsDisplay];
	}
}

#pragma mark Methods that could be removed after UICalloutView is available.

- (void)drawRect:(CGRect)rect {

	[super drawRect:rect];
	
	CGFloat decenderHeight = kInfoWindowDescenderHeight;
	CGFloat decenderWidth = 28;
	
	CGRect rrect = CGRectMake(self.bounds.origin.x + kInfoWindowSidePadding, 
							  self.bounds.origin.y + kInfoWindowTopPadding, 
							  self.bounds.size.width - kInfoWindowSidePadding - kInfoWindowSidePadding + 5,
							  self.bounds.size.height - kInfoWindowTopPadding - kInfoWindowBottomPadding - decenderHeight);
	
	CGFloat descenderOffset = (rrect.size.width / 2) + 3 ;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Drawing with a white stroke color
	CGContextSetRGBStrokeColor(context, 0, 0, 0, 1.0);
	// And draw with a translucent fill color
	CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.75);
	
	
	CGFloat radius = 5.0;
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
	CGContextAddLineToPoint(context, descenderOffset + (decenderWidth / 2), maxy );
	CGContextAddLineToPoint(context, descenderOffset, maxy + decenderHeight);
	CGContextAddLineToPoint(context, descenderOffset - (decenderWidth / 2) , maxy);
	
	// Add an arc through 8 to 9
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	// Close the path
	CGContextClosePath(context);
	// Fill & stroke the path
	CGContextDrawPath(context, kCGPathFillStroke);
	
	
	// Line cap round
	//CGContextSetLineCap(context, kCGLineCapRound);
	//CGContextMoveToPoint(context, 40.0, 65.0);
	//CGContextAddLineToPoint(context, 280.0, 65.0);
	//CGContextStrokePath(context);
	
}

- (void)setTitle:(id)title {
	[_label removeFromSuperview];
	
	_label = [[UILabel alloc] initWithFrame:CGRectZero];
	_label.text = title;
	_label.font = [UIFont boldSystemFontOfSize:16];
	_label.textColor = [UIColor whiteColor];
	_label.backgroundColor = [UIColor clearColor];
	[self addSubview:_label];
	
	CGSize size = [title sizeWithFont:_label.font constrainedToSize:CGSizeMake(200.0, 100.0)];
	_label.frame = CGRectMake(
							  0,
							  0,
							  size.width + kInfoWindowLabelPadding + kInfoWindowLabelPadding,
							  kInfoWindowLabelHeight + kInfoWindowLabelPadding + kInfoWindowLabelPadding );
	_label.center = CGPointMake(
								(size.width / 2) + kInfoWindowSidePadding + kInfoWindowLabelPadding + kInfoWindowLabelPadding,
								(kInfoWindowLabelHeight /2) + kInfoWindowLabelPadding + kInfoWindowTopPadding );
	self.frame = CGRectMake(
							self.frame.origin.x,
							self.frame.origin.y,
							size.width + kInfoWindowSidePadding + kInfoWindowSidePadding + kInfoWindowLabelPadding + kInfoWindowLabelPadding,
							kInfoWindowLabelHeight + kInfoWindowLabelPadding + kInfoWindowLabelPadding + kInfoWindowTopPadding + kInfoWindowBottomPadding + kInfoWindowDescenderHeight);
	
	
}

- (id)title {
	return _label.text;
}

- (void)setAnchorPoint:(struct CGPoint)point boundaryRect:(struct CGRect)boundary animate:(BOOL)animated;
{
	self.frame = CGRectMake(
							point.x - (self.frame.size.width/2),
							point.y - (self.frame.size.height) + 14,
							self.frame.size.width,
							self.frame.size.height);
	
}

- (void)fadeOutWithDuration:(float)duration;
{
	[self removeFromSuperview];
}

@end
