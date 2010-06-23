//
//  DKMapViewMarker.h
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

@class DKMapView;

@interface DKWaypointView : UIView {
	CLLocationCoordinate2D latlng;
	NSString *label;
	DKMapView *controller;
	BOOL allowAnimation;
	
@private
	MKMapPoint	_position;
	CGFloat _width;
	CGFloat _height;
}

@property (assign) CLLocationCoordinate2D latlng;
@property (assign) MKMapPoint position;
@property (assign, readonly) float sortIndex;
@property (nonatomic, retain) NSString *label;
@property (nonatomic, retain) DKMapView *controller;

@property (assign) BOOL allowAnimation;

+ (id)markerFromLatLng:(CLLocationCoordinate2D)latlng withAccuracy:(float)accuracy;

- (void)setPosition:(MKMapPoint)position animated:(BOOL)animated delay:(float)delay;
- (CGPoint)anchorPoint;

- (void)openInfoWindow;
- (CGPoint)infoWindowAnchorPoint;

- (UIImage *)iconImage;
- (CGPoint)infoWindowAnchorPoint;

- (void)bounce:(float)pause;
- (void)drop:(float)pause;

@end
