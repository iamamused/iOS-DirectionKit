//
//  DKRoute.h
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

typedef enum {
	kDKRouteAccuracyOverview,
	kDKRouteAccuracyFine
} kDKRouteAccuracy;

@interface DKRoute : NSObject {
	NSString       *summary;
	NSMutableArray *legs;
	NSString       *waypointOrder;
	NSDictionary   *overviewPolyline;
	NSString       *copyrights;
	NSArray        *warnings;
}

// summary contains a short textual description for the route, suitable for naming and disambiguating the route from alternatives.
@property (nonatomic, retain) NSString *summary;

// legs[] contains an array which contains information about a leg of the route, between two locations within the given route. A separate leg will be present for each waypoint or destination specified. (A route with no waypoints will contain exactly one leg within the legs array.) Each leg consists of a series of steps. (See Directions Legs below.)
@property (nonatomic, retain) NSMutableArray *legs;

// waypoint_order contains an array indicating the order of any waypoints in the calculated route. This waypoints may be reordered if the request was passed optimize:true within its waypoints parameter.
@property (nonatomic, retain) NSString *waypointOrder;

// overview_path contains an object holding an array of encoded points and levels that represent an approximate (smoothed) path of the resulting directions.
@property (nonatomic, retain) NSDictionary *overviewPolyline;

// copyrights contains the copyrights text to be displayed for this route. You must handle and display this information yourself.
@property (nonatomic, retain) NSString *copyrights;

// warnings[] contains an array of warnings to be displayed when showing these directions. You must handle and display these warnings yourself.
@property (nonatomic, retain) NSArray *warnings;


- (id) initWithDict:(NSDictionary *)dict;
- (NSArray *)polylineWithAccuracy:(kDKRouteAccuracy)accuracy;
- (NSArray *)waypoints;


@end
