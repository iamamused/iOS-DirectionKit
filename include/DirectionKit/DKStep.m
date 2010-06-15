//
//  DKStep.m
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

#import "DKStep.h"


@implementation DKStep

@synthesize instructions;
@synthesize distance;
@synthesize distanceInMeters;
@synthesize duration;
@synthesize durationInSeconds;
@synthesize startLocation;
@synthesize endLocation;
@synthesize polyline;

- (id)init {
	if (self = [super init]) {
	}
	return self;
}

- (id) initWithDict:(NSDictionary *)dict
{
	if (self = [self init]) {
		
		self.instructions  = [dict objectForKey:@"instructions"];

		NSDictionary *dist    = [dict objectForKey:@"distance"];
		self.distance         = [dist objectForKey:@"text"];
		self.distanceInMeters = [[dist objectForKey:@"value"] floatValue];
		
		NSDictionary *dur      = [dict objectForKey:@"duration"];
		self.duration          = [dur objectForKey:@"text"];
		self.durationInSeconds = [[dur objectForKey:@"value"] floatValue];
		
		NSDictionary *sl   = [dict objectForKey:@"start_location"];
		self.startLocation = (CLLocationCoordinate2D){[[sl objectForKey:@"lat"] doubleValue],[[sl objectForKey:@"lng"] doubleValue]};
		
		NSDictionary *el   = [dict objectForKey:@"end_location"];
		self.endLocation = (CLLocationCoordinate2D){[[el objectForKey:@"lat"] doubleValue],[[el objectForKey:@"lng"] doubleValue]};

		self.polyline = [dict objectForKey:@"polyline"];

	}
	return self;
}

- (void)dealloc {
	
	[instructions dealloc];
	[distance     dealloc];
	[duration     dealloc];
	
	[super dealloc];
}

@end
