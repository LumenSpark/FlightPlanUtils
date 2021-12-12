//
//  Waypoint.m
//  fpl_utils
//
//  Created by Christoph Zelazowski on 12/11/21.
//

#import "Waypoint.h"
#import "FlightPlanUtils.h"

@implementation Waypoint


/**
 Returns a newly initialized waypoint.
 */
- (instancetype)init
{
  self = [super init];
  if (self != nil) {
    self.identifier = @"";
    self.type = @"";
    self.countryCode = @"";
    self.lat = @"";
    self.lon = @"";
    self.comment = @"";
  }
  return self;
}


/**
 Compares waypoints based on lat/lon values.
 */
- (BOOL)isEqual:(id)object
{
  Waypoint *other = object;
  return [self.lat isEqualToString:other.lat] && [self.lon isEqualToString:other.lon];
}


/**
 Compares two waypoints based on their distance from home base location.
 */
- (NSComparisonResult)compare:(Waypoint *)other
{
  NSNumberFormatter *formatter = [NSNumberFormatter new];
  [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
  
  CLLocationCoordinate2D coordinate1;
  coordinate1.latitude = [formatter numberFromString:self.lat].doubleValue;
  coordinate1.longitude = [formatter numberFromString:self.lon].doubleValue;

  CLLocationCoordinate2D coordinate2;
  coordinate2.latitude = [formatter numberFromString:other.lat].doubleValue;
  coordinate2.longitude = [formatter numberFromString:other.lon].doubleValue;

  CLLocation *location1 = [[CLLocation alloc] initWithLatitude:coordinate1.latitude longitude:coordinate1.longitude];
  CLLocation *location2 = [[CLLocation alloc] initWithLatitude:coordinate2.latitude longitude:coordinate2.longitude];

  NSNumber *dist1 = [NSNumber numberWithDouble:[location1 distanceFromLocation:_homeBaseLocation]];
  NSNumber *dist2 = [NSNumber numberWithDouble:[location2 distanceFromLocation:_homeBaseLocation]];

  return [dist1 compare:dist2];
}


/**
 Makes a copy of this waypoint.
 */
- (id)copy
{
  Waypoint *copy = [Waypoint new];
  copy.identifier = self.identifier;
  copy.type = self.type;
  copy.countryCode = self.countryCode;
  copy.lat = self.lat;
  copy.lon = self.lon;
  copy.comment = self.comment;
  return copy;
}

@end
