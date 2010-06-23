//
//  DKLeg.h
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


@interface DKLeg : NSObject {
	NSMutableArray         *steps;
	NSString               *distance;
	float                  distanceInMeters;
	NSString               *duration;
	float                  durationInSeconds;
 	NSString               *startAddress;
	NSString               *endAddress;

	CLLocationCoordinate2D startLocation;
	CLLocationCoordinate2D endLocation;
}

//steps[] contains an array of steps denoting information about each separate step of the leg of the journey. (See Directions Steps below.)
@property (nonatomic, retain) NSMutableArray *steps;

//distance indicates the total distance covered by this leg, as a field with the following elements:
@property (nonatomic, retain) NSString *distance;
@property (nonatomic, assign) float distanceInMeters;

//duration indicates the total duration of this leg, as a field with the following elements:
@property (nonatomic, retain) NSString *duration;
@property (nonatomic, assign) float durationInSeconds;

//start_location contains the latitude/longitude coordinates of the origin of this leg. Because the Directions API calculates directions between locations by using the nearest transportation option (usually a road) at the start and end points, start_location may be different than the provided origin of this leg if, for example, a road is not near the origin.
@property (nonatomic, assign) CLLocationCoordinate2D startLocation;

//end_location contains the latitude/longitude coordinates of the given destination of this leg. Because the Directions API calculates directions between locations by using the nearest transportation option (usually a road) at the start and end points, end_location may be different than the provided destination of this leg if, for example, a road is not near the destination.
@property (nonatomic, assign) CLLocationCoordinate2D endLocation;

//start_address contains the human-readable address (typically a street address) reflecting the start_location of this leg.
@property (nonatomic, retain) NSString *startAddress;

//end_addresss contains the human-readable address (typically a street address) reflecting the end_location of this leg.
@property (nonatomic, retain) NSString *endAddress;

- (id) initWithDict:(NSDictionary *)dict;

@end
