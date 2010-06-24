//
//  DKWaypointControl.h
//  DirectionKit
//
//  Created by Jeffrey Sambells on 10-06-16.
//  Copyright 2010 We-Create Inc. All rights reserved.
//

#import "DirectionKit.h"

@class DKRoute;
@class DKMapView;

@interface DKWaypointControl : UIView {

@private
	DKMapView *_map;
	UISegmentedControl *_control;
}

- (id)initWithRoute:(DKRoute *)route map:(DKMapView *)map;

@end
