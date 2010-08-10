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

#import "DirectionKit.h"
#import "CJSONDeserializer.h"

@interface DKGoogleDirections (PrivateMethods)
-(void) doRegistration:(NSURL *)url;
@end

@implementation DKGoogleDirections

- (id)initWithDelegate:(id<DKDirectionsDelegate>)delegate;
{
	if (self = [super init]) {
		_cancelled = NO;
		dirDelegate = delegate;
	}
	return self;
}

- (void)loadDirectionsThroughWaypoints:(NSArray *)waypoints travelMode:(kDKTravelMode)travelMode;
{
	
	[dirDelegate didStartWithWaypoints:waypoints];

	// position the waypoints.
	int pos = 0;
	for (DKWaypoint *wp in waypoints) {
		[wp setPosition:++pos];
	}
	
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
	
	NSString *mode;
	
	switch (travelMode) {
		default:
		case kDKTravelModeDriving:
			mode = @"driving";
			break;
		case kDKTravelModeWalking:
			mode = @"walking";
			break;
		case kDKTravelModeBicycling:
			mode = @"bicycling";
			break;
	}
	
	NSString *assembled = [NSString stringWithFormat:
						   @"%@?mode=%@&origin=%@&destination=%@&waypoints=%@&sensor=false",
						   @"http://maps.google.com/maps/api/directions/json",
						   mode,
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
	_connection = nil;
	
	NSString *jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	[responseData release];
	
	NSData *jsonData = [jsonString dataUsingEncoding:NSUTF32BigEndianStringEncoding];
	[jsonString release];
	
	NSError *error = nil;
	NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
	
	
	NSMutableArray *routes = [NSMutableArray array];
	
	if ( !_cancelled && [[dictionary objectForKey:@"status"] isEqualToString:@"OK"]) {
		NSArray *dkRoutes = [dictionary objectForKey:@"routes"];
		for (NSDictionary *routeDict in dkRoutes) {
			DKRoute *route = [[DKRoute alloc] initWithDict:routeDict];
			[route setWaypoints:_wp];
			[routes addObject:route];
			[route release];
		}
	}
	
	if (!_cancelled) [dirDelegate didFinishWithRoutes:routes];
	
	[_wp release];
	
}


#pragma mark -
#pragma mark TouchXML Parsing

-(void) doRegistration:(NSURL *)url {
	
	if (_cancelled) return;
	
	NSLog(@"Google Directions API: %@", url);
	
	responseData = [[NSMutableData data] retain];
	_connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:url] delegate:self];
	
	
}

#pragma mark -
#pragma mark Cancelling
- (void)cancel;
{
	if (_connection != nil) {
		[_connection cancel];
	}
	_cancelled = YES;
}

- (void)dealloc {
	[responseData release];
	[_connection release];
	[super dealloc];
}
@end
