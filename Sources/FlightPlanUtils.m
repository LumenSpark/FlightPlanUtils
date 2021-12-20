//
//  FlightPlanUtils.m
//  fpl_utils
//
//  Created by Christoph Zelazowski on 12/11/21.
//

#import "FlightPlanUtils.h"
#import "NSString+Additions.h"

CLLocation *_homeBaseLocation = nil;
NSString *_allWaypointsFilename = @"Waypoints.fpl";

@implementation FlightPlanUtils

/**
 Updates all custom waypoints inside flight plans in the specified folder.
 */
+ (void)updateWaypointsInFolder:(NSString *)folderPath homeBaseLat:(NSString *)lat homeBaseLon:(NSString *)lon
{
  NSError *error = nil;
  NSString *filePath = nil;
  NSMutableArray *flightPlans = [NSMutableArray new];
  folderPath = [folderPath stringByExpandingTildeInPath];
  NSArray *contents = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folderPath error:&error];
  NSMutableDictionary *flightPlanDictionary = [NSMutableDictionary new];
  
  // Read all the flight plans
  //
  for (NSString *subpath in contents) {
    filePath = [folderPath stringByAppendingPathComponent:subpath];
    FlightPlan *flightPlan = [FlightPlanUtils readFlightPlan:filePath];
    if (flightPlan) {
      [flightPlans addObject:flightPlan];
      flightPlanDictionary[filePath] = flightPlan;
    }
  }
  
  // Sort and rename user waypoints
  //
  NSMutableArray *allUserWaypoints = [FlightPlanUtils extractUserWaypointsFromFlightPlans:flightPlans];
  [FlightPlanUtils sortWaypoints:allUserWaypoints homeBaseLat:lat homeBaseLon:lon];
  NSString *format = (allUserWaypoints.count < 99) ? @"WP%02d" : @"WP%03d";
  for (int i=0; i < allUserWaypoints.count; i++) {
    Waypoint *waypoint = allUserWaypoints[i];
    waypoint.identifier = [NSString stringWithFormat:format, i+1];
  }
  
  // Update user waypoints in the flight plans
  //
  for (FlightPlan *flightPlan in flightPlans) {
    NSMutableArray *waypoints = [NSMutableArray new];
    NSMutableArray *routePoints = [NSMutableArray new];
    NSMutableArray *replacements = [NSMutableArray new];
    
    for (RoutePoint *routePoint in flightPlan.routePoints) {
      Waypoint *waypoint = [FlightPlanUtils waypointWithName:routePoint.waypointIdentifier flightPlan:flightPlan];
      NSAssert(waypoint != nil, @"Missing waypoint");
      if ([waypoint.type isEqualToString:@"USER WAYPOINT"] == NO) continue;
      
      NSUInteger index = [allUserWaypoints indexOfObject:waypoint];
      NSAssert(index != NSNotFound, @"Index not found");
      Waypoint *replacement = [allUserWaypoints objectAtIndex:index];
      
      [waypoints addObject:waypoint];
      [routePoints addObject:routePoint];
      [replacements addObject:replacement];
    }
    
    for (int i=0; i < waypoints.count; i++) {
      Waypoint *waypoint = waypoints[i];
      RoutePoint *routePoint = routePoints[i];
      Waypoint *replacement = replacements[i];
      waypoint.identifier = routePoint.waypointIdentifier = replacement.identifier;
    }
  }
  
  // Create a flight plan containing ALL user waypoints (G1000 doesn't support importing of waypoints alone)
  //
  FlightPlan *flightPlan = [FlightPlan new];
  flightPlan.created = [NSDate date];
  flightPlan.routeName = @"ALL WAYPOINTS";
  flightPlan.waypoints = allUserWaypoints;
  filePath = [folderPath stringByAppendingPathComponent:_allWaypointsFilename];
  flightPlanDictionary[filePath] = flightPlan;
  
  NSMutableArray *routePoints = [NSMutableArray new];
  for (Waypoint *waypoint in flightPlan.waypoints) {
    RoutePoint *routePoint = [RoutePoint new];
    routePoint.waypointIdentifier = waypoint.identifier;
    routePoint.waypointType = @"USER WAYPOINT";
    [routePoints addObject:routePoint];
  }
  flightPlan.routePoints = routePoints;
  
  NSMutableArray *filePaths = [flightPlanDictionary.allKeys mutableCopy];
  [filePaths sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
    return [obj1.lastPathComponent compare:obj2.lastPathComponent];
  }];
  
  // Write updated flight plans to disk
  //
  for (NSString *filePath in filePaths) {
    FlightPlan *flightPlan = flightPlanDictionary[filePath];
    [flightPlan.description writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
      Log(@"Error saving %@ : %@", filePath.lastPathComponent, error.description);
    }
    else {
      Log(@"✓ %@", flightPlan.routeName);
    }
    error = nil;
  }
  
  Log(@"");
}


/**
 Reads the flight plan from the specified file.
 */
+ (FlightPlan *)readFlightPlan:(NSString *)filePath
{
  NSError *error = nil;
  FlightPlan *flightPlan = [FlightPlan new];

  if ([filePath hasSuffix:@".fpl"] == NO) return nil;
  if ([filePath.lastPathComponent isEqualToString:_allWaypointsFilename]) return nil;
  
  NSString *strings = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
  if (error) {
    strings = [NSString stringWithContentsOfFile:filePath encoding:NSUnicodeStringEncoding error:&error];
  }
  
  Waypoint *waypoint = nil;
  RoutePoint *routePoint = nil;
  NSMutableArray *waypoints = [NSMutableArray new];
  NSMutableArray *routePoints = [NSMutableArray new];
  NSArray *lines = [strings componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
  for (NSString *line in lines) {
    NSString *tag = nil, *valueString = nil;
          
    tag = @"created";
    if ([line containsStartTag:tag]) {
      valueString = [line valueWithinTag:tag];
      NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
      [dateFormatter setDateFormat:@"yyyyMMdd'T'HH:mm:ssZ"];
      NSDate *date = [dateFormatter dateFromString:valueString];
      if (!date) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        date = [dateFormatter dateFromString:valueString];
      }
      flightPlan.created = date;
    }
    
    tag = @"waypoint";
    if ([line containsStartTag:tag]) {
      waypoint = [Waypoint new];
      continue;
    }
    if ([line containsEndTag:tag]) {
      if (waypoint) {
        if (waypoint.countryCode.isPresent == NO) {
          waypoint.countryCode = @"K1";
        }
        if ([waypoint.type isEqualToString:@"USER WAYPOINT"]) {
          waypoint.countryCode = @"";
        }
        [waypoints addObject:waypoint];
      }
      continue;
    }

    tag = @"identifier";
    if ([line containsStartTag:tag]) {
      waypoint.identifier = [line valueWithinTag:tag];
      continue;;
    }
    
    tag = @"type";
    if ([line containsStartTag:tag]) {
      waypoint.type = [line valueWithinTag:tag];
      if (waypoint.type.isPresent == NO) {
        waypoint.type = @"USER WAYPOINT";
      }
      continue;;
    }
    
    tag = @"country-code";
    if ([line containsStartTag:tag]) {
      waypoint.countryCode = [line valueWithinTag:tag];
      continue;;
    }
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormat:@"0.000000"];
    
    tag = @"lat";
    if ([line containsStartTag:tag]) {
      valueString = [line valueWithinTag:tag];
      NSNumber *value = [NSNumber numberWithDouble:valueString.doubleValue];
      if (value) {
        waypoint.lat = [numberFormatter stringFromNumber:value];
      }
    }
    
    tag = @"lon";
    if ([line containsStartTag:tag]) {
      valueString = [line valueWithinTag:tag];
      NSNumber *value = [NSNumber numberWithDouble:valueString.doubleValue];
      if (value) {
        waypoint.lon = [numberFormatter stringFromNumber:value];
      }
    }
    
    tag = @"comment";
    if ([line containsStartTag:tag]) {
      waypoint.comment = [line valueWithinTag:tag];
      continue;;
    }
    
    tag = @"route-name";
    if ([line containsStartTag:tag]) {
      NSString *filename = filePath.stringByDeletingPathExtension.lastPathComponent.uppercaseString;
      flightPlan.routeName = filename;
      continue;;
    }
    
    tag = @"route-point";
    if ([line containsStartTag:tag]) {
      routePoint = [RoutePoint new];
      continue;
    }
    if ([line containsEndTag:tag]) {
      if (routePoint) {
        if (routePoint.waypointCountryCode.isPresent == NO) {
          routePoint.waypointCountryCode = @"K1";
        }
        if ([routePoint.waypointType isEqualToString:@"USER WAYPOINT"]) {
          routePoint.waypointCountryCode = @"";
        }
        [routePoints addObject:routePoint];
      }
      continue;
    }
    
    tag = @"waypoint-identifier";
    if ([line containsStartTag:tag]) {
      routePoint.waypointIdentifier = [line valueWithinTag:tag];
      continue;;
    }
    
    tag = @"waypoint-type";
    if ([line containsStartTag:tag]) {
      routePoint.waypointType = [line valueWithinTag:tag];
      if (routePoint.waypointType.isPresent == NO) {
        routePoint.waypointType = @"USER WAYPOINT";
      }
      continue;;
    }
    
    tag = @"waypoint-country-code";
    if ([line containsStartTag:tag]) {
      routePoint.waypointCountryCode = [line valueWithinTag:tag];
      continue;;
    }
  }
  
  flightPlan.waypoints = [waypoints copy];
  flightPlan.routePoints = [routePoints copy];
  
  return flightPlan;
}


/**
 Extracts all the waypoints from an array with flight plans.
 */
+ (NSMutableArray *)extractUserWaypointsFromFlightPlans:(NSArray *)list
{
  NSMutableArray *result = [NSMutableArray new];
  for (FlightPlan *flightPlan in list) {
    for (Waypoint *waypoint in flightPlan.waypoints) {
      if ([waypoint.type isEqualToString:@"USER WAYPOINT"] && [result containsObject:waypoint] == NO) {
        [result addObject:[waypoint copy]];
      }
    }
  }
  return result;
}


/**
  Returns waypoint with the specified name.
 */
+ (Waypoint *)waypointWithName:(NSString *)identifier flightPlan:(FlightPlan *)flightPlan
{
  for (Waypoint *waypoint in flightPlan.waypoints) {
    if ([waypoint.identifier isEqualToString:identifier]) return waypoint;
  }
  return nil;
}


/**
 Sorts the list of waypoints based on distance from home base location.
 */
+ (void)sortWaypoints:(NSMutableArray *)list homeBaseLat:(NSString *)lat homeBaseLon:(NSString *)lon
{
  NSNumberFormatter *formatter = [NSNumberFormatter new];
  [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
  
  CLLocationCoordinate2D homeBaseCoordinate;
  homeBaseCoordinate.latitude = [formatter numberFromString:lat].doubleValue;
  homeBaseCoordinate.longitude = [formatter numberFromString:lon].doubleValue;
  _homeBaseLocation = [[CLLocation alloc] initWithLatitude:homeBaseCoordinate.latitude longitude:homeBaseCoordinate.longitude];
  
  [list sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    return ([obj1 compare:obj2]);
  }];
}


/**
 Outputs the specified information to stdout.
 */
+ (void)output:(NSString *)output, ...
{
  va_list argList;
  NSString *formatStr;
  
  va_start(argList, output);
  formatStr = [[NSString alloc] initWithFormat:output arguments:argList];
  va_end(argList);
  
  if (formatStr.length == 1 && [formatStr characterAtIndex:0] == '\n') {
    fprintf(stdout,"\n");
  }
  else {
    fprintf(stdout,"%s\n", formatStr.UTF8String);
  }
}

@end
