//
//  DKWaypointControl.m
//  DirectionKit
//
//  Created by Jeffrey Sambells on 10-06-16.
//  Copyright 2010 We-Create Inc. All rights reserved.
//

#import "DKWaypointControl.h"

@interface DKWaypointControl ()
- (void)_triggerHide;
@end


@implementation DKWaypointControl

- (id)initWithRoute:(DKRoute *)route map:(DKMapView *)map;
{
	
	if (self = [super init]) {

		_map = [map retain];
		
		self.frame = CGRectMake(map.frame.origin.x, map.frame.origin.y + map.frame.size.height - 60, map.frame.size.width, 48);
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
		self.alpha = 0.0f;
		
		NSMutableArray *items = [NSMutableArray arrayWithCapacity:[route.waypoints count]];
		[items addObject:@"Start (S)"];
		for (int i = 1; i < [route.waypoints count]; i++) {
			//http://stackoverflow.com/questions/2832729/how-to-convert-ascii-value-to-a-character-in-objective-c
			[items addObject:[NSString stringWithFormat:@"%c", 64+i]];
		}

		_control = [[UISegmentedControl alloc] initWithItems:items];
		_control.frame = CGRectMake(10, 10, self.frame.size.width - 20, 30);
		_control.segmentedControlStyle = UISegmentedControlStyleBar;
		_control.selectedSegmentIndex = UISegmentedControlNoSegment;
		_control.tintColor = [UIColor blueColor];
		_control.momentary = YES;
		
		[_control addTarget:self
					 action:@selector(valueChanged:)
			forControlEvents:UIControlEventValueChanged];
		
		[self addSubview:_control];		
		
	}
	
	return self;
	
}


- (void)showInterface;
{
	if (self.alpha != 1.0f) {

		[[_map superview] addSubview:self];
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5f];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDidStopSelector:@selector(_triggerHide)];
		self.alpha = 1.0f;
		[UIView commitAnimations];
		
	} else {
		[self _triggerHide];
	}
}

- (void)hideInterface;
{
	if (self.alpha != 0.0f) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5f];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDidStopSelector:@selector(_removeControl)];
		self.alpha = 0.0f;
		[UIView commitAnimations];
	}
	
}

- (void)_triggerHide;
{
	[DKWaypointControl cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideInterface) object:nil];
	[self performSelector:@selector(hideInterface) withObject:nil afterDelay: 4.45];
}

- (void)_removeControl;
{
	[self removeFromSuperview];
}


- (void)valueChanged:(id)sender {
	[_map centerOnWaypointIndex:_control.selectedSegmentIndex];
}


- (void)drawRect:(CGRect)rect;
{

	CGContextRef myContext = UIGraphicsGetCurrentContext();
	
    CGSize          myShadowOffset = CGSizeMake (0, 5);
    float           myColorValues[] = {0, 0, 0, .85};
    CGColorSpaceRef myColorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef      myColor = CGColorCreate (myColorSpace, myColorValues);
	
    CGContextSaveGState(myContext);
    CGContextSetShadow (myContext, myShadowOffset, 10);

    CGContextSetRGBFillColor (myContext, 1, 1, 1, 1);
	
	CGRect rrect = CGRectInset(rect, 10, 10);
	
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
	
	float radius = 7.0f;
	CGContextMoveToPoint(myContext, minx, midy);
	CGContextAddArcToPoint(myContext, minx, miny, midx, miny, radius);
	CGContextAddArcToPoint(myContext, maxx, miny, maxx, midy, radius);
	CGContextAddArcToPoint(myContext, maxx, maxy, midx , maxy, radius);
	CGContextAddArcToPoint(myContext, minx, maxy, minx, midy, radius);
	CGContextClosePath(myContext);
	CGContextDrawPath(myContext, kCGPathFill);
	
    CGColorRelease (myColor);
    CGColorSpaceRelease (myColorSpace);
	
    CGContextRestoreGState(myContext);

}

- (void)dealloc {
	[_control release];
	[_map release];
	[super dealloc];
}

@end
