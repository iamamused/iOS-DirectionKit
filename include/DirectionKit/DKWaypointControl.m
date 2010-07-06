//
//  DKWaypointControl.m
//  DirectionKit
//
//  Created by Jeffrey Sambells on 10-06-16.
//  Copyright 2010 We-Create Inc. All rights reserved.
//

#import "DKWaypointControl.h"


@implementation DKWaypointControl

- (id)initWithRoute:(DKRoute *)route map:(DKMapView *)map;
{
	
	
	if (self = [super init]) {

		_map = [map retain];
		

		self.frame = CGRectMake(map.frame.origin.x, map.frame.origin.y + map.frame.size.height - 60, map.frame.size.width, 48);
		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
		
		NSMutableArray *items = [NSMutableArray arrayWithCapacity:[route.waypoints count]];
		[items addObject:@"Start"];
		for (int i = 1; i < [route.waypoints count]; i++) {
			//http://stackoverflow.com/questions/2832729/how-to-convert-ascii-value-to-a-character-in-objective-c
			[items addObject:[NSString stringWithFormat:@"%c", 64+i]];
		}
		
		

		_control = [[UISegmentedControl alloc] initWithItems:items];
		_control.frame = CGRectMake(10, 10, self.frame.size.width - 20, 30);
		_control.segmentedControlStyle = UISegmentedControlStyleBar;
		_control.selectedSegmentIndex = 0;
		_control.tintColor = [UIColor blueColor];
				
		[_control addTarget:self
			action:@selector(valueChanged)
			forControlEvents:UIControlEventValueChanged];
		
		[self addSubview:_control];
		
		[[_map superview] addSubview:self];
		
	}
	
	return self;
	
}

- (void)valueChanged {
	[_map centerOnWaypointIndex:_control.selectedSegmentIndex];
}


- (void)drawRect:(CGRect)rect;
{

	CGContextRef myContext = UIGraphicsGetCurrentContext();
	
    CGSize          myShadowOffset = CGSizeMake (0, 5);
    float           myColorValues[] = {0, 0, 0, .85};
    CGColorSpaceRef myColorSpace = CGColorSpaceCreateDeviceRGB ();
    CGColorRef      myColor = CGColorCreate (myColorSpace, myColorValues);
	
    CGContextSaveGState(myContext);
    CGContextSetShadow (myContext, myShadowOffset, 10);

    CGContextSetRGBFillColor (myContext, 0, 1, 0, 1);
	
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
	
	//[super drawRect:rect];
}

- (void)dealloc {
	[_control release];
	[_map release];
	[super dealloc];
}

@end
