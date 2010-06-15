//
//  DKGoogleDirections.m
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

#import <DirectionKit/DirectionKit.h>
#import "CJSONDeserializer.h"

@implementation DKGoogleDirections

- (id)initWithDelegate:(id<DKDirectionsDelegate>)delegate;
{
	if (self = [super init]) {
		dirDelegate = delegate;
	}
	return self;
}

- (void)loadDirectionsThroughWaypoints:(NSArray *)waypoints;
{
	
	_wp = [waypoints retain];
	
	DKWaypoint *o = [waypoints objectAtIndex:0];
	DKWaypoint *d = [waypoints lastObject];
	
	NSString *origin = [NSString stringWithFormat:@"%f,%f", o.coordinate.latitude, o.coordinate.longitude ];
	NSString *desitnation = [NSString stringWithFormat:@"%f,%f", d.coordinate.latitude, d.coordinate.longitude ];

	NSString *waypointList = @"";
	
	if ([waypoints count] > 2) {
		
		DKWaypoint *wp = [waypoints objectAtIndex:1];
		waypointList = [NSString stringWithFormat:@"%f,%f",wp.coordinate.latitude, wp.coordinate.longitude];
		for (int i = 2; i < [waypoints count] - 1; i++) {
			wp = [waypoints objectAtIndex:i];
			waypointList = [NSString stringWithFormat:@"%@|%f,%f",waypointList,wp.coordinate.latitude, wp.coordinate.longitude];
		}
	}
	
	NSString *assembled = [NSString stringWithFormat:
						   @"%@?origin=%@&destination=%@&waypoints=%@&sensor=false",
						   @"http://maps.google.com/maps/api/directions/json",
						   [origin stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
						   [desitnation stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
						   waypointList];
	
	
	NSString *escapedURL = [assembled stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	NSURL *url = [NSURL URLWithString:escapedURL];
	[self doRegistration:url];
}

#pragma mark -
#pragma mark Data loading

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	//label.text = [NSString stringWithFormat:@"Connection failed: %@", [error description]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[connection release];
	
	NSString *jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	[responseData release];
	
	NSData *jsonData = [jsonString dataUsingEncoding:NSUTF32BigEndianStringEncoding];
	NSError *error = nil;
	NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
	
	
	NSMutableArray *routes = [NSMutableArray array];
	
	if ([[dictionary objectForKey:@"status"] isEqualToString:@"OK"]) {
		NSArray *dkRoutes = [dictionary objectForKey:@"routes"];
		for (NSDictionary *routeDict in dkRoutes) {
			DKRoute *route = [[DKRoute alloc] initWithDict:routeDict];
			[routes addObject:route];
			[route release];
		}
	}
	
	[dirDelegate didFinishWithRoutes:routes];
	[_wp release];
	
}


#pragma mark -
#pragma mark TouchXML Parsing

-(void) doRegistration:(NSURL *)url {
		
	NSLog(@"Google Directions API: %@", url);
	//NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	responseData = [[NSMutableData data] retain];
	[[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:url] delegate:self];
	
	//[pool release];
	//return;
	
}

- (void)dealloc {
	[super dealloc];
}
@end
