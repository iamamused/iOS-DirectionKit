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

	id <DKWaypointControlDelegate> delegate;
	
@private
	DKMapView *_map;
	DKRoute *_route;
}

- (id)initWithRoute:(DKRoute *)route map:(DKMapView *)map;
- (void)showInterface;

@property (nonatomic, retain) id <DKWaypointControlDelegate> delegate;

@end
