//
//  FlightPlan.m
//  fpl_utils
//
//  Created by Christoph Zelazowski on 12/11/21.
//

#import "FlightPlan.h"
#import "NSString+Additions.h"

@implementation FlightPlan

/**
 Returns flight plan description in G1000 FPL format.
 */
- (NSString *)description
{
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    
  NSMutableString *result = [NSMutableString new];
  [result appendFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"];
  [result appendFormat:@"<flight-plan xmlns=\"http://www8.garmin.com/xmlschemas/FlightPlan/v1\">\n"];
  [result appendFormat:@"<created>%@</created>\n", [dateFormatter stringFromDate:self.created]];
  [result appendFormat:@"  <waypoint-table>\n"];
  
  for (Waypoint *waypoint in self.waypoints) {
    [result appendFormat:@"    <waypoint>\n"];
    [result appendFormat:@"      <identifier>%@</identifier>\n", waypoint.identifier];
    [result appendFormat:@"      <type>%@</type>\n", waypoint.type];
    
    if (waypoint.countryCode.isPresent) {
      [result appendFormat:@"      <country-code>%@</country-code>\n", waypoint.countryCode];
    }
    else {
      [result appendFormat:@"      <country-code />\n"];
    }

    [result appendFormat:@"      <lat>%@</lat>\n", waypoint.lat];
    [result appendFormat:@"      <lon>%@</lon>\n", waypoint.lon];

    if (waypoint.comment.isPresent) {
      [result appendFormat:@"      <comment>%@</comment>\n", waypoint.comment];
    }
    else {
      [result appendFormat:@"      <comment />\n"];
    }
    [result appendFormat:@"    </waypoint>\n"];
  }
  [result appendFormat:@"  </waypoint-table>\n"];

  [result appendFormat:@"  <route>\n"];
  [result appendFormat:@"    <route-name>%@</route-name>\n", self.routeName];
  [result appendFormat:@"    <flight-plan-index>1</flight-plan-index>\n"];

  for (RoutePoint *routePoint in self.routePoints) {
    [result appendFormat:@"    <route-point>\n"];
    [result appendFormat:@"      <waypoint-identifier>%@</waypoint-identifier>\n", routePoint.waypointIdentifier];
    [result appendFormat:@"      <waypoint-type>%@</waypoint-type>\n", routePoint.waypointType];
    
    if (routePoint.waypointCountryCode.isPresent) {
      [result appendFormat:@"      <waypoint-country-code>%@</waypoint-country-code>\n", routePoint.waypointCountryCode];
    }
    else {
      [result appendFormat:@"      <waypoint-country-code />\n"];
    }
    [result appendFormat:@"    </route-point>\n"];
  }
  
  [result appendFormat:@"  </route>\n"];
  [result appendFormat:@"</flight-plan>\n"];

  return [result copy];
}

@end
