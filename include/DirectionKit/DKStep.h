//
//  DKStep.h
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


@interface DKStep : NSObject {
	NSString               *instructions;
	NSString               *distance;
	float                  distanceInMeters;
	NSString               *duration;
	float                  durationInSeconds;
	NSDictionary           *polyline;
	
	CLLocationCoordinate2D startLocation;
	CLLocationCoordinate2D endLocation;
}

//html_instructions contains formatted instructions for this step, presented as an HTML text string.
@property (nonatomic, retain) NSString *instructions;

//distance contains the distance covered by this step until the next step. (See the discussion of this field in Directions Legs above.) This field may be undefined if the distance is unknown.
@property (nonatomic, retain) NSString *distance;
@property (nonatomic, assign) float distanceInMeters;

//duration contains the typical time required to perform the step, until the next step (See the description in Directions Legs above.) This field may be undefined if the duration is unknown.
@property (nonatomic, retain) NSString *duration;
@property (nonatomic, assign) float durationInSeconds;

//start_location contains the location of the starting point of this step, as a single set of lat and lng fields.
@property (nonatomic, assign) CLLocationCoordinate2D startLocation;

//end_location contains the location of the starting point of this step, as a single set of lat and lng fields.
@property (nonatomic, assign) CLLocationCoordinate2D endLocation;

@property (nonatomic, retain) NSDictionary *polyline;

- (id) initWithDict:(NSDictionary *)dict;

@end
