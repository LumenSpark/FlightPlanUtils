//
//  RoutePoint.m
//  fpl_utils
//
//  Created by Christoph Zelazowski on 12/11/21.
//

#import "RoutePoint.h"

@implementation RoutePoint

/**
 Returns a newly initialized waypoint.
 */
- (instancetype)init
{
  self = [super init];
  if (self != nil) {
    self.waypointIdentifier = @"";
    self.waypointType = @"";
    self.waypointCountryCode = @"";
  }
  return self;
}

@end
