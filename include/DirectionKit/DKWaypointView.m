//
//  DKMapViewMarker.m
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

#import <QuartzCore/QuartzCore.h>
#import "DKWaypointView.h"
#import "DKMapView.h";
#import "DKWaypointAccruacyIndicator.h"

@interface DKWaypointView (Private)
- (void)grow:(float)pause;
- (void)growEnd;
- (void)bounceEnd;
- (void)dropEnd;

- (void)_positionOnAnchor;
@end

@implementation DKWaypointView

@synthesize latlng, position = _position, label, controller, allowAnimation;

- (void)dealloc {
	[super dealloc];
}

- (UIImage *)iconImage {
	return [UIImage imageNamed:@"marker-1.png"]; // 20x34
}

- (CGPoint)infoWindowAnchorPoint {
	return CGPointMake(self.position.x + 2, self.position.y - 26);
}

- (CGPoint)anchorPoint {
	return CGPointMake(10.0f, 34.0f); // from top left
}

- (void)_positionOnAnchor {
	CGPoint anchorPoint = [self anchorPoint];
	
	self.frame = CGRectMake(
							_position.x - anchorPoint.x, 
							_position.y - anchorPoint.y, 
							_width, 
							_height);
}


+ (id)markerFromLatLng:(CLLocationCoordinate2D)latlng withAccuracy:(float)accuracy {
	DKWaypointView *marker = [[[self alloc] initWithFrame:CGRectZero] autorelease];
	marker.allowAnimation = YES;
	if (accuracy >= 0.0f) {
		marker.latlng = latlng;
		
		if (accuracy > 0.0f) {
			//DKMapViewMarkerAccruacy *accuracy = [[DKMapViewMarkerAccruacy alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 100.0f)];
			//[marker insertSubview:accuracy atIndex:0];
		}
	}
			
	
	return marker;
}


- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		// Initialization code
		
		
		UIImage *image = [self iconImage];
		_width = image.size.width;
		_height = image.size.height;
		
		UIImage *stretchable = [image stretchableImageWithLeftCapWidth:0 topCapHeight:0];
		
		
		UIButton *icon = [UIButton buttonWithType:UIButtonTypeCustom];
		[icon setFrame:CGRectMake(0.0f, 0.0f, _width, _height)];
		[icon setTag:0];
		[icon setImage:stretchable forState:UIControlStateNormal];
		[icon addTarget:self action:@selector(openInfoWindow) forControlEvents:UIControlEventTouchUpInside];
	
		[self addSubview:icon];
		
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;

	}
	
	return self;
}

- (void)setPosition:(MKMapPoint)position animated:(BOOL)animated delay:(float)delay {
	_position = position;
	
	if (allowAnimation && animated) {
		[self drop:(float)delay];
	} else {
		[self _positionOnAnchor];
	}
}

- (void)didMoveToSuperview {
	[super didMoveToSuperview];
    if (allowAnimation) [self drop:0.0f];
}

- (void)drawRect:(CGRect)rect {
	// Drawing code
}

- (void)openInfoWindow {
	[controller openInfoWindow:self];
}

- (float)sortIndex {
	return (float)latlng.latitude;
}

- (void)grow:(float)pause;
{
	
	////NSLog(@"Grow: %f", pause);
	
	self.frame = CGRectMake(_position.x, _position.y, 0, 0);
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelay:pause];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(growEnd)];
	self.frame = CGRectMake(_position.x, _position.y -40, _width + 5, _height + 5);
	[UIView commitAnimations];
	
}

- (void)growEnd {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	self.frame = CGRectMake(_position.x, _position.y -40, _width, _height);
	[UIView commitAnimations];
}

- (void)bounce:(float)pause;
{
	
	////NSLog(@"Bounce: %f", pause);
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelay:pause];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounceEnd)];
	[self _positionOnAnchor];
	[self setCenter:CGPointMake(self.center.x, self.center.y - 80)];
	[UIView commitAnimations];
	
}

- (void)bounceEnd {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[self _positionOnAnchor];
	[UIView commitAnimations];
}



- (void)drop:(float)pause;
{
	[self _positionOnAnchor];
	[self setCenter:CGPointMake(self.center.x, self.center.y - 120)];

	[self setAlpha:0.0f];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelay:pause];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(dropEnd)];
	[self _positionOnAnchor];
	[self setAlpha:1.0f];
	[UIView commitAnimations];
	
}

- (void)dropEnd {
}

@end
